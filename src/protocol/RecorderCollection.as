package protocol
{
	import flash.utils.Dictionary;

	import game.mainGame.gameRecord.Recorder;

	import protocol.packages.server.AbstractServerPacket;

	public class RecorderCollection
	{
		static private var collection:Dictionary = new Dictionary();

		static public function has(playerId:int):Boolean
		{
			for each(var recorder:Recorder in collection)
				if (recorder.playerId == playerId)
					return true;

			return false;
		}

		static public function get empty():Boolean
		{
			for each(var recorder:Recorder in collection)
				return false;

			return true;
		}

		static public function add(recorder:Recorder):void
		{
			collection[recorder] = recorder;
		}

		static public function remove(recorder:Recorder):void
		{
			delete collection[recorder];
		}

		static public function addDataClient(type:int, packet:Array):void
		{
			for each(var recorder:Recorder in collection)
				recorder.addDataClient(type, packet);
		}

		public static function addDataServer(packet:AbstractServerPacket):void
		{
			for each(var recorder:Recorder in collection)
				recorder.addDataServer(packet);
		}
	}
}