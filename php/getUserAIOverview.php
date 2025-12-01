<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include_once('./config.php');
$conn = new mysqli($host, $user, $pw, $dbName);

$userId = $_GET['userId'] ?? 0;

$sql = "
SELECT aiCheering
FROM Letters
WHERE senderId = ?
ORDER BY createdAt DESC
LIMIT 1
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
$stmt->execute();
$result = $stmt->get_result();

$response = ["aiCheering" => null];

if ($row = $result->fetch_assoc()) {
    $response["aiCheering"] = $row["aiCheering"];
}

echo json_encode($response);
?>

