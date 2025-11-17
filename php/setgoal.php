<?php
// DB 접속 정보 (환경 변수 사용)
$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pw = getenv('DB_PASSWORD');
$dbName = getenv('DB_NAME');

// 응답 헤더 설정
header('Content-Type: application/json');

// 데이터베이스 연결
$conn = new mysqli($host, $user, $pw, $dbName);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection failed: " . $conn->connect_error]);
    exit();
}

// 1. POST 데이터 받기
// Swift에서 보낸 POST 키 이름을 사용
$usersId = $_POST['usersId'] ?? 0;        // Swift에서 보낸 usersId (PK)
$title = $_POST['title'] ?? '';
$deadLine = $_POST['dueDate'] ?? '';
$categoryId = $_POST['categoryId'] ?? 0; 

// 입력값 검증 (필요한 경우 추가)
if (empty($title) || $usersId == 0 || $categoryId == 0) {
    echo json_encode(["error" => "필수 입력 항목(제목, 사용자 ID, 카테고리)이 누락되었습니다."]);
    $conn->close();
    exit();
}

// 2. 안전한 삽입: PreparedStatement 사용
// deadLine, usersId, categoriesId는 DB에서 숫자/날짜 타입일 경우 ?는 따옴표가 필요 없습니다.
$sql = "INSERT INTO Goals (title, deadLine, createdAt, categoriesId, usersId)
        VALUES (?, ?, NOW(), ?, ?)";

$stmt = $conn->prepare($sql);

// 변수 바인딩: s=string, i=integer
// (title: string, deadLine: string, categoriesId: integer, usersId: integer)로 가정
$stmt->bind_param("ssii", $title, $deadLine, $categoryId, $usersId);

if ($stmt->execute()) {
    echo json_encode(["success" => "목표가 성공적으로 저장되었습니다."]);
} else {
    echo json_encode(["error" => "데이터베이스 저장 실패: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>