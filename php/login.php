<?php
session_start(); // 세션 시작

// DB 접속 정보
$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pw = getenv('DB_PASSWORD');
$dbName = getenv('DB_NAME');

// POST 데이터 받기
$id = $_POST['id'] ?? '';
$pwd = $_POST['pwd'] ?? '';

// DB 연결
$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["message" => "DB 연결 실패"]);
    exit;
}

// id, pwd 존재 확인
if (!$id || !$pwd) {
    http_response_code(400);
    echo json_encode(["message" => "아이디와 비밀번호를 입력해주세요."]);
    exit;
}

// SQL 조회
$stmt = $conn->prepare("SELECT * FROM Users WHERE id = ?");
$stmt->bind_param("s", $id);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if ($user && password_verify($pwd, $user['password'])) {
    // 로그인 성공
    $_SESSION['users_id'] = $user['usersId']; // users_id → usersId
    $_SESSION['user_id'] = $user['id'];
    $_SESSION['nickName'] = $user['nickName'];

    http_response_code(200);
    echo json_encode([
        "usersId" => $user['usersId'],
        "id" => $user['id'],
        "nickName" => $user['nickName']
    ]);
} else {
    // 로그인 실패
    http_response_code(400);
    echo json_encode(["message" => "아이디 또는 비밀번호가 잘못되었습니다."]);
}

$stmt->close();
$conn->close();
?>
