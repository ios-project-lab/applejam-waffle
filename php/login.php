<?php
// login.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=utf-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// DB 접속
$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pw = getenv('DB_PASSWORD');
$dbName = getenv('DB_NAME');

// 데이터 받기
$id = $_POST['id'] ?? '';
$pwd = $_POST['pwd'] ?? '';

if (!$id || !$pwd) {
    http_response_code(400);
    echo json_encode(["message" => "아이디와 비밀번호를 입력해주세요."]);
    exit;
}

// DB 연결
$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["message" => "DB 연결 실패"]);
    exit;
}
$conn->set_charset("utf8");

// 유저 조회
$stmt = $conn->prepare("SELECT * FROM Users WHERE id = ?");
$stmt->bind_param("s", $id);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if ($user && ((string)$pwd === (string)$user['password'])) {
    
    http_response_code(200);
    echo json_encode([
        "usersId" => $user['usersId'],
        "id" => $user['id'],
        "nickName" => $user['nickName']
    ]);

} else {
    http_response_code(401);
    echo json_encode(["message" => "아이디 또는 비밀번호가 잘못되었습니다."]);
}

$stmt->close();
$conn->close();
?>
