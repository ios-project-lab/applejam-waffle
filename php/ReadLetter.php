<?php
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

include_once(./config.php);

$conn = new mysqli($host, $user, $pw, $dbName);
$conn->set_charset("utf8");

$lettersId = $_POST["lettersId"] ?? "";

if ($lettersId === "") {
    echo json_encode(["error" => "missing lettersId"]);
    exit;
}

$idEsc = intval($lettersId);

// 1. 읽음 처리 (isRead = 1)
$conn->query("UPDATE Letters SET isRead=1 WHERE lettersId=$idEsc");

// 2. 편지 상세 정보 리턴
$result = $conn->query("SELECT * FROM Letters WHERE lettersId = $idEsc");
$letterData = $result->fetch_assoc();

if ($letterData) {
    echo json_encode($letterData, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
} else {
    echo json_encode(["error" => "Letter not found"]);
}

$conn->close();
?>
