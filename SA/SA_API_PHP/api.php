<?php
	include 'methods.php';
	setlocale(LC_ALL, 'ru_RU.CP1251', 'rus_RUS.CP1251', 'Russian_Russia.1251');
	$input = $_GET;

	$method = $input['method'];
	
	switch ($method)
	{
		case 'auth': auth($input['email'], $input['passwd']); break;
		case 'getProfiles': echo "{'response': [".getUserInfo($input['id'])."]}"; break;
		case 'getAppList': getAppList(); break;
		case 'getAppInfo': getAppInfo($input['id'], $input['appId']); break;
		case 'getUserBalance': getBalance($input['id'], $input['appId'], $input['sig']); break;
		case 'setUserInfo': setUserInfo($input['id'], $input['fName'], $input['sName'] , $input['photoUrl'], $input['gender'], $input['birthDate'], $input['sig']); break;
		case 'changePasswd': changePasswd($input['id'], $input['old'], $input['new']); break;

		case 'getFriends': echo "{'response':''}"; break;
		case 'getAppUsers': echo "{'response':''}"; break;

		case 'register': register($input['email'], $input['passwd']); break;
		case 'confirmReg': confirmReg($input['key']); break;

		case 'recover': recoverRequest($input['email'], $input['passwd']); break;
		case 'confirmRecover': confirmRecover($input['email'], $input['key']); break;
	}
?>