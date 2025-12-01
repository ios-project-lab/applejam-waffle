<?php
// DB 접속 정보 (환경 변수 사용)
include_once('./config.php');

// 응답 헤더 설정
header('Content-Type: application/json');

// 데이터베이스 연결
$conn = new mysqli($host, $user, $pw, $dbName);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection failed: " . $conn->connect_error]);
    exit();
}

$friendsId = $_POST['friendsId'];

if (!$friendsId) {
    echo "missing_params";
    exit;
}

$query = "
UPDATE Friends
SET friendStatus = '3', updatedAt = NOW()
WHERE friendsId = '$friendsId'
";

if (mysqli_query($conn, $query)) {
    echo "success";
} else {
    echo "fail";
}
$stmt->close();
$conn->close();
?>
