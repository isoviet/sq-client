package
{
	import flash.utils.getTimer;

	public class Logger
	{
		static public var messages:Array = [];
		static public var callBacks:Array = [];
		static public var traceEnabled:Boolean = true;
		static public var traceTextureEnabled:Boolean = false;

		static public function getMessages(count:int = int.MAX_VALUE):String
		{
			var result:String = "";
			for (var i:int = Math.max(0, messages.length - count); i < messages.length; i++)
				result += messages[i] + "\n";
			return result;
		}

		static public function add(...rest):void
		{
			var message:String = "[" + getTimer() + "] " + rest;
			if (traceEnabled)
				trace(message);

			Logger.messages.push(message);

			PreLoader.showDebug();

			var srting:String = message + "\n";
			for each (var callback:Function in callBacks)
				callback(srting);
		}

		static public function setTag(name:String):void
		{
			Logger.messages.push("[Tag:" + name + "]");
			trace("[Tag:" + name + "]");
		}

		static public function closeTag(name:String):void
		{
			while (messages.length > 0)
			{
				if (messages.pop() == "[Tag:" + name + "]")
					return;
			}
		}
	}
}