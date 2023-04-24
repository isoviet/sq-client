package
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	import by.blooddy.crypto.MD5;
	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketLatency;

	import utils.CountryUtil;

	public class Latency
	{
		static private const URL:String = "https://squirrelspay.realcdn.ru/ping.php";
		static private const URL_KEY:String = "hy3ozMAlhomuQiAa8QiF";

		static private var timeSend:int;

		static private var urlCount:int = 0;
		static private var urlTotalTime:int = 0;
		static private var urlLastTime:int = 0;

		static public function latency():void
		{
			timeSend = getTimer();

			Connection.listen(onPacket, PacketLatency.PACKET_ID);

			Connection.sendData(PacketClient.LATENCY);

			callUrl(null);
		}

		private static function callUrl(e:Event):void
		{
			if (e != null)
			{
				var data:Object;

				try
				{
					data = by.blooddy.crypto.serialization.JSON.decode(e.currentTarget['data']);
				}
				catch(e:Error)
				{
					return;
				}

				if (!data['success'] || data['finished'])
					return;

				urlTotalTime += getTimer() - urlLastTime;
				urlCount++;
			}

			urlLastTime = getTimer();

			var url:String = "attempt=" + urlCount + "&";
			url += "country=" + ("country" in Game.self ? int(CountryUtil.convertId(Game.self.country, Game.self.type)) : 0) + "&";
			url += "mseconds=" + int(urlTotalTime / urlCount) + "&";
			url += "owner_id=" + Game.selfId + "&";
			url += "server=" + (Config.isRus ? 0 : 1) + "&";
			var sig:String = MD5.hash(url.replace(/&/g, "") + URL_KEY);
			url += "sig=" + sig;

			var request:URLRequest = new URLRequest(URL + "?" + url);
			var urlLoader:URLLoader = new URLLoader();
			request.method = URLRequestMethod.POST;

			urlLoader.addEventListener(Event.COMPLETE, callUrl);
			urlLoader.load(request);
		}

		static private function onPacket(packet:PacketLatency):void
		{
			if (packet) {}

			Connection.forget(onPacket, PacketLatency.PACKET_ID);

			var time:int = getTimer() - timeSend;
			Connection.sendData(PacketClient.LATENCY, time);

			setTimeout(latency, 3 * 60 * 1000);
		}
	}
}