<?php
// 1. 헤더 설정
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 

// 2. 데이터베이스 연결 설정 (getenv 사용 유지)
include_once('./config.php');
// MySQL 연결
$conn = new mysqli($host, $user, $pw, $dbName);

$friendsId = $_POST['friendsId'];

if (!$friendsId) {
    echo "missing_params";
    exit;
}

$query = "
UPDATE Friends
SET friendStatus = '5', updatedAt = NOW()
WHERE friendsId = '$friendsId'
";

if (mysqli_query($conn, $query)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "fail"]);
}

// 7. 연결 종료
$stmt->close();
$conn->close();
?>
