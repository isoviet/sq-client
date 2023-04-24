package game.mainGame.gameBattleNet.achieves
{
	import flash.events.EventDispatcher;

	import game.mainGame.IReset;
	import game.mainGame.events.AchieveEvent;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundDie;

	public class AchieveFragsWithoutDie extends EventDispatcher implements IDispose, IReset
	{
		private var counter:int = 0;

		public function AchieveFragsWithoutDie():void
		{
			Connection.listen(onPacket, PacketRoundDie.PACKET_ID);
		}

		public function dispose():void
		{
			Connection.forget(onPacket, PacketRoundDie.PACKET_ID);
		}

		public function reset():void
		{
			this.counter = 0;
		}

		public function kill():void
		{
			this.counter++;
			switch (counter)
			{
				case 3:
					dispatchEvent(new AchieveEvent(AchieveEvent.INVULNERABLE));
					break;
				case 4:
					dispatchEvent(new AchieveEvent(AchieveEvent.RAMBO));
					break;
			}
		}

		private function onPacket(packet:PacketRoundDie):void
		{
			if (packet.playerId == Game.selfId)
			{
				this.counter = 0;
				return;
			}

			if (packet.killerId <= 0 || (packet.killerId != Game.selfId))
				return;
			kill();
		}
	}
}