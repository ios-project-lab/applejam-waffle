<?php
//LetterCompose.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=utf-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pw = getenv('DB_PASSWORD');
$dbName = getenv('DB_NAME');

$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    echo json_encode(["error" => "CONNECTION_FAILED: " . $conn->connect_error]);
    exit;
}

$senderId = $_POST['senderId'] ?? '';
$receiverId = $_POST['receiverId'] ?? '';
$title = $_POST['title'] ?? '';
$content = $_POST['content'] ?? '';
$expectedArrivalTime = $_POST['expectedArrivalTime'] ?? '';

// 0: 나에게, 1: 친구에게
$receiverType = 0;
$arrivedType = 1;
$emotionsId = 1;
$parentLettersId = 1;

if (empty($senderId) || empty($receiverId) || empty($title) || empty($content) || empty($expectedArrivalTime)) {
    echo json_encode(["error" => "VALIDATION_ERROR: Missing required fields."]);
    exit;
}

$sql = "INSERT INTO Letters (
    senderId, 
    receiverId, 
    title, 
    content, 
    expectedArrivalTime, 
    receiverType,   
    arrivedType,
    emotionsId,
    parentLettersId,
    createdAt, 
    updatedAt
) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
if (!$stmt = $conn->prepare($sql)) {
    echo json_encode(["error" => "PREPARE_FAILED: " . $conn->error]);
    $conn->close();
    exit;
}

$stmt->bind_param("iisssiiii",
    $senderId,
    $receiverId,
    $title,
    $content,
    $expectedArrivalTime,
    $receiverType,
    $arrivedType,
    $emotionsId,
    $parentLettersId

);

if ($stmt->execute()) {
    echo json_encode(["success" => "편지가 성공적으로 발송되었습니다."]);
} else {
    echo json_encode(["error" => "편지 발송 실패: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
