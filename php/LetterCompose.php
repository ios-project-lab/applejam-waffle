<?php
// LetterCompose.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

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

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo "error: Invalid method. Use POST.";
    exit;
}

$senderId = $_POST["senderId"] ?? "";
$receiverId = $_POST["receiverId"] ?? "";
$title = $_POST["title"] ?? "";
$content = $_POST["content"] ?? "";
$receiveDateRaw = $_POST["receiveDate"] ?? "";

if ($senderId === "" || $receiverId === "" || $title === "" || $content === "") {
    http_response_code(400);
    echo "error: Missing required POST parameters.";
    exit;
}

$expectedArrival = null;
if ($receiveDateRaw !== "") {
    $dt = DateTime::createFromFormat('Y-m-d H:i:s', $receiveDateRaw);
    if ($dt !== false) {
        $expectedArrival = $dt->format('Y-m-d H:i:s');
    } else {
        $parts = preg_split('/\s+/', $receiveDateRaw);
        if (count($parts) >= 2) {
            $expectedArrival = $parts[0] . " " . $parts[1];
        }
    }
}

$expectedArrivalSQL = $expectedArrival ? "'" . $conn->real_escape_string($expectedArrival) . "'" : "NULL";

$createdAt = date('Y-m-d H:i:s');
$updatedAt = $createdAt;

$titleEsc = $conn->real_escape_string($title);
$contentEsc = $conn->real_escape_string($content);
$senderEsc = intval($senderId);
$receiverEsc = intval($receiverId);

$sql = "
INSERT INTO Letters (
    title, content, senderId, receiverId, expectedArrivalTime,
    createdAt, updatedAt, isLocked, isRead, isCheering,
    receiverType, arrivedType, emotionsId, goalsHistorieId, parentLetterId
) VALUES (
    '{$titleEsc}', '{$contentEsc}', {$senderEsc}, {$receiverEsc}, {$expectedArrivalSQL},
    '{$createdAt}', '{$updatedAt}', 0, 0, 0,
    1, 1, NULL, NULL, NULL
)
";

if ($conn->query($sql)) {
    echo "success: letter created";
} else {
    http_response_code(500);
    echo "error: " . $conn->error;
}

$conn->close();
?>
