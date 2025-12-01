<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include_once('./config.php');

$conn = new mysqli($host, $user, $pw, $dbName);

$userId = $_GET['userId'] ?? 0;

$sql = "
SELECT DATE(createdAt) AS date,
       AVG(JSON_EXTRACT(aiCheering, '$.sentiment_analysis.score')) AS score
FROM Letters
WHERE senderId = ?
GROUP BY DATE(createdAt)
ORDER BY date ASC
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
$stmt->execute();

$result = $stmt->get_result();
$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = [
        "date" => $row["date"],
        "score" => floatval($row["score"])
    ];
}

echo json_encode($data);

$stmt->close();
$conn->close();
?>

