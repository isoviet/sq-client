<?php
function checkEmail($email)
{
	return preg_match("/^([a-z0-9_\.-]+)@([a-z0-9_\.-]+)\.([a-z\.]{2,6})$/", $email);
}
?>