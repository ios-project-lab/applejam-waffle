<?php
// DB 접속 정보
$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pw = getenv('DB_PASSWORD');
$dbName = getenv('DB_NAME');

// POST 데이터 받기
$id = $_POST['id'] ?? '';
$pwd = $_POST['pwd'] ?? '';
$displayName = $_POST['displayName'] ?? '';
$birthday = $_POST['birthday'] ?? '';
$gender = $_POST['gender'] ?? '';
// gender가 "남성" 같은 문자열로 들어온다면 숫자로 변환
switch($gender) {
    case "남성":
        $gender = 0;
        break;
    case "여성":
        $gender = 1;
        break;
    default:
        $gender = 2; // 모름
}

// 비밀번호 암호화
$hashedPwd = password_hash($pwd, PASSWORD_DEFAULT);

// DB 연결
$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// SQL 삽입
$stmt = $conn->prepare("
    INSERT INTO Users (id, password, nickName, birthDay, gender, status, profileImage, createdAt)
    VALUES (?, ?, ?, ?, ?, 0, NULL, NOW())
");
$stmt->bind_param("sssss", $id, $hashedPwd, $displayName, $birthday, $gender);

if ($stmt->execute()) {
    echo "회원가입 성공";
} else {
    echo "회원가입 실패: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>

