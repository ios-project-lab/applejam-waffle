<?php
	echo "Future Letter - 와플에 애플잼";
        
    include_once(./config.php);

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

