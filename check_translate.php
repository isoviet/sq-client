<?php
$trashFileName = "Trash.txt";
$translateFileName = "ToTranslate.txt";
$enFileName = ".\content\\en\\en.lp";

$exceptions = array("","Выполняется загрузка");

$pathList = array(".\src");

$fileList = array();
foreach ($pathList as $path)
	$fileList = array_merge($fileList, scan($path));

$filterList = array_unique(cleaner($fileList));

$string  = file_get_contents($enFileName);
$fileText = explode("\n", $string);

$newLocale = search($filterList, $fileText);

file_put_contents($enFileName, implode("\n", array_unique($newLocale)));

function cleaner($fileList)
{
	$rusText = array();
	foreach($fileList as $f)
	{
		$text = file_get_contents($f);

		if (!preg_match_all("/gls\(\"(.+)\"/U", $text, $rusLines))
			continue;

		foreach($rusLines[1] as $str)
			array_push($rusText, $str);
	}

	return $rusText;
}

function scan($path)
{
	$fileList = scandir($path);

	$filterList = array();
	foreach($fileList as $f)
	{
		if (!preg_match_all("/\.as/", $f))
		{
			if (($f == ".") || ($f == ".."))
				continue;
			if (is_dir($path."\\".$f))
				$filterList = array_merge($filterList, scan($path."\\".$f));
		}

		array_push($filterList, $path."\\".$f);
	}

	return $filterList;
}

function search($codeText, $localeText)
{
	$trash = fopen($GLOBALS['trashFileName'], "a");
	$translate = fopen($GLOBALS['translateFileName'], "w");

	$russian = array();
	$other = array();
	while (list(, $val) = each($localeText))
	{
		list($rus, $oth) = explode("\t", $val);
		array_push($russian, $rus);
		array_push($other, $oth);
	}

	array_unshift($russian, "");
	foreach ($codeText as $line)
	{
		if (!array_search($line, $russian) && !array_search($line, $GLOBALS['exceptions'])) 
		{	
			fwrite($translate, $line."\n");
			continue;
		}
	}
	array_shift($russian);

	array_unshift($codeText, "");
	$newLocale = array();
	for ($i = 0; $i <= count($russian); $i++)
	{
		if (!array_search($russian[$i], $codeText) && !array_search($line, $GLOBALS['exceptions'])) 
		{	
			fwrite($trash, $russian[$i]."\t".$other[$i]."\n");
			continue;
		}

		array_push($newLocale, $russian[$i]."\t".$other[$i]);
	}

	fclose($trash);
	fclose($translate);

	file_put_contents($GLOBALS['trashFileName'], array_unique(file($GLOBALS['trashFileName'])));

	return $newLocale;
}
?>