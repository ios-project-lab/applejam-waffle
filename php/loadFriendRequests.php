<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 
include_once('./config.php');
// MySQL 연결
$conn = new mysqli($host, $user, $pw, $dbName);

$currentUserId = $_GET['currentUserId'];

if (!$currentUserId) {
    echo json_encode(["error" => "missing_params"]);
    exit;
}

// 1) 받은 요청
$receivedQuery = "
SELECT f.friendsId, f.requesterId, f.receiverId, f.friendStatus, u.nickName AS requesterNick
FROM Friends f
JOIN Users u ON f.requesterId = u.usersId
WHERE f.receiverId = ? AND f.friendStatus = '1'
";

$stmt = $conn->prepare($receivedQuery);
$stmt->bind_param("i", $currentUserId);
$stmt->execute();
$receivedResult = $stmt->get_result();
$received = [];
while ($row = $receivedResult->fetch_assoc()) {
    $received[] = $row;
}

// 2) 보낸 요청
$sentQuery = "
SELECT f.friendsId, f.requesterId, f.receiverId, f.friendStatus, u.nickName AS receiverNick
FROM Friends f
JOIN Users u ON f.receiverId = u.usersId
WHERE f.requesterId = ? AND f.friendStatus = '1'
";

$stmt = $conn->prepare($sentQuery);
$stmt->bind_param("i", $currentUserId);
$stmt->execute();
$sentResult = $stmt->get_result();
$sent = [];
while ($row = $sentResult->fetch_assoc()) {
    $sent[] = $row;
}

// 3) 응답 JSON
echo json_encode([
    "received" => $received,
    "sent" => $sent
]);

$stmt->close();
$conn->close();
?>
