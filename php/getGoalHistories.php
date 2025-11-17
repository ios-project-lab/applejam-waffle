<?php
// getGoals.php
// 25.11.17 편지 아이디 조회 추가 by kcw

// 1. 헤더 설정
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 

// 2. 데이터베이스 연결 설정 (getenv 사용 유지)
$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pw = getenv('DB_PASSWORD');
$dbName = getenv('DB_NAME');
// MySQL 연결
$conn = new mysqli($host, $user, $pw, $dbName);

// 연결 확인
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(array("error" => "Database Connection failed: " . $conn->connect_error)));
}

// 3. 사용자 ID (userId) 가져오기
$goal_id = isset($_GET['goalsId']) ? (int)$_GET['goalsId'] : 0;

if ($goal_id == 0) {
    http_response_code(400); // Bad Request
    die(json_encode(array("error" => "Required parameter 'goalsId' is missing or invalid.")));
}

// 히스토리 데이터 셋팅
$sql_history = "SELECT 
                    goalHistoryID,
                    content,
                    createadAt,
                    UpdatedAt,
                    goalsId,
                    lettersId
                FROM GoalHistories
                WHERE goalsId = ?";

$stmt = $conn->prepare($sql_history);
$stmt->bind_param("i", $goal_id);
$stmt->execute();
$result = $stmt->get_result();

$histories = array();

// 북마크 여부 확인
//$sql_bookmark 


// 5. 결과 처리 및 배열 저장
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        // 5-1. Swift의 GoalItem 구조체에 맞춰 배열에 저장
        $histories[] = array (
            'goalHistoriesId' => (int)$row['goalHistoryID'],
            'title' => $row['content'],
            'goalsId' => (int)$row['goalsId'],
            'lettersId' => (int)$row['lettersId'],
            'createdAt' => date('Y-m-d', strtotime($row['createadAt'])),
            'updatedAt' => !empty($row['UpdatedAt']) 
                ? date('Y-m-d', strtotime($row['UpdatedAt'])) 
                : null,
        );
    }
}


// 6. 최종 JSON 응답 출력
echo json_encode($histories);

// 7. 연결 종료
$stmt->close();
$conn->close();

?>