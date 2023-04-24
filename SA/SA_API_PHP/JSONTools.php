<?php
	function rowToJSON($keys, $row)
	{
		$result = "{";
		for ($i = 0; $i < count($row); $i = $i + 1)
		{
			$result = $result."'$keys[$i]':'$row[$i]'";
			if ($i < count($row) - 1)
				$result = $result.",";
		}
		$result = $result."}";
		return $result;
	}

	function arrayToJSON($array)
	{
		$result = "[";
		for ($i = 0; $i < count($array); $i = $i + 1)
		{
			$result = $result.$array[$i];
			if ($i < count($array) - 1)
				$result = $result.",";
		}
		$result = $result."]";
		return $result;
	}
?>