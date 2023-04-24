package utils
{
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;

	import by.blooddy.crypto.MD5;

	public class SupportManager
	{
		static private const SUPPORT_SECRET:String = "a79f419f611782afa260ee1f27687cb8";
		static private const REQUEST_TIME:int = 10;

		static private var lastRequest:int = 0;

		static public function init():void
		{
			ExternalInterface.call("supportInit");

			ExternalInterface.addCallback("supportCallback", onSupportCallback);
		}

		static private function onSupportCallback():void
		{
			var time:int = int(getTimer() / 1000);
			if (time - lastRequest < REQUEST_TIME && (lastRequest != 0))
			{
				ExternalInterface.call("supportAnswer", {"status": "fail"});
				return;
			}
			lastRequest = time;

			var answer:Object = {
				"status": "success",
				"type": Game.self.type,
				"time": int(Game.unix_time + lastRequest),
				"net_id": Game.self.nid
			};
			answer["sig"] = MD5.hash(answer["type"] + answer["time"] + SUPPORT_SECRET+ answer["net_id"]);

			ExternalInterface.call("supportAnswer", answer);
		}
	}
}