<?php

class Updater
{
	const BOM = "﻿";

	private $files = array();
	private $pathes = array();

	public function update()
	{
		reset($this->files);
		while (list(, $file) = each($this->files))
			$this->collect_imports($file);

		reset($this->pathes);
		while (list(, $directory) = each($this->pathes))
			$this->parse_dir($directory, array(&$this, "collect_imports"));
	}

	public function add_file($file)
	{
		$this->files[] = $file;
	}

	public function add_path($path)
	{
		$this->pathes[] = $path;
	}

	private function collect_imports($source_file)
	{
		$source = file_get_contents($source_file);
		$orig_source = $source;

		$source = str_replace("\r", "", $source);

		$source = trim($source, self::BOM);
		$source = trim($source);
		$source = preg_replace("/[ \t]+\n/u", "\n", $source);

		$lines = explode("\n", $source);

		if (preg_match("/^package(?:\s+([a-zA-Z0-9_.]+))?$/u", $lines[0], $matches) == 0)
		{
			echo "File {$source_file} has no package\n";
			return;
		}

		if (count($matches) > 1)
			$package = trim($matches[1]);
		else
			$package = "";

		array_shift($lines);		// package
		array_shift($lines);		// {

		$found = array();
		$comment = false;
		$count = count($lines);

		for ($i = 0; $i < $count; $i++)
		{
			$line = trim($lines[$i]);

			if (strpos($line, "*/") === 0)
			{
				$comment = false;
				continue;
			}

			if ($comment)
				continue;

			if (strpos($line, "//") === 0)
				continue;
			if (strpos($line, "/*") === 0)
			{
				$comment = true;
				continue;
			}

			if ($line == "")
			{
				array_splice($lines, $i, 1);
				$count--;
				$i--;
				continue;
			}

			if (strpos($line, "import") !== 0)
			{
				if (empty($found))
					break;

				array_splice($lines, $i, 0, "");
				break;
			}

			if (preg_match("/^import\s+(.+);$/u", $line, $matches) == 0)
			{
				echo "File {$source_file} contains wrong import line {$line}\n";
				continue;
			}

			$found[] = trim($matches[1]);

			array_splice($lines, $i, 1);
			$count--;
			$i--;
		}

		$source = implode("\n", $lines);

		$imports = array();
		while (list(, $import) = each($found))
		{
			if (preg_match("/^[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)+$/ui", $import) == 0)
			{
				echo "File {$source_file} contains wrong import {$import}\n";
				return;
			}

			if (isset($imports[$import]))
			{
				echo "File {$source_file} imported {$import} twice\n";
				continue;
			}

			$imports[$import] = true;
		}

		$used = array();
		while (list($import, ) = each($imports))
		{
			preg_match("/^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$/i", $import, $matches);

			$import_full = str_replace(".", "\\.", $import);
			$import_base = trim($matches[1], ".");

			$is_function = (preg_match("/^[a-z]/u", $import_base) == 1);

			if (!$is_function && (
				preg_match("/[^a-zA-Z0-9_]{$import_base}\./u", $source) != 0 ||
				preg_match("/[^a-zA-Z0-9_]new\s+{$import_base}[^a-zA-Z0-9_]/u", $source) != 0 ||
				preg_match("/\s+(?:is|as|extends)\s+{$import_base}[^a-zA-Z0-9_]/u", $source) != 0 ||
				preg_match("/[ ,:;\[(]{$import_base}[ ,:;\])]/u", $source) != 0 ||
				preg_match("/\s+implements\s+(?:[a-zA-Z0-9_]+,\s+)*{$import_base}[^a-zA-Z0-9_]/u", $source) != 0 ||
				preg_match("/:{$import_base}[^a-zA-Z0-9_]/u", $source) != 0 ||
				preg_match("/[\[,]\s*{$import_base}\s*[,\]]/u", $source) != 0 ||
				preg_match("/\s*=\s*{$import_base};/u", $source) != 0 ||
				preg_match("/Vector.<{$import_base}>/u", $source) != 0 ||

				preg_match("/[^a-zA-Z0-9_]{$import_full}\./u", $source) != 0 ||
				preg_match("/[^a-zA-Z0-9_]new\s+{$import_full}[^a-zA-Z0-9_]/u", $source) != 0 ||
				preg_match("/\s+(?:is|as|extends)\s+{$import_full}[^a-zA-Z0-9_]/u", $source) != 0 ||
				preg_match("/[ ,:;\[(]{$import_full}[ ,:;\])]/u", $source) != 0 ||
				preg_match("/\s+implements\s+(?:[a-zA-Z0-9_]+,\s+)*{$import_full}[^a-zA-Z0-9_]/u", $source) != 0 ||
				preg_match("/:{$import_full}[^a-zA-Z0-9_]/u", $source) != 0 ||
				preg_match("/[\[,]\s*{$import_full}\s*[,\]]/u", $source) != 0 ||
				preg_match("/\s*=\s*{$import_full};/u", $source) != 0 ||
				preg_match("/Vector.<{$import_full}>/u", $source) != 0
			))
			{
				$used[] = $import;
			 	continue;
			}

			if ($is_function && (
				preg_match("/[^a-zA-Z0-9_]{$import_base}[^a-zA-Z0-9_]/u", $source) != 0 ||
				preg_match("/[\[,]\s*{$import_base}\s*[,\]]/u", $source) != 0
			))
			{
				$used[] = $import;
			 	continue;
			}
		}

		$positions = array();

		reset($imports);
		while (list(, $import) = each($used))
		{
			$position = $this->get_position($import);

			$positions[$position][] = $import;
		}

		ksort($positions);
		reset($positions);

		$joined = array();
		while (list($position, $imports) = each($positions))
		{
			sort($imports);

			$imports = implode(";\n\timport ", $imports);
			if ($imports != "")
				$imports = "\timport ".$imports.";";

			$joined[] = $imports;
		}

		$joined = implode("\n\n", $joined);
		if ($joined != "")
			$joined = $joined."\n";

		if ($package != "")
			$package = " ".$package;

		$source = self::BOM."package".$package."\n{\n".$joined.$source;
		$source = str_replace("\n", "\r\n", $source);

		if ($source == $orig_source)
			return;

		echo "Updating {$source_file}\n";

		file_put_contents($source_file, $source);
	}

	private function get_position($import)
	{
		if (strpos($import, "flash.") === 0)
			return 0;
		if (strpos($import, "fl.") === 0)
			return 1;
		if (strpos($import, "Box2D.") === 0)
			return 2;

		$common = array("buttons.", "chat.", "controllers.", "clans.", "dialogs.", "education.", "events.", "footers.", "game.", "headers.", "loaders.", "locale.", "menu.", "mobile.", "particles.", "ratings.", "screens.", "sensors.", "sounds.", "statuses.", "syncronize.", "tape.", "views.", "wear.", "widgets.");
		while (list(, $package) = each($common))
		{
			if (strpos($import, $package) === 0)
				return 3;
		}

		if (strpos($import, "avmplus.") === 0)
			return 4;
		if (strpos($import, "by.blooddy.") === 0)
			return 5;
		if (strpos($import, "com.") === 0)
			return 6;
		if (strpos($import, "com.api.") === 0)
			return 7;
		if (strpos($import, "com.greensock.") === 0)
			return 8;
		if (strpos($import, "com.senocular.") === 0)
			return 9;
		if (strpos($import, "dragonBones.") === 0)
			return 10;
		if (strpos($import, "editor.") === 0)
			return 11;
		if (strpos($import, "feathers.") === 0)
			return 12;
		if (strpos($import, "hscript.") === 0)
			return 13;
		if (strpos($import, "interfaces.") === 0)
			return 14;
		if (strpos($import, "luaAlchemy.") === 0)
			return 15;
		if (strpos($import, "protocol.") === 0)
			return 16;
		if (strpos($import, "ru.") === 0)
			return 17;
		if (strpos($import, "starling.") === 0)
			return 18;
		if (strpos($import, "utils.") === 0)
			return 19;

		echo "Import {$import} has unknown position\n";
	}

	private function parse_dir($dir, $callback)
	{
		$dir_handle = opendir($dir);
		if ($dir_handle === false)
			die("Can't open directory ".$dir);

		while (($file = readdir($dir_handle)) !== false)
		{
			if ($file === "." || $file === "..")
				continue;

			if (is_dir($dir.$file))
			{
				$this->parse_dir($dir.$file."/", $callback);
				continue;
			}

			if (strstr($file, ".") !== ".as")
				continue;

			call_user_func_array($callback, array($dir.$file));
		}

		closedir($dir_handle);
	}
}

	$updater = new Updater();

	$updater->add_path("src/");
	$updater->add_path("editor/");

	$dir_handle = opendir(".");
	while (($file = readdir($dir_handle)))
	{
		if ($file == "." || $file == "..")
			continue;

		if (strrchr($file, ".") != ".as")
			continue;

		$updater->add_file($file);
	}
	closedir($dir_handle);

	$updater->update();

?>