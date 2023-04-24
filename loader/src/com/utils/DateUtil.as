package com.utils
{
	public class DateUtil
	{
		/**
		 * Parse date and return date in seconds
		 * Supported formats: dd.mm.yyyy, mm/dd/yyyy, yyyy-mm-dd
		 */
		static public function getTime(dateString:String):int
		{
			if (dateString == "0" || dateString == "" || dateString == null)
				return 0;

			var timeStart:int = dateString.indexOf("T");
			if (timeStart != -1)
				dateString = dateString.substring(0, timeStart);

			var delimeter:String;
			if (dateString.indexOf("/") != -1)
				delimeter = "/";
			else if (dateString.indexOf(".") != -1)
				delimeter = ".";
			else if (dateString.indexOf("-") != -1)
				delimeter = "-";
			else
				return 0;

			var parsed:Array = dateString.split(delimeter);
			if (parsed.length != 3)
				return 0;

			var year:int, month:int, day:int;

			if (delimeter == "/")
			{
				month = parseInt(parsed[0]);
				day = parseInt(parsed[1]);
				year = parseInt(parsed[2]);
			}
			else if (delimeter == ".")
			{
				day = parseInt(parsed[0]);
				month = parseInt(parsed[1]);
				year = parseInt(parsed[2]);
			}
			else if (delimeter == "-")
			{
				year = parseInt(parsed[0]);
				month = parseInt(parsed[1]);
				day = parseInt(parsed[2]);
			}

			if (year <= 1901 || year >= 2038)
				return 0;

			var date:Date = new Date(year, month - 1, day);

			return int(date.getTime() / 1000);
		}
	}
}