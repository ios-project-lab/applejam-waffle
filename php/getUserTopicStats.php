<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include_once('./config.php');

$conn = new mysqli($host, $user, $pw, $dbName);

$userId = $_GET['userId'] ?? 0;

$sql = "
SELECT 
    JSON_EXTRACT(aiCheering, '$.sentiment_analysis.sentiment') AS sentiment,
    COUNT(*) AS count
FROM Letters
WHERE senderId = ?
GROUP BY sentiment
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
$stmt->execute();
$result = $stmt->get_result();

$response = [];

while ($row = $result->fetch_assoc()) {
    $response[] = [
        "sentiment" => trim($row["sentiment"], '"'),
        "count" => intval($row["count"])
    ];
}

echo json_encode($response);
?>

