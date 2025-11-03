<?php
    echo "Future Letter - 와플에 애플잼";

    $host = 'localhost';
    $user = 'WaffleApple';
    $pw = '0000';
    $dbName = 'FutureMe';

    $conn = new mysqli($host, $user, $pw, $dbName);

    if ($conn) {
        echo "-1";
        return;
    }

    $sql = "select * from Letters;";
    $result = mysqli_query($conn, $sql);

    while($row = mysqli_fetch_array($result)) {
        $letter = $row['letter'];
        echo $letter;
    }

    mysqli_close($conn);
?>