package utils
{
	import flash.net.LocalConnection;
	import flash.system.System;
	import flash.utils.Dictionary;

	public class InstanceCounter
	{
		static private var instances:Dictionary = new Dictionary(true);

		static public function onCreate(instance:*):void
		{
			var stack:String;
			try
			{
				throw(new Error(""));
			}
			catch(e:Error)
			{
				stack = e.getStackTrace();
			}
			instances[instance] = [stack, false];
		}

		static public function onDispose(instance:*):void
		{
			if (instance == null)
				return;
			instances[instance][1] = true;
		}

		static public function report(withStack:Boolean = false):String
		{
			doForcedClean(3);

			var result:String = "Alive instances:\n";

			if (withStack)
			{
				for (var instanceElement:* in instances)
					result += "\t Class: " + instanceElement + (withStack ? "\t Stack:" + instances[instanceElement][0] + "\n" : "\n");
				return result;
			}

			var counter:Object = {};
			for (instanceElement in instances)
			{
				if (!(String(instanceElement) in counter))
					counter[String(instanceElement)] = [0, 0];

				counter[String(instanceElement)][1]++;
				if (!instances[instanceElement][1])
					counter[String(instanceElement)][0]++;
			}

			var list:Array = [];
			for (var name:String in counter)
				list.push({'name': name, 'count': counter[name][0] + "/" + counter[name][1]});
			list.sortOn("name");

			for each (var data:Object in list)
				result += "\t" + data.name + " : " + data.count + "\n";

			return result;
		}

		// Hack - позволяет вызвать принудительную итерацию GC
		static private function doForcedClean(interationCount:int = 1):void
		{
			Logger.add("Running GC... " + System.totalMemory / 1000000 + " Mb");

			for (var i:int = 0; i < interationCount; i++)
			{
				try
				{
					new LocalConnection().connect("Crio");
					new LocalConnection().connect("Crio");
				}
				catch (e:*)
				{}
			}
			Logger.add("Complete... " + System.totalMemory / 1000000 + " Mb");
		}
	}

}