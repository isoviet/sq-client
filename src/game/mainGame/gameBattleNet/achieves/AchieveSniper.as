package game.mainGame.gameBattleNet.achieves
{
	import flash.events.EventDispatcher;

	import game.mainGame.SquirrelGame;
	import game.mainGame.events.AchieveEvent;
	import game.mainGame.perks.Perk;
	import game.mainGame.perks.mana.PerkSmallSize;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundDie;

	public class AchieveSniper extends EventDispatcher implements IDispose
	{
		private var game:SquirrelGame = null;

		public function AchieveSniper(game:SquirrelGame):void
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

			if (!this.game || !this.game.squirrels)
				return;
			var victim:Hero = this.game.squirrels.get(packet.playerId);

			if (!victim || !victim.perkController)
				return;

			for each (var perk:Perk in victim.perkController.perksMana)
			{
				if (!(perk is PerkSmallSize))
					continue;
				if (!perk.active)
					return;
				dispatchEvent(new AchieveEvent(AchieveEvent.SNIPER));
				return;
			}
		}
	}
}