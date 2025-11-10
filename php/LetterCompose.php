<?php
    $host = getenv('DB_HOST');
    $user = getenv('DB_USER');
    $pw = getenv('DB_PASSWORD');
    $dbName = getenv('DB_NAME');

    $conn = new mysqli($host, $user, $pw, $dbName);

    if ($conn->connect_error) {
        die("error: Connection failed: " . $conn->connect_error);
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        
        if (!empty($_POST)) {
            
            $to = $conn->real_escape_string($_POST['to'] ?? '');
            $subject = $conn->real_escape_string($_POST['subject'] ?? '');
            $bodyText = $conn->real_escape_string($_POST['bodyText'] ?? '');
            $from = $conn->real_escape_string($_POST['from'] ?? '');
            $receiveDate_raw = $_POST['receiveDate'] ?? '';
            
            $expected_arrive_time = null;
            if (!empty($receiveDate_raw)) {
                $date_parts = explode(' ', $receiveDate_raw);
                $expected_arrive_time = $conn->real_escape_string($date_parts[0] . ' ' . $date_parts[1]);
            }

            $createdAt = now();
            $updatedAt = $createdAt;
            $isLocked = 0;
            $isRead = 0;
            $isCheering = 0;
            $receiverType = 1;
            $arrivedType = 1;
            $emotionsId = 'NULL';
            $goalsHistorieId = 'NULL';
            $parentLetterId = 'NULL';

            $sql = "INSERT INTO Letters (
                        title, content, senderId, receiverId, expectedArrivalTime, 
                        createdAt, updatedAt, isLocked, isRead, isCheering, 
                        receiverType, arrivedType, emotionsId, goalsHistorieId, parentLetterId
                    )  
                    VALUES (
                        '$subject', '$bodyText', '$from', '$to', " . ($expected_arrive_time ? "'$expected_arrive_time'" : "NULL") . ", 
                        '$createdAt', '$updatedAt', '$isLocked', '$isRead', '$isCheering', 
                        '$receiverType', '$arrivedType', $emotionsId, $goalsHistorieId, $parentLetterId
                    )";

            if ($conn->query($sql) === TRUE) {
                echo "success: New letter created successfully";
            } else {
                http_response_code(500);
                echo "error: " . $sql . "<br>" . $conn->error;
            }
            
        } else {
            http_response_code(400);
            echo "error: Missing required POST parameters.";
        }
    } else {
        http_response_code(405);
        echo "error: Invalid request method. Use POST.";
    }

    $conn->close();

?>
