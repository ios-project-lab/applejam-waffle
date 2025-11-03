<?php
    $host = 'localhost';
    $user = 'root';
    $pw = '0000';
    $dbName = 'FutereMe';
    $tableName = 'Goals';

    $conn = new mysqli($host, $user, $pw, $dbName);

    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $goal_title = isset($_POST['title']) ? $_POST['title'] : '';
    $goal_description = isset($_POST['description']) ? $_POST['description'] : '';
    $goal_due_date = isset($_POST['dueDate']) ? $_POST['dueDate'] : '';

    $stmt = $conn->prepare("INSERT INTO $tableName (title, description, dueDate, categoryID) VALUES (?, ?, ?, 1)");
    
    if ($stmt) {
        $stmt->bind_param("sss", $goal_title, $goal_description, $goal_due_date); 

        if ($stmt->execute()) {
            echo "success";
        } else {
            echo "Error executing query: " . $stmt->error;
        }

        $stmt->close();
    } else {
        echo "Error preparing statement: " . $conn->error;
    }

    $conn->close();
?>