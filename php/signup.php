<?php
// signup.php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: text/plain; charset=utf-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}


// DB 접속 정보
include_once('./config.php');

// POST 데이터 받기
$id = $_POST['id'] ?? '';
$pwd = $_POST['pwd'] ?? '';
$displayName = $_POST['displayName'] ?? '';
$birthday = $_POST['birthday'] ?? '';
$genderInput = $_POST['gender'] ?? '';
$gender = 2;
if ($genderInput === "남성") $gender = 0;
elseif ($genderInput === "여성") $gender = 1;

// DB 연결
$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
$conn->set_charset("utf8");

$sql = "INSERT INTO Users (id, password, nickName, birthDay, gender, userStatus, profileImage, createdAt) VALUES (?, ?, ?, ?, ?, 0, NULL, NOW())";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo "Prepare failed: (" . $conn->errno . ") " . $conn->error;
    exit;
}

$stmt->bind_param("ssssi", $id, $pwd, $displayName, $birthday, $gender);

if ($stmt->execute()) {
    echo "회원가입 성공";
} else {
    echo "회원가입 실패: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>
