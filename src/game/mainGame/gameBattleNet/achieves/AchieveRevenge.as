package game.mainGame.gameBattleNet.achieves
{
	import flash.events.EventDispatcher;

	import game.mainGame.IReset;
	import game.mainGame.SquirrelGame;
	import game.mainGame.events.AchieveEvent;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundDie;

	public class AchieveRevenge extends EventDispatcher implements IDispose, IReset
	{
		private var game:SquirrelGame = null;

		private var revenged:Boolean = false;

		public function AchieveRevenge(game:SquirrelGame):void
		{
			this.game = game;

			Connection.listen(onPacket, PacketRoundDie.PACKET_ID);
		}

		public function dispose():void
		{
			this.game = null;

			Connection.forget(onPacket, PacketRoundDie.PACKET_ID);
		}

		public function reset():void
		{
			this.revenged = false;
		}

		private function onPacket(packet:PacketRoundDie):void
		{
			if (packet.killerId <= 0)
				return;

			if (packet.playerId == Game.selfId)
			{
				this.revenged = false;
				return;
			}

			if (packet.killerId != Game.selfId || !Hero.self)
				return;

			if (this.revenged || (packet.playerId != Hero.self.lastKiller))
				return;

			this.revenged = true;

			dispatchEvent(new AchieveEvent(AchieveEvent.REVENGE));
		}
	}
}