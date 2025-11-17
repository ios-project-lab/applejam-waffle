<?php
// GetInbox.php

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
    echo json_encode(array("error" => "missing userId"));
    exit;
}

$userEsc = intval($userId);

$sql = "SELECT * FROM Letters WHERE receiverId = $userEsc ORDER BY createdAt DESC";
$result = $conn->query($sql);

$list = array();

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $list[] = $row;
    }
}

echo json_encode($list, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

$conn->close();
?>
