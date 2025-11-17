<?php
// GetInbox.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pw = getenv('DB_PASSWORD');
$dbName = getenv('DB_NAME');
// MySQL 연결
$conn = new mysqli($host, $user, $pw, $dbName);

// 연결 확인
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(array("error" => "Database Connection failed: " . $conn->connect_error)));
}
    
$conn->set_charset("utf8");

$userId = $_GET["userId"] ?? "";

if ($userId === "") {
    http_response_code(400);
    echo "error: missing userId";
    exit;
}

$userEsc = intval($userId);

$sql = "SELECT * FROM Letters WHERE receiverId = $userEsc ORDER BY createdAt DESC";
$result = $conn->query($sql);

$list = [];

while ($row = $result->fetch_assoc()) {
    $list[] = $row;
}

echo json_encode($list, JSON_UNESCAPED_UNICODE);

$conn->close();
?>
