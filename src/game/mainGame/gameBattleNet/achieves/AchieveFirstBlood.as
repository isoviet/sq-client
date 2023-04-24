package game.mainGame.gameBattleNet.achieves
{
	import flash.events.EventDispatcher;

	import game.mainGame.SquirrelCollection;
	import game.mainGame.events.AchieveEvent;
	import game.mainGame.gameBattleNet.SquirrelGameBattleNet;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundDie;

	public class AchieveFirstBlood extends EventDispatcher implements IDispose
	{
		private var game:SquirrelGameBattleNet = null;

		public function AchieveFirstBlood(game:SquirrelGameBattleNet):void
		{
			this.game = game;

			Connection.listen(onPacket, PacketRoundDie.PACKET_ID);
		}

		public function dispose():void
		{
			this.game = null;

			Connection.forget(onPacket, PacketRoundDie.PACKET_ID);
		}

		private function onPacket(packet:PacketRoundDie):void
		{
			if (packet.killerId <= 0)
				return;

			if (packet.killerId != Game.selfId)
				return;

			if (!SquirrelCollection.instance)
				return;

			var hero:Hero = SquirrelCollection.instance.get(packet.playerId);
			if (!hero || !this.game)
				return;

			if ((hero.team == Hero.TEAM_RED) && (int(this.game.getScore()[1]) == 1))
				dispatchEvent(new AchieveEvent(AchieveEvent.FIRST_BLOOD));

			if ((hero.team == Hero.TEAM_BLUE) && (int(this.game.getScore()[0]) == 1))
				dispatchEvent(new AchieveEvent(AchieveEvent.FIRST_BLOOD));
		}
	}
}