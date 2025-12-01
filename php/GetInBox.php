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

include_once(./config.php);

$conn = new mysqli($host, $user, $pw, $dbName);
$conn->set_charset("utf8");

if ($conn->connect_error) {
    die(json_encode(["error" => "DB Connection failed: " . $conn->connect_error]));
}


$userId = isset($_GET['userId']) ? (int)$_GET['userId'] : 0;

if ($userId == 0) {
    echo json_encode([]);
    exit;
}

$sql = "
    SELECT 
        L.lettersId,
        L.title,
        L.content,
        
        -- 보낸 사람 정보 (S)
        L.senderId,
        S.nickName AS senderNickName, 
        S.id AS senderUserId,
        
        -- 받는 사람 정보 (R)
        L.receiverId,
        R.nickName AS receiverNickName,
        
        L.expectedArrivalTime,
        L.isRead,
        L.isLocked,
        L.parentLettersId,
        
        -- 답장 개수 계산
        (SELECT COUNT(*) FROM Letters WHERE parentLettersId = L.lettersId) AS replyCount,
        
        -- goalId가 없을 경우를 대비해 NULL 처리
        NULL AS goalId
        
    FROM Letters L
    LEFT JOIN users S ON L.senderId = S.usersId
    LEFT JOIN users R ON L.receiverId = R.usersId
    WHERE L.receiverId = $userId OR L.senderId = $userId
    ORDER BY L.expectedArrivalTime DESC
";

$result = mysqli_query($conn, $sql);
$response = array();

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $row['lettersId'] = (int)$row['lettersId'];
        $row['senderId'] = (int)$row['senderId'];
        $row['receiverId'] = (int)$row['receiverId'];
        $row['isRead'] = (int)$row['isRead'];
        $row['isLocked'] = (int)$row['isLocked'];
        $row['parentLettersId'] = (int)$row['parentLettersId'];
        $row['replyCount'] = (int)$row['replyCount'];
        $row['goalId'] = null;

        array_push($response, $row);
    }
}

header('Content-Type: application/json; charset=utf-8');
echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

mysqli_close($conn);
?>
