<?php
	echo "Future Letter - 와플에 애플잼";
        
	$host = getenv('DB_HOST');
	$user = getenv('DB_USER');
	$pw = getenv('DB_PASSWORD');
	$dbName = getenv('DB_NAME');
	
	$conn = new mysqli($host, $user, $pw, $dbName);

 	if(!$conn){
		echo "-1";
		return;
	}

 	$sql = "select * from Users;";
	$result = mysqli_query($conn, $sql);

	while($row = mysqli_fetch_array($result)){
		echo $row['nickName'];
		echo "<br>";
	}

	mysqli_close($conn);
?>

