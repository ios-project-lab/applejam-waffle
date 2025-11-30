<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// DB 연결
//$host = getenv('DB_HOST');
//$user = getenv('DB_USER');
//$pw = getenv('DB_PASSWORD');
//$dbName = getenv('DB_NAME');

include_once('./config.php');

$conn = new mysqli($host, $user, $pw, $dbName);

if (!$conn) {
    echo json_encode(["error" => "DB 연결 실패"]);
    exit;
}

// 입력 JSON
$input = json_decode(file_get_contents("php://input"), true);

// 편지 필드들 받기
$title             = $input["title"] ?? "";
$content           = $input["content"] ?? "";
$expectedArrivalTime = $input["expectedArrivalTime"] ?? "";
$receiverType      = $input["receiverType"] ?? 0;
$senderId          = $input["senderId"] ?? 0;
$receiverId        = $input["receiverId"] ?? 0;
$arrivedType       = $input["arrivedType"] ?? 0;
$emotionsId        = $input["emotionsId"] ?? 0;
$parentLettersId   = $input["parentLettersId"] ?? 0;

// AI 분석용 필드
$text    = $input["text"] ?? "";
$emotion = $input["emotion"] ?? "";
$goal    = $input["goal"] ?? "";

// OpenAI Key
$apiKey = getenv("OPENAI_API_KEY");

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

TEXT: \"$text\"
USER_EMOTION: \"$emotion\"
USER_GOAL: \"$goal\"
";

// OpenAI 호출
$aiResponse = openai_request($prompt, $apiKey);
$aiContent = $aiResponse["choices"][0]["message"]["content"] ?? "{}";

// ----------------------------
// DB INSERT
// ----------------------------
$sql = "
INSERT INTO letters (
    title,
    content,
    expectedArrivalTime,
    receiverType,
    senderId,
    receiverId,
    arrivedType,
    emotionsId,
    parentLettersId,
    aiCheering
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
";

$stmt = $conn->prepare($sql);

$stmt->bind_param(
    "sssiiiiiis",
    $title,
    $content,
    $expectedArrivalTime,
    $receiverType,
    $senderId,
    $receiverId,
    $arrivedType,
    $emotionsId,
    $parentLettersId,
    $aiContent
);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "저장 성공", "ai" => $aiContent]);
} else {
    echo json_encode(["success" => false, "error" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>
