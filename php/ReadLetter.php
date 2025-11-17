<?php
// ReadLetter.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
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
    
$conn->set_charset("utf8");

$lettersId = $_POST["lettersId"] ?? "";

if ($lettersId === "") {
    http_response_code(400);
    echo "error: missing lettersId";
    exit;
}

$idEsc = intval($lettersId);

// mark as read
$conn->query("UPDATE Letters SET isRead=1 WHERE lettersId=$idEsc");

$sql = "SELECT * FROM Letters WHERE lettersId = $idEsc";
$result = $conn->query($sql);

echo json_encode($result->fetch_assoc(), JSON_UNESCAPED_UNICODE);

$conn->close();
?>
