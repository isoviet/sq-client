package utils
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import by.blooddy.crypto.MD5;

	import hscript.HScript;

	import protocol.Connection;
	import protocol.PacketClient;

	public class GuardUtil extends Sprite
	{
		static private const COLLECTINGS_COUNT:SaltValue = new SaltValue(3);
		static private const COLLECTINGS_TIME:SaltValue = new SaltValue(1);

		static private var _selfId:SaltValue = new SaltValue(0);

		static private var collecting:SaltValue = new SaltValue(0);
		static private var collectingTime:SaltValue = new SaltValue(0);

		static public var circularKey:uint = 0;

		static public var dataString:String = "";

		static public var timer:Timer = new Timer(15 * 1000);

		static public function setSelfId(id:int):void
		{
			_selfId.value = id;
		}

		static public function checkId():void
		{
			if (Game.self.id != _selfId.value)
				Connection.sendData(PacketClient.PING, 1);
		}

		static public function calculateQuiz():String
		{
			if (dataString == "")
				return "";

			var a:Object = HScript.ExecuteHaXeScript(dataString, {'root': Game.stage});
			return ((a is ByteArray) ? MD5.hashBytes(a as ByteArray) : MD5.hash(a.toString())).toString();
		}

		static public function startRecheck():void
		{
			timer.addEventListener(TimerEvent.TIMER, recheck);
			timer.reset();
			timer.start();

			recheck();
		}

		static public function stopRecheck():void
		{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, recheck);
		}

		static public function recheck(e:TimerEvent = null):void
		{
			if (Game.guardValue != calculateQuiz())
				Connection.sendData(PacketClient.PING, 1);
		}

		static public function incCollecting():void
		{
			var now:int = getTimer() / 1000;

			if (collectingTime.value == 0)
				collectingTime.value = now;

			if (now - collectingTime.value > COLLECTINGS_TIME.value)
			{
				collectingTime.value = now;
				collecting.value = 1;
				return;
			}

			collecting.value++;

			if (collecting.value != COLLECTINGS_COUNT.value)
				return;

			collecting.value = 0;
			collectingTime.value = 0;

			Connection.sendData(PacketClient.PING, 2);
		}

		static public function startRound():void
		{
			collecting.value = 0;
			collectingTime.value = 0;
		}

		static public function encode(value:int):int
		{
			var answer:int = value ^ circularKey;
			circularShift(value);

			return answer;
		}

		static public function circularShift(value:int):void
		{
			var size:int = 32;
			var key:uint = circularKey + value;
			value = (value + 1) % size;
			circularKey = (key << value) | (key >>> (size - value));
		}
	}
}