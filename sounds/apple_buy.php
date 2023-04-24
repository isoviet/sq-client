<?php

	define('STATUS_SUCCESS', 0);
	define('STATUS_ERROR', 1);

	define('ERROR_BAD_REQUEST', 1);
	define('ERROR_INVALID_RECEIPT', 2);
	define('ERROR_INVALID_KEY', 3);
	define('ERROR_REQUEST_ERROR', 4);
	define('ERROR_INVALID_BUYING', 5);
	define('ERROR_DATABASE', 6);


	define('VERIFY_URL', 'https://sandbox.itunes.apple.com/verifyReceipt');

	define('BUYINGS', array(
		"Coin4" => 4,
		"Coin20" => 20,
		"Coin60" => 60
	));

	require_once "defines.inc.php";

	header("Content-Type: application/json; encoding=utf-8");

	if (empty($_REQUEST['receipt-data']) || empty($_REQUEST['inner_id']))
		print_status(STATUS_ERROR, ERROR_BAD_REQUEST);
		
	$receipt_data = $_REQUEST['receipt-data'];
	$type = $_REQUEST['type'];
	$net_id = $_REQUEST['net_id'];
	$key = $_REQUEST['key'];	

	$receipt = verify_receipt($receipt_data, $type, $net_id, $key);

	$product_id = $receipt['product_id'];
	$transaction_id = $receipt['original_transaction_id'];
	$transaction_date = $receipt['original_purchase_date'];

	if (!in_array(BUYINGS, $product_id))
		print_status(STATUS_ERROR, ERROR_INVALID_BUYING);

	$sql = new mysqli(DATABASE_HOST, DATABASE_USER, DATABASE_PASSWORD, DATABASE_NAME);
	//обработка sql
	$result = $sql->query("SELECT transaction_id FROM orders_apple WHERE transaction_id = '{$transaction_id}' LIMIT 1");
	$row = $result->fetch_assoc();
	if ($row)
		print_status(STATUS_SUCCESS, array('order_id' => $transaction_id, 'app_order_id' => $row['transaction_id']));

	$sql->query("INSERT INTO orders_apple SET transaction_id = '{$transaction_id}', type = '{$type}', net_id = '{$inner_id}', time = UNIX_TIMESTAMP(), amount = '".BUYINGS[$product_id]."'");
	if ($sql->affected_rows != 1)
		print_status(STATUS_ERROR, ERROR_DATABASE, $sql);

	print_status(STATUS_SUCCESS, $receipt_data);


	print_status(STATUS_SUCCESS, $receipt);
 
	function verify_receipt($receipt, $type, $net_id, $key)
	{
		$response = json_decode(send_post($receipt), true);

		if ($response['status'] != 0)
			print_status(STATUS_ERROR, ERROR_INVALID_RECEIPT);

		$transaction_id = $response['receipt']['transaction_id'];
		$current_key = md5($transaction_id . strval($type) . strval($net_id));

		if (strcasecmp($current_key, $key) != 0)
			print_status(STATUS_ERROR, ERROR_INVALID_KEY);

		return $response['receipt'];
	}

	function send_post($receipt)
	{
		$context = stream_context_create(array(
			'https' => array(
				'method' => 'POST',
				'header' => 'Content-Type: application/x-www-form-urlencoded' . PHP_EOL,
				'content' => $receipt
			),
			'http' => array(
				'method' => 'POST',
				'header' => 'Content-Type: application/x-www-form-urlencoded' . PHP_EOL,
				'content' => $receipt
			)
		));

		$result = file_get_contents(
			$file = VERIFY_URL,
			$use_include_path = false,
			$context
		);

		if ($result === false)
			print_status(STATUS_ERROR, ERROR_REQUEST_ERROR);

		return $result;
	}

	function print_status($status, $code, $sql = null)
	{
		if ($status == STATUS_SUCCESS)
		{
			echo json_encode(array('response' => $code));
			exit;
		}

		ob_start();
		print_r($_POST);
		if ($sql != null)
			echo $sql->errno.", ".$sql->error."\n";
		file_put_contents("buy_apple.log", $status.",".$code.":\n".ob_get_contents()."\n\n", FILE_APPEND);
		ob_end_clean();

		echo json_encode(array('error' => $code));
		exit;
	}
?>