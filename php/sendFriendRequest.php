<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include_once('./config.php');

// MySQL 연결
$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    echo json_encode(["error" => "db_connect_fail"]);
    exit;
}

// iOS 요청 값
$requesterId = intval($_POST['usersId']);
$friendNickName = $_POST['friendNickName'];

if (!$requesterId || !$friendNickName) {
    echo json_encode(["error" => "missing_params"]);
    exit;
}

// 1) 닉네임으로 receiverId 찾기 (id + usersId 둘 다)
$findUser = $conn->prepare("SELECT id, usersId FROM Users WHERE nickName = ?");
$findUser->bind_param("s", $friendNickName);
$findUser->execute();
$userResult = $findUser->get_result();

if ($userResult->num_rows == 0) {
    echo json_encode(["error" => "user_not_found"]);
    exit;
}

$userRow = $userResult->fetch_assoc();
$receiverId = intval($userRow['id']);       // Friends 테이블용
$receiverUsersId = intval($userRow['usersId']); // Notifications.usersId 용

// 2) 중복 요청 검사
$checkQuery = "
    SELECT * FROM Friends
    WHERE (requesterId = $requesterId AND receiverId = $receiverId)
       OR (requesterId = $receiverId AND receiverId = $requesterId)
";
$checkResult = $conn->query($checkQuery);

if ($checkResult->num_rows > 0) {
    echo json_encode(["error" => "already_exists"]);
    exit;
}

// 3) 친구 요청 생성
$insertQuery = $conn->prepare("
    INSERT INTO Friends (requesterId, receiverId, friendStatus, createdAt, updatedAt)
    VALUES (?, ?, 1, NOW(), NOW())
");
$insertQuery->bind_param("ii", $requesterId, $receiverId);

if (!$insertQuery->execute()) {
    echo json_encode(["error" => "insert_fail"]);
    exit;
}

// 4) 알림 생성
$notifSql = $conn->prepare("
    INSERT INTO Notifications (title, content, isRead, notificationTypesId, usersId)
    VALUES ('친구 요청', '새로운 친구 요청이 왔습니다!', 0, 2, ?)
");
$notifSql->bind_param("i", $receiverUsersId);

if (!$notifSql->execute()) {
    echo json_encode(["error" => "notif_fail", "detail" => $notifSql->error]);
    exit;
}

// 5) 성공 응답
echo json_encode(["status" => "success"]);

$conn->close();
?>
