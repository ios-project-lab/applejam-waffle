<?php
include_once('./config.php');

header("Content-Type: application/json");

$title = $_POST['title'] ?? '';
$content = $_POST['content'] ?? '';
$usersId = $_POST['usersId'] ?? 0;
$notificationTypesId = $_POST['notificationTypesId'] ?? 0;

if (!$usersId || !$notificationTypesId || empty($title)) {
    echo json_encode(["error" => "Missing required fields"]);
    exit;
}

$conn = new mysqli($host, $user, $pw, $dbName);

$sql = "INSERT INTO Notifications 
(title, content, isRead, createdAt, notificationTypesId, usersId)
VALUES (?, ?, 0, NOW(), ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ssii", $title, $content, $notificationTypesId, $usersId);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

$conn->close();
?>

