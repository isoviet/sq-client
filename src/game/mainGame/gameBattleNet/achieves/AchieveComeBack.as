package game.mainGame.gameBattleNet.achieves
{
	import flash.events.EventDispatcher;

	import game.mainGame.IReset;
	import game.mainGame.events.AchieveEvent;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundDie;

	public class AchieveComeBack extends EventDispatcher implements IDispose, IReset
	{
		static private const DIE_COUNT:int = 3;

		private var counter:int = 0;

		public function AchieveComeBack():void
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
			if (this.counter >= DIE_COUNT)
				dispatchEvent(new AchieveEvent(AchieveEvent.COMEBACK));

			this.counter = 0;
		}

		private function onPacket(packet:PacketRoundDie):void
		{

			if (packet.playerId == Game.selfId)
			{
				this.counter++;
				return;
			}

			if (packet.killerId <= 0 || (packet.killerId != Game.selfId))
				return;
			kill();
		}
	}
}