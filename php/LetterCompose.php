<?php
// LetterCompose.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=utf-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

//$host = getenv('DB_HOST');
//$user = getenv('DB_USER');
//$pw = getenv('DB_PASSWORD');
//$dbName = getenv('DB_NAME');

include_once('./config.php');

$conn = new mysqli($host, $user, $pw, $dbName);
$conn->set_charset("utf8");

if ($conn->connect_error) {
    die(json_encode(["error" => "DB Connection failed: " . $conn->connect_error]));
}

$senderIntId = $_POST['senderId'] ?? '';
$receiverStringId = $_POST['receiverId'] ?? '';
$title = $_POST['title'] ?? '';
$content = $_POST['content'] ?? '';
$expectedArrivalTime = $_POST['expectedArrivalTime'] ?? '';
$parentLettersId = $_POST['parentLettersId'] ?? 0;

$findUser = $conn->prepare("SELECT usersId FROM Users WHERE id = ?");
$findUser->bind_param("s", $receiverStringId);
$findUser->execute();
$result = $findUser->get_result();
$userRow = $result->fetch_assoc();

if (!$userRow) {
    echo json_encode(["error" => "받는 사람을 찾을 수 없습니다."]);
    exit;
}

// 진짜 receiverId(PK, int)
$receiverId = (int)$userRow['usersId'];


if (empty($senderIntId) || empty($receiverStringId)) {
    echo json_encode(["error" => "보내는 사람 또는 받는 사람 정보가 없습니다."]);
    exit;
}

$findUser = $conn->prepare("SELECT usersId FROM Users WHERE id = ?");
$findUser->bind_param("s", $receiverStringId);
$findUser->execute();
$result = $findUser->get_result();
$row = $result->fetch_assoc();

if (!$row) {
    echo json_encode(["error" => "받는 사람 아이디($receiverStringId)를 찾을 수 없습니다."]);
    exit;
}

$receiverIntId = $row['usersId'];
$receiverType = ($senderIntId == $receiverIntId) ? 0 : 1;

$sql = "INSERT INTO Letters (
    senderId, receiverId, title, content, expectedArrivalTime, 
    receiverType, arrivedType, emotionsId, parentLettersId, 
    createdAt, updatedAt, isRead, isLocked
) VALUES (?, ?, ?, ?, ?, ?, 1, 1, ?, NOW(), NOW(), 0, 1)";

$stmt = $conn->prepare($sql);
$stmt->bind_param("iisssii",
    $senderIntId,
    $receiverIntId,
    $title,
    $content,
    $expectedArrivalTime,
    $receiverType,
    $parentLettersId
);

if ($stmt->execute()) {
    echo json_encode(["success" => "편지가 성공적으로 발송되었습니다."]);
} else {
    echo json_encode(["error" => "DB 입력 실패: " . $stmt->error]);
}

// ----------------------------
// 4) 방금 생성된 letterId 가져오기
// ----------------------------
$letterId = $conn->insert_id;

if (!$letterId) {
    echo json_encode(["success" => false, "error" => "letterId 없음"]);
    exit;
}

// DB에서 해당 레터 가져오기
$sql = "SELECT * FROM Letters WHERE lettersId = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $letterId);
$stmt->execute();
$result = $stmt->get_result();
$letter = $result->fetch_assoc();

if (!$letter) {
    echo json_encode(["success" => false, "error" => "해당 letterId 없음"]);
    exit;
}

// DB에서 분석용 필드 가져오기
$title   = $letter["title"];
$content = $letter["content"];
$emotion = $letter["emotionsId"];
$goal    = $letter["goal"] ?? "";


// OpenAI 요청 함수
function openai_request($prompt, $apiKey) {
    $url = "https://api.openai.com/v1/chat/completions";

    $payload = [
        "model" => "gpt-4o-mini",
        "messages" => [
            ["role" => "system", "content" => "Respond ONLY in valid JSON. No extra text."],
            ["role" => "user", "content" => $prompt]
        ]
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Content-Type: application/json",
        "Authorization: " . "Bearer " . $apiKey
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

    $res = curl_exec($ch);
    curl_close($ch);

    return json_decode($res, true);
}

// OpenAI Prompt 생성
$prompt = "
Analyze the following user letter, emotion, and goal. 
Return a single JSON:

{
  \"overall_analysis\": \"string\",
  \"sentiment_analysis\": {
      \"sentiment\": \"string\",
      \"score\": number,
      \"reason\": \"string\"
  },
  \"goal_analysis\": {
      \"progress_percent\": number,
      \"feedback\": \"string\",
      \"next_step\": \"string\"
  }
}

TEXT: \"$content\"
USER_EMOTION: \"$emotion\"
USER_GOAL: \"$goal\"
";

// OpenAI 호출
$aiResponse = openai_request($prompt, $apiKey);
$aiContent = $aiResponse["choices"][0]["message"]["content"] ?? "{}";

// ----------------------------
// DB UPDATE (기존 letterId에 aiCheering 업데이트)
// ----------------------------

$sql = "
UPDATE Letters
SET aiCheering = ?
WHERE lettersId = ?
";

$stmt = $conn->prepare($sql);
$stmt->bind_param(
    "si",
    $aiContent,     // 업데이트할 AI 문자열
    $letterId       // 이미 존재하는 letterId
);

if (!$stmt->execute()) {
    echo json_encode(["error" => "AI 업데이트 실패: " . $stmt->error]);
    exit;
}

// ----------------------------
// 7) 성공 반환
// ----------------------------
echo json_encode([
    "success" => true,
    "message" => "편지가 성공적으로 발송되었습니다.",
    "letterId" => $letterId,
    "aiCheering" => $aiContent
]);

// 알림 생성
if($senderIntId != reveiverId){
    $notifSql = "
        INSERT INTO Notifications (title, content, isRead, notificationTypesId, usersId)
        VALUES ('편지 도착', '친구가 보낸 편지: {$title}', 0, 1, ?)
    ";
    // notificationTypesId = 1 → 미래편지 도착 알림
}else{
    $notifSql = "
        INSERT INTO Notifications (title, content, isRead, notificationTypesId, usersId)
        VALUES ('미래편지 도착', '미래의 나에게서 온 편지: {$title}', 0, 1, ?)
    ";
    // notificationTypesId = 1 → 미래편지 도착 알림
}

$notif = $conn->prepare($notifSql);
$notif->bind_param("i", $receiverId);
if (!$notif->execute()) {
    echo "알림 insert 에러: " . $notif->error;
}

$conn->close();
?>
