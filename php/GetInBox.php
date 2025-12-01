<?php
// getInbox.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
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

include_once('./config.php');

$conn = new mysqli($host, $user, $pw, $dbName);
$conn->set_charset("utf8");

if ($conn->connect_error) {
    die(json_encode(["error" => "DB Connection failed: " . $conn->connect_error]));
}

$userId = $_GET["userId"] ?? "";
if ($userId === "") { echo json_encode(["error" => "missing userId"]); exit; }
$userEsc = intval($userId);

$sql = "SELECT 
            L.lettersId, 
            L.senderId, 
            L.receiverId, 
            L.title, 
            L.content, 
            L.expectedArrivalTime, 
            L.isRead, 
            L.parentLettersId, 
            L.isLocked,
            L.createdAt,
            IFNULL(U.nickName, '알수없음') as senderNickName,
            IFNULL(U.id, '') as senderUserId,
            (SELECT COUNT(*) FROM Letters WHERE parentLettersId = L.lettersId) as replyCount
        FROM Letters L 
        LEFT JOIN Users U ON L.senderId = U.usersId 
        WHERE (L.receiverId = $userEsc OR L.senderId = $userEsc) 
        ORDER BY L.expectedArrivalTime DESC";

$result = $conn->query($sql);
$list = array();

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $row['lettersId'] = (int)$row['lettersId'];
        $row['senderId'] = (int)$row['senderId'];
        $row['receiverId'] = (int)$row['receiverId'];
        $row['isRead'] = (int)$row['isRead'];
        $row['parentLettersId'] = (int)$row['parentLettersId'];
        $row['isLocked'] = (int)$row['isLocked'];
        $row['replyCount'] = (int)$row['replyCount'];
        
        $list[] = $row;
    }
}

echo json_encode($list, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
$conn->close();
?>
