<?php

// DB 접속 정보
//$host = getenv('DB_HOST');
//$user = getenv('DB_USER');
//$pw = getenv('DB_PASSWORD');
//$dbName = getenv('DB_NAME');

include_once('./config.php');

// 응답 헤더를 미리 JSON으로 설정
header('Content-Type: application/json; charset=utf-8');

// 데이터베이스 연결
$conn = new mysqli($host, $user, $pw, $dbName);

// 연결 확인 (실패 시 JSON 응답)
if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection failed: " . $conn->connect_error]);
    exit();
}

// 쿼리 실행
$sql = "SELECT categoriesId, name FROM Categories ORDER BY categoriesId ASC"; 
$result = $conn->query($sql);

$categories = array();

if ($result === false) {
    echo json_encode(["error" => "SQL query failed: " . $conn->error]);
    $conn->close();
    exit();
}

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $categories[] = $row;
    }
}

echo json_encode($categories, JSON_UNESCAPED_UNICODE);

$conn->close();
?>
