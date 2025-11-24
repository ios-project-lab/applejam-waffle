<?php
// getGoals.php

// 헤더 설정
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 

// 데이터베이스 연결
//$host = getenv('DB_HOST');
//$user = getenv('DB_USER');
//$pw = getenv('DB_PASSWORD');
//$dbName = getenv('DB_NAME');

include_once(./config.php);

// MySQL 연결
$conn = new mysqli($host, $user, $pw, $dbName);

// 연결 확인
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(array("error" => "Database Connection failed: " . $conn->connect_error)));
}

// 사용자 ID (userId) 가져오기
$user_id = isset($_GET['userId']) ? (int)$_GET['userId'] : 0;
$letter_id = isset($_GET['letterId']) ? (int)$_GET['letterId'] : 0;

if ($user_id == 0) {
    http_response_code(400); // Bad Request
    die(json_encode(array("error" => "Required parameter 'userId' is missing or invalid.")));
}

if ($letter_id == 0) {
    http_response_code(400); // Bad Request
    die(json_encode(array("error" => "Required parameter 'letterId' is missing or invalid.")));
}

// 목표 데이터 조회 (SQL Injection 방지를 위해 PreparedStatement 사용)
$sql = "SELECT 
            lettersId,
            title, 
            content,
            createdAt,
            updatedAt,
            expectedArrivalTime,
            isLocked,
            receiverType,
            isRead,
            aiCheering,
            senderId,
            receiverId,
            arrivedType,
            emotionsId,
            parentLettersId
        FROM Letters 
        WHERE lettersId = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $letter_id);
$stmt->execute();
$result = $stmt->get_result();

$response = array();

// 결과 처리 및 배열 저장
while($row = $result->fetch_assoc()) {

    $response[] = [
        "lettersId" => (int)$row['lettersId'],
        "title" => $row['title'],
        "content" => $row['content'],
        "createdAt" => date('Y-m-d', strtotime($row['createdAt'])),
        "updatedAt" => !empty($row['updatedAt']) ? date('Y-m-d', strtotime($row['updatedAt'])) : null,
        "expectedArrivalTime" => !empty($row['expectedArrivalTime']) ? date('Y-m-d', strtotime($row['expectedArrivalTime'])) : null,
        "isLocked" => (int)$row['isLocked'],
        "receiverType" => (int)$row['receiverType'],
        "isRead" => (int)$row['isRead'],
        "aiCheering" => $row['aiCheering'],
        "senderId" => (int)$row['senderId'],
        "receiverId" => (int)$row['receiverId'],
        "arrivedType" => (int)$row['arrivedType'],
        "emotionsId" => (int)$row['emotionsId'],
        "parentLettersId" => (int)$row['parentLettersId']
    ];
}

// JSON 응답 출력
echo json_encode($response);

// 연결 종료
$stmt->close();
$conn->close();

?>
