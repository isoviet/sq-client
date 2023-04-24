package game.mainGame.gameRecord
{
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.RecorderCollection;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundCastBegin;
	import protocol.packages.server.PacketRoundCastEnd;
	import protocol.packages.server.PacketRoundCommand;
	import protocol.packages.server.PacketRoundHero;
	import protocol.packages.server.PacketRoundHollow;

	public class Recorder
	{
		static public const ROUND_COMMAND:int = 0;
		static public const ROUND_HERO:int = 1;
		static public const ROUND_CAST_BEGIN:int = 4;
		static public const ROUND_CAST_END:int = 5;

		static public const FIRST_ID:int = -1;

		public var isRecording:Boolean = false;
		public var isReplay:Boolean = false;
		public var isNet:Boolean = false;

		public var actions:Array = [];
		public var timeStart:int = 0;
		public var playerId:int = FIRST_ID;	//TODO unique

		private var currentStep:int = 0;
		private var onStopReplayCallback:Function;

		public function Recorder():void
		{
			super();

			RecorderCollection.add(this);
		}

		public function dispose():void
		{
			this.actions = [];

			RecorderCollection.remove(this);
		}

		public function startRecord():void
		{
			if (this.isReplay)
				return;

			if (this.isRecording)
				stopRecord();

			this.timeStart = getTimer();
			this.isRecording = true;
		}

		public function stopRecord():void
		{
			this.isRecording = false;
		}

		public function startReplay():void
		{
			this.currentStep = 0;
			this.timeStart = getTimer();

			this.isRecording = false;
			this.isReplay = true;

			EnterFrameManager.addListener(onFrame);
		}

		public function stopReplay():void
		{
			EnterFrameManager.removeListener(onFrame);

			this.isReplay = false;

			if (this.onStopReplayCallback != null && this.onStopReplayCallback is Function)
				this.onStopReplayCallback.apply();
		}

		public function whenStopReplay(callback:Function):void
		{
			this.onStopReplayCallback = callback;
		}

		public function add(action:Array):void
		{
			this.actions.push(action);
		}

		public function addDataClient(type:int, packet:Array):void
		{
			if (!this.isRecording)
				return;
			switch (type)
			{
				case PacketClient.ROUND_COMMAND:
					var data:Object = by.blooddy.crypto.serialization.JSON.decode(packet[0]);
					if ('Create' in data || 'Destroy' in data)
						return;
				case PacketClient.ROUND_HERO:
					this.actions.push([getTimer() - this.timeStart, convertType(type), convertData(type, packet)]);
					break;
				case PacketClient.ROUND_CAST_BEGIN:
				case PacketClient.ROUND_CAST_END:
					if (this.isNet)
						return;

					var serverType:int = convertType(type);
					var serverData:Array = convertData(type, packet);
					this.actions.push([getTimer() - this.timeStart, serverType, serverData]);
					Connection.receiveFake(reconvertType(serverType), serverData);
					break;
			}
		}

		public function addDataServer(packet:AbstractServerPacket):void
		{
			if (!isRecording)
				return;

			if (parseData(packet) == null)
				return;

			add([getTimer() - timeStart, packet.packetId, packet]);
		}

		protected function parseData(packet:AbstractServerPacket):AbstractServerPacket
		{
			switch (packet.packetId)
			{
				case PacketRoundCastBegin.PACKET_ID:
				case PacketRoundCastEnd.PACKET_ID:
					break;
				case PacketRoundHollow.PACKET_ID:
					if ((packet as PacketRoundHollow).playerId != this.playerId)
						return null;
					break;
				default:
					return null;
			}

			return packet;
		}

		protected function decodeData(type:int, data:Array):Array
		{
			switch(type)
			{
				case PacketRoundCommand.PACKET_ID:
					data[1] = by.blooddy.crypto.serialization.JSON.decode(data[1]);
					break;
			}

			return data;
		}

		protected function convertData(type:int, data:Array):Array
		{
			var answer:Array = data.concat();
			switch (type)
			{
				case PacketClient.ROUND_COMMAND:
				case PacketClient.ROUND_HERO:
				case PacketClient.ROUND_CAST_BEGIN:
				case PacketClient.ROUND_CAST_END:
					answer.unshift(this.playerId);
					break;
			}
			return answer;
		}

		protected function convertType(type:int):int
		{
			switch (type)
			{
				case PacketClient.ROUND_COMMAND:
					return ROUND_COMMAND;
				case PacketClient.ROUND_HERO:
					return ROUND_HERO;
				case PacketClient.ROUND_CAST_BEGIN:
					return ROUND_CAST_BEGIN;
				case PacketClient.ROUND_CAST_END:
					return ROUND_CAST_END;
			}
			return 0;
		}

		protected function reconvertType(type:int):int
		{
			switch (type)
			{
				case ROUND_COMMAND:
					return PacketRoundCommand.PACKET_ID;
				case ROUND_HERO:
					return PacketRoundHero.PACKET_ID;
				case ROUND_CAST_BEGIN:
					return PacketRoundCastBegin.PACKET_ID;
				case ROUND_CAST_END:
					return PacketRoundCastEnd.PACKET_ID;
			}
			return 0;
		}

		private function cloneData(data:*):*
		{
			if (data is Array)
				return (data as Array).concat();
			if (data is ByteArray)
			{
				var answer:ByteArray = new ByteArray();
				(data as ByteArray).readBytes(answer, 0, (data as ByteArray).length);

				answer.position = 0;
				data.position = 0;

				return answer;
			}
			return data;
		}

		private function onFrame():void
		{
			var time:int = getTimer();

			while ((this.currentStep < this.actions.length) && (this.actions[this.currentStep][0] <= time - this.timeStart))
			{
				var packet:Object = this.actions[this.currentStep];
				this.currentStep++;

				var type:int = reconvertType(packet[1]);
				Connection.receiveFake(type, decodeData(type, packet[2]));
			}

			if (this.currentStep >= this.actions.length)
				stopReplay();
		}
	}
}