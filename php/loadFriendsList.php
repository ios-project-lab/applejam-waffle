<?php
// loadFriendsList.php

// 1. 헤더 설정
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 

// 2. 데이터베이스 연결 설정 (getenv 사용 유지)
include_once('./config.php');
// MySQL 연결
$conn = new mysqli($host, $user, $pw, $dbName);

// 연결 확인
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(array("error" => "Database Connection failed: " . $conn->connect_error)));
}

// 3. 사용자 ID (userId) 가져오기
$users_id = isset($_GET['usersId']) ? (int)$_GET['usersId'] : 0;

if ($users_id == 0) {
    http_response_code(400); // Bad Request
    die(json_encode(array("error" => "Required parameter 'userId' is missing or invalid.")));
}

// 친구 데이터 셋팅
$sql_base = "SELECT 
                    friendsId,
                    createdAt,
                    updatedAt,
                    f.friendStatus,
                    s.name as friendStatusName,
                    requesterId,
                    receiverId
                FROM Friends f
                JOIN FriendStatus s ON f.friendStatus = s.friendStatusId
                WHERE requesterId = ? and friendStatus = 2";

$stmt = $conn->prepare($sql_base);
$stmt->bind_param("i", $users_id);
$stmt->execute();
$result = $stmt->get_result();

$friends = array();

// 친구 닉네임 가져오기
$sql_user = "SELECT nickName FROM Users WHERE usersId = ?";
$stmt_user = $conn->prepare($sql_user);

// 5. 결과 처리 및 배열 저장
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {

        $user_nickName = "모름"; // 기본값
        // 5-1. Swift의 구조체에 맞춰 배열에 저장
        $stmt_user->bind_param("i", $row['receiverId']);
        $stmt_user->execute();
        $user_result = $stmt_user->get_result();

        if ($user_row = $user_result->fetch_assoc()) {
            $user_nickName = $user_row['nickName'];
        }


        $friends[] = array (
            'friendsId' => (int)$row['friendsId'],
            'receiverId' => (int)$row['receiverId'],
            'nickName' => $user_nickName ? $user_nickName : '-1',
            'friendStatusName' => (String)$row['friendStatusName'],
            'createdAt' => date('Y-m-d', strtotime($row['createdAt'])),
            'isBlocked' => false,
            'updatedAt' => !empty($row['updatedAt']) 
                ? date('Y-m-d', strtotime($row['updatedAt'])) 
                : null,
                
        );
    }
}


// 6. 최종 JSON 응답 출력
echo json_encode($friends);

// 7. 연결 종료
$stmt->close();
$stmt_user->close();
$conn->close();
?>