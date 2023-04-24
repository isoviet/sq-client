package utils
{
	public class DateUtil
	{
		static public function getYearsOld(date:Number):int
		{
			if (date == 0)
				return 0;

			var now:Date = new Date();
			var birth:Date = new Date(date * 1000);
			var years:int = now.fullYear - birth.fullYear;

			if (birth.month > now.month || (birth.month == now.month && birth.date > now.date))
				years--;

			if (years < 0)
				return 0;
			return years;
		}

		static public function durationDayTime(time:int):String
		{
			var timeLeft:int = time;

			var days:int = int(timeLeft / (24 * 60 * 60));
			timeLeft = timeLeft % (24 * 60 * 60);
			var timeString:String = new Date(0, 0, 0, 0, 0, timeLeft).toTimeString().slice(0, 8);
			if (days > 0)
				timeString = days + gls("д.") + " " + timeString;

			return timeString;
		}

		static public function formatTime(time:int):String
		{
			var result:String = "";

			var minutes:int = int(time / 60);
			var seconds:int = time % 60;

			result += minutes.toString();

			result += ":";
			result += (seconds > 9 ? "" : "0") + seconds.toString();

			return result;
		}

		static public function durationString(time:int):String
		{
			var result:String = "";

			var days:int = time / (24 * 3600);
			var hours:int = (time % (24 * 3600)) / 3600;
			var minutes:int = (time % 3600) / 60;
			var seconds:int = time % 60;

			if (days != 0)
				result += days + " " + StringUtil.word("день", days);
			if (hours != 0)
			{
				if (result != "")
					result += " ";
				result += hours + " " + StringUtil.word("час", hours);
			}
			if (minutes != 0)
			{
				if (result != "")
					result += " ";
				result += minutes + " " + StringUtil.word("минуту", minutes);
			}
			if (seconds != 0 && minutes == 0 && hours == 0)
			{
				if (result != "")
					result += " ";
				result += seconds + " " + StringUtil.word("секунду", seconds);
			}
			return result;
		}

		static public function getFormatedDate(seconds:int):String
		{
			var date:Date = new Date(seconds * 1000);
			var day:String = formatDate(date.getDate());
			var month:String = formatDate(date.getMonth() + 1);
			var year:String = formatDate(date.getFullYear());

			return day + "." + month + "." + year;
		}

		static private function formatDate(time:int):String
		{
			var timeString:String = String(time);
			if (timeString.length < 2)
				timeString = "0" + timeString;
			return timeString;
		}
	}
}