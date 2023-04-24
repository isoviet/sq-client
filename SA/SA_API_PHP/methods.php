<?php
	include 'JSONTools.php';
	include 'EmailTools.php';
    ini_set('default_socket_timeout', 2);

	function connect()
	{
		$link = mysql_connect("localhost", "games.irg.com", "vvTan5QSJJH5Vns6")
			or die("Could not connect : " . mysql_error());
		mysql_select_db("itsrealgames_games") or die("Could not select database");
		
		$query = "set names 'utf8'";
		$result = mysql_query($query) or die("Query failed : " . mysql_error());
	}

	function getUserInfo($id)
	{
		settype($id, "integer");
		connect();
		$query = "SELECT id, firstName, secondName, photoURL, gender, birthDate FROM users WHERE id=$id";
		$result = mysql_query($query) or die("Query failed : " . mysql_error());

		$keys = Array('uid', 'first_name', 'last_name', 'photo_big', 'sex', 'birthDate');
		while ($row = mysql_fetch_row($result)) 
			return rowToJSON($keys, $row);
	}

	function getAppInfo($userId, $appid)
	{
		settype($appid, "integer");
		settype($userId, "integer");
		connect();
		$query = "SELECT id, name, thumburl, description, swfurl, secretkey FROM applications WHERE id=$appid";
		$result = mysql_query($query) or die("Query failed : " . mysql_error());

		if (mysql_num_rows($result) == 0)
		{
			echo "{'error':'App is not exists'}";
		}
		$keys = Array('id', 'name', 'thumburl', 'description', 'swfurl', 'authkey');
		while ($row = mysql_fetch_row($result)) 
		{
			$row[5] = md5($appid."_".$userId."_".$row[5]); 
			echo "{'response':".rowToJSON($keys, $row)."}";
		}
	}

	function getAppList()
	{
		connect();

		$query = "SELECT id FROM applications";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		$appList = Array();
		while ($row = mysql_fetch_row($result)) 
			array_push($appList, $row[0]);

		echo "{'response':'".arrayToJSON($appList)."'}";
	}

	function getBalance($userId, $appId, $sig)
	{
		settype($userId, "integer");
		settype($appId, "integer");
		connect();

		$query = "SELECT userbalance FROM appusers WHERE userId = $userId AND appid = $appId";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) == 0)
		{
			$query = "INSERT INTO appusers (
			`userid` ,
			`appid` ,
			`userbalance` ,
			`id` 
			)
			VALUES (
			$userId , $appId, 0, NULL
			); ";
			$result = mysql_query($query) or die("Query failed : ".mysql_error());
			echo getBalance($userId, $appId, $sig);
			return;
		}

		$appList = Array();
		while ($row = mysql_fetch_row($result)) 
			echo "{'response':'$row[0]'}";
	}

	function auth($email, $passwd)
	{
		connect();

		$email = addslashes($email);
		$passwd = addslashes($passwd);

		$query = "SELECT id, email FROM users WHERE email = '$email' AND passwd = '$passwd'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) != 1)
		{
			echo "{'response' : 'Login failed'}";
			return;
		}

		$row = mysql_fetch_row($result);
		$date = date("U");
		$sig = md5($date + $row[0] + $row[1]);

		$query = "UPDATE users SET sessionsig = '$sig', lastAuth = $date WHERE id =$row[0]";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		echo "{'response':{'id':$row[0], 'sig':'$sig'}}";
	}

	function setUserInfo($id, $fName, $sName, $photoUrl, $gender, $birthDate, $sig)
	{
		connect();

		settype($id, "integer");
		$fName = addslashes($fName);
		$sName = addslashes($sName);
		$photoUrl = addslashes($photoUrl);
		$birthDate = addslashes($birthDate);
		$sig = addslashes($sig);
		$gender = $gender == 'female';

		$query = "SELECT id FROM users WHERE id = $id AND sessionsig = '$sig'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) != 1)
		{
			echo false;
			return;
		}

		$query = "UPDATE users SET firstname = '$fName', secondname = '$sName', photourl = '$photoUrl', birthdate = '$birthDate', gender = '$gender' WHERE id = $id";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		echo "{'response':'saved'}";
	}

	function changePasswd($id, $oldPasswd, $newPasswd)
	{
		connect();

		settype($id, "integer");
		$oldPasswd = addslashes($oldPasswd);
		$newPasswd = addslashes($newPasswd);

		$query = "SELECT id FROM users WHERE id = $id AND passwd = '$oldPasswd'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) != 1)
		{
			echo "{'response':'Wrong password'}";;
			return;
		}

		$query = "UPDATE users SET passwd = '$newPasswd' WHERE id = $id";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		echo "{'response':'OK'}";
	}

	function sendMailRegister($email, $link)
	{
		$message = "<body>Для завершения регистрации перейдите по следующей ссылке: <br/> $link	</body>";

		$subject = "Регистрация учётной записи RealGames";
		$subject = '=?utf-8?B?'.base64_encode($subject).'?=';

		$header ="From: RealGames <noreply@itsrealgames.com>\r\n";
		$header.="Subject: $subject\r\n";
		$header.= "Content-type: text/html; charset=utf-8 \r\n";

		mail($email, $subject, $message, $header);
	}

	function register($email, $passwd)
	{
		if (!checkEmail($email))
		{
			echo "{'response': 'Email incorrect'}";
			return;
		}
		connect();

		$email = addslashes($email);
		$passwd = addslashes($passwd);

		$query = "SELECT email, passwd FROM users WHERE email = '$email'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) > 0)
		{
			echo "{'response': 'Email exists'}";
			return;
		}

		$query = "SELECT email, passwd FROM waitingusers WHERE email = '$email'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) > 0)
		{
			echo "{'response': 'Check Your email'}";
			return;
		}

		$key = md5(date("U") + $email + $passwd);
		$row = mysql_fetch_row($result);

		$query = "INSERT INTO waitingusers (
		`id` ,
		`email` ,
		`passwd` ,
		`regkey` 
		)
		VALUES (
		NULL , '$email', '$passwd', '$key'
		); ";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		sendMailRegister($email, "http://games.itsrealgames.com/api.php?method=confirmReg&key=$key");
		echo "{'response': 'OK', 'link':'http://games.itsrealgames.com/api.php?method=confirmReg&key=$key'}";
	}

	function confirmReg($key)
	{
		connect();

		$key = addslashes($key);

		$query = "SELECT email, passwd FROM waitingusers WHERE regkey = '$key'";

		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) != 1)
		{
			echo "Wrong key";
			return;
		}

		$row = mysql_fetch_row($result);
		$query = "INSERT INTO users (
			id ,
			firstname ,
			secondname ,
			photourl ,
			gender ,
			birthDate ,
			passwd ,
			regdate ,
			email ,
			lastauth ,
			sessionsig 
			)
			VALUES (
			NULL , '', '', '', '', '', '$row[1]', '', '$row[0]', 
			CURRENT_TIMESTAMP , ''
			)";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		$query = "DELETE FROM waitingusers WHERE regkey = '$key'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());
		echo "Confirmed";
	}

	function sendMailRecover($email, $link)
	{
		$message = 	"<body>Для завершения востановления пароля перейдите по следующей ссылке:\n
							$link<br/>
					< / body >";
		
		$subject = "Востановлени пароля учётной записи RealGames";
		$subject = '=?utf-8?B?'.base64_encode($subject).'?=';
		
		$header ="From: RealGames <noreply@itsrealgames.com>\r\n";
		$header.="Subject: $subject\r\n";
		$header.= "Content-type: text/html; charset=utf-8 \r\n";
		
		mail($email, $subject, $message	, $header);
	}

	function recoverRequest($email, $passwd)
	{
		if (!checkEmail($email))
		{
			echo "{'response': 'Email incorrect'}";
			return;
		}

		connect();

		$email = addslashes($email);
		$passwd = addslashes($passwd);

		$query = "SELECT id FROM users WHERE email = '$email'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) != 1)
		{
			echo "{'response': 'User not found'}";
			return;
		}

		$query = "SELECT id FROM passwdrecover WHERE email = '$email'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) != 0)
		{
			echo "{'response': 'Check your mail'}";
			return;
		}

		$key = md5(date("U"));
		$query = "INSERT INTO passwdrecover (
			`id` ,
			`passwd` ,
			`key` ,
			`email`
			)
			VALUES (
			null, '$passwd', '$key', '$email'
			)";

		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		sendMailRecover($email, "http://games.itsrealgames.com/api.php?method=confirmRecover&key=$key&email=$email");
		echo "{'response': 'OK', 'link':'http://games.itsrealgames.com/api.php?method=confirmRecover&key=$key&email=$email'}";
	}

	function confirmRecover($email, $key)
	{
		connect();

		$email = addslashes($email);
		$key = addslashes($key);

		$query = "SELECT passwd FROM passwdrecover WHERE email = '$email' AND passwdrecover.key = '$key'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		if (mysql_num_rows($result) != 1)
		{
			echo "Wrong key";
			return;
		}

		$row = mysql_fetch_row($result);
		$passwd = $row[0];

		$query = "DELETE FROM passwdrecover WHERE email = '$email' AND passwdrecover.key = '$key'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		$query = "UPDATE users SET passwd = '$passwd' WHERE email = '$email'";
		$result = mysql_query($query) or die("Query failed : ".mysql_error());

		echo "Your password successful changed";
	}
?>