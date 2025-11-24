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

$host = 'localhost';
$user = 'brant';
$pw = '0505';
$dbName = 'FutureMe';

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

$conn->close();
?>
