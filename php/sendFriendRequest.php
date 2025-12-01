<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 

include_once('./config.php');

// MySQL 연결
$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    echo json_encode(array("error" => "db_connect_fail"));
    exit;
}

// iOS 요청 값
$requesterId = $_POST['usersId'];  // 요청 보낸 사용자
$friendNickName = $_POST['friendNickName']; // 닉네임으로 친구 찾기

if (!$requesterId || !$friendNickName) {
    echo json_encode(array("error" => "missing_params"));
    exit;
}

// 1) 닉네임으로 receiverId 찾기
$userQuery = "SELECT id FROM Users WHERE nickName = '$friendNickName'";
$userResult = mysqli_query($conn, $userQuery);

if (!$userResult || mysqli_num_rows($userResult) == 0) {
    echo "user_not_found";
    exit;
}

$userData = mysqli_fetch_assoc($userResult);
$receiverId = $userData['id'];

// 2) 이미 친구 요청이 있는지 확인
$checkQuery = "
    SELECT * FROM Friends
    WHERE requesterId = '$requesterId' AND receiverId = '$receiverId'
       OR requesterId = '$receiverId' AND receiverId = '$requesterId'
";
$checkResult = mysqli_query($conn, $checkQuery);

if (mysqli_num_rows($checkResult) > 0) {
    echo "already_exists";
    exit;
}

// 3) 친구 요청 생성 (friendStatus = pending)
$insertQuery = "
    INSERT INTO Friends (requesterId, receiverId, friendStatus, createdAt, updatedAt)
    VALUES ('$requesterId', '$receiverId', '1', NOW(), NOW())
";

if (mysqli_query($conn, $insertQuery)) {
    echo json_encode(array("status" => "success"));
} else {
    echo json_encode(array("error" => "insert_fail"));
}
$conn->close();
?>
