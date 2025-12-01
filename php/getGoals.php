<?php
// getGoals.php

// 헤더 설정
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 

// 데이터베이스 연결 설정
//$host = getenv('DB_HOST');
//$user = getenv('DB_USER');
//$pw = getenv('DB_PASSWORD');
//$dbName = getenv('DB_NAME');

include_once('./config.php');

// MySQL 연결
$conn = new mysqli($host, $user, $pw, $dbName);

// 연결 확인
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(array("error" => "Database Connection failed: " . $conn->connect_error)));
}

// 3. 사용자 ID (userId) 가져오기
$user_id = isset($_GET['userId']) ? (int)$_GET['userId'] : 0;

if ($user_id == 0) {
    http_response_code(400); // Bad Request
    die(json_encode(array("error" => "Required parameter 'userId' is missing or invalid.")));
}


$sql_category = "SELECT name FROM Categories WHERE categoriesId = ?";
$category_stmt = $conn->prepare($sql_category);

$sql_process = "SELECT sum(progressRate) as totalProgress FROM GoalHistories WHERE goalsId = ?";
$process_stmt = $conn->prepare($sql_process);
// 목표 데이터 조회 (SQL Injection 방지를 위해 PreparedStatement 사용)
$sql = "SELECT 
            goalsId, 
            title, 
            deadLine, 
            createdAt, 
            categoriesId
            -- description,   -- GoalItem 구조체와 일치하도록 컬럼 추가 가정
            -- progress,      -- GoalItem 구조체와 일치하도록 컬럼 추가 가정
            -- completed      -- GoalItem 구조체와 일치하도록 컬럼 추가 가정
        FROM Goals 
        WHERE usersId = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$goals = array();

// 결과 처리 및 배열 저장
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        
        $category_name = "미분류"; // 기본값
        
        // 카테고리 이름 조회 로직
        $category_stmt->bind_param("i", $row['categoriesId']); 
        $category_stmt->execute();
        $category_result = $category_stmt->get_result();
        
        if ($category_row = $category_result->fetch_assoc()) {
            $category_name = $category_row['name'];
        }
        // 프로세스 계산
        $process_stmt->bind_param("i", $row['goalsId']);
        $process_stmt->execute();
        $process_result = $process_stmt->get_result();

        if ($process_row = $process_result->fetch_assoc()) {
            $total_progress = $process_row['totalProgress'];
        }

        // completed 계산
        $completed = ($total_progress >= 100) ? true : false;


        // Swift의 GoalItem 구조체에 맞춰 배열에 저장
        $goals[] = array(
            'goalsId' => (int)$row['goalsId'],
            'title' => $row['title'],
            'category' => $category_name, // 조회된 카테고리 이름 사용
            'categoriesId' => (int)$row['categoriesId'],
            'description' => "데이터 없음 -- 논의 필요", // DB 컬럼이 없는 경우 대비
            // createdAt을 creationDate로 매핑하고 "yyyy-MM-dd" 형식으로 변환
            'creationDate' => date('Y-m-d', strtotime($row['createdAt'])), 
            'deadLine' => date('Y-m-d', strtotime($row['deadLine'])), 
            'progress' => (int)$total_progress,
            'completed' => $completed
        );
    }
}

// JSON 응답 출력
echo json_encode($goals);

// 연결 종료
$stmt->close();
$category_stmt->close();
$process_stmt->close();
$conn->close();

?>
