package
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	import events.LoggerEvent;

	public class Logger
	{
		static public var messages:Array = new Array();
		static public var dispatcher:EventDispatcher = new EventDispatcher();

		static public function getMessages(count:int = int.MAX_VALUE):String
		{
			var result:String;
			for (var i:int = Math.max(0, messages.length - count); i < messages.length; i++)
				result += messages[i] + "\n";
			return result;
		}

		static public function add(...rest):void
		{
			var message:String = "[" + getTimer() + "] " + rest;
			trace(message);
			Logger.messages.push(message);
			dispatcher.dispatchEvent(new LoggerEvent(LoggerEvent.MESSAGE, message + "\n"));
		}

		static public function setTag(name:String):void
		{
			Logger.messages.push("[Tag:" + name + "]");
			trace("[Tag:" + name + "]");
		}

		static public function closeTag(name:String):void
		{
			var pos:int = messages.length - 1;
			while (messages.length > 0)
			{
				if (messages.pop() == "[Tag:" + name + "]")
					return;
			}
		}
	}
}