<?php
header('Content-Type: application/json');

// DB 접속 정보
include_once('./config.php');

// DB 연결
$conn = new mysqli($host, $user, $pw, $dbName);

if ($conn->connect_error) {
    echo json_encode(["error" => "db_connect_fail"]);
    exit;
}

$friendsId = $_POST['friendsId'];

if (!$friendsId) {
    echo json_encode(["error" => "missing_params"]);
    exit;
}

// 1) 친구 요청 관계 가져오기
$getQuery = "SELECT requesterId, receiverId FROM Friends WHERE friendsId = '$friendsId'";
$getResult = mysqli_query($conn, $getQuery);

if (!$getResult || mysqli_num_rows($getResult) == 0) {
    echo json_encode(["error" => "not_found"]);
    exit;
}

$row = mysqli_fetch_assoc($getResult);
$requesterId = $row['requesterId'];
$receiverId = $row['receiverId'];

// 2) Friends friendStatus = 2 (수락)
$updateFriend = "
UPDATE Friends
SET friendStatus = '2', updatedAt = NOW()
WHERE friendsId = '$friendsId'
";
mysqli_query($conn, $updateFriend);

// 3) Users receiver → requester (기존)
$insertReverse = "
INSERT INTO Friends (requesterId, receiverId, friendStatus, createdAt, updatedAt)
VALUES ('$receiverId', '$requesterId', '2', NOW(), NOW());
";
mysqli_query($conn, $insertReverse);

echo json_encode(["status" => "success"]);

// 4) 🎉 친구 요청 수락 알림 생성
// 알림을 받아야 하는 사람 = "요청을 보낸 사람" → requesterUsersId

$notifSql = "
INSERT INTO Notifications (title, content, isRead, notificationTypesId, usersId)
VALUES ('친구 요청 수락됨', '상대방이 친구 요청을 수락했습니다!', 0, 3, ?)
";

$notif = $conn->prepare($notifSql);
$notif->bind_param("i", $requesterId);

if (!$notif->execute()) {
    echo json_encode([
        "error" => "notif_fail",
        "detail" => $notif->error
    ]);
    exit;
}

$conn->close();
?>
