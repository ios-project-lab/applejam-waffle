<?php
header('Content-Type: application/json');

// DB 연결
include_once('./config.php');
$conn = new mysqli($host, $user, $pw, $dbName);
$conn->set_charset("utf8");

$data = json_decode(file_get_contents("php://input"), true);

$usersId = $data['usersId'];
$nickName = $data['nickName'];
$password = $data['password'];
$profileImage = $data['profileImage'];

$sql = "
UPDATE Users 
SET 
    nickName = ?, 
    password = ?, 
    profileImage = ?, 
    updatedAt = NOW()
WHERE usersId = ?
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("sssi", $nickName, $password, $profileImage, $usersId);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Update failed"
    ]);
}

$stmt->close();
$conn->close();
?>

