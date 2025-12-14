<?php
include_once('./config.php');

header("Content-Type: application/json");

$usersId = $_GET['usersId'] ?? 0;

$conn = new mysqli($host, $user, $pw, $dbName);

$sql = "
SELECT n.notificationsId, n.title, n.content, n.isRead, n.createdAt,
       n.notificationTypesId, t.code, t.name
FROM Notifications n
LEFT JOIN NotificationType t ON n.notificationTypesId = t.notificationTypesId
WHERE n.usersId = ?
ORDER BY n.createdAt DESC
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $usersId);
$stmt->execute();
$result = $stmt->get_result();

$list = [];

while ($row = $result->fetch_assoc()) {
    $list[] = $row;
}

echo json_encode($list);
?>

