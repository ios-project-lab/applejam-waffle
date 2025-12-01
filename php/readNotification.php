<?php
include_once('./config.php');

header("Content-Type: application/json");

$notificationsId = $_POST['notificationsId'] ?? 0;

$conn = new mysqli($host, $user, $pw, $dbName);

$sql = "UPDATE Notifications SET isRead = 1 WHERE notificationsId = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $notificationsId);
$stmt->execute();

echo json_encode(["success" => true]);

$conn->close();
?>

