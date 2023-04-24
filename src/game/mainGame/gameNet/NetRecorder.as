package game.mainGame.gameNet
{
	import flash.utils.ByteArray;

	import game.gameData.ReportManager;
	import game.mainGame.gameRecord.Recorder;

	import protocol.PacketClient;
	import protocol.packages.server.PacketRoom;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundHollow;

	public class NetRecorder extends Recorder
	{
		public function NetRecorder():void
		{
			super();

			this.isNet = true;
			this.playerId = 0;
		}

		override protected function decodeData(type:int, data:Array):Array
		{
			switch (type)
			{
				case PacketRoom.PACKET_ID:
					data[2] = [];
					break;
				case PacketRoomRound.PACKET_ID:
					if (8 in data)
						data[8] = ReportManager.mapData;
					break;
				default:
					return super.decodeData(type, data);
			}

			return data;
		}

		override protected function convertData(type:int, data:Array):Array
		{
			var answer:Array = data.concat();
			switch (type)
			{
				case PacketClient.ROUND_COMMAND:
				case PacketClient.ROUND_HERO:
				case PacketClient.ROUND_CAST_BEGIN:
				case PacketClient.ROUND_CAST_END:
					answer.unshift(Game.selfId);
					break;
			}
			return answer;
		}

		override protected function parseData(type:int, data:Array):Array
		{
			switch (type)
			{
				case PacketRoomRound.PACKET_ID:
					if (2 in data)
						ReportManager.replayMap = data[2];
					if (8 in data)
						data[8] = new ByteArray();
					return data;
				case PacketRoundHollow.PACKET_ID:
					if (data[1] != Game.selfId)
						return null;
					return data;
				default:
					return super.parseData(type, data);
			}
		}

		override protected function reconvertType(type:int):int
		{
			var convertType:int = super.reconvertType(type);

			return convertType == 0 ? type : convertType;
		}
	}
}