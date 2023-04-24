package clans
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import clans.PerkTotems;
	import footers.FooterGame;

	import protocol.Connection;
	import protocol.PacketServer;
	import protocol.packages.server.PacketRoundRespawn;

	public class PerkTotemRespawn extends PerkTotems
	{
		private var timer:Timer = null;

		public function PerkTotemRespawn(hero:Hero, bonus:int)
		{
			super(hero, bonus);
			Connection.listen(onPacket, PacketRoundRespawn.PACKET_ID);
			this.totemId = TotemsData.RESPAWN;

			if (this.hero.id != Game.selfId)
				return;

			if ((this.hero.player['clan_totem'] + this.hero.player['last_update'] - (getTimer() / 1000)) <= 0)
				FooterGame.toggleFreeRespawn(true);
			else
				startAllowTimer();
		}

		override public function dispose():void
		{
			Connection.forget(onPacket, PacketRoundRespawn.PACKET_ID);
			if (this.timer && this.timer.running)
			{
				this.timer.stop();
				this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, allowRespawn);
			}
			if (this.hero.id == Game.selfId)
				FooterGame.toggleFreeRespawn(false);
			super.dispose();
		}

		private function allowRespawn(e:TimerEvent):void
		{
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, allowRespawn);
			this.timer.stop();
			FooterGame.toggleFreeRespawn(true);
		}

		private function startAllowTimer():void
		{
			FooterGame.toggleFreeRespawn(false);
			this.timer = new Timer(1000, (Game.self['clan_totem'] + Game.self['last_update'] - (getTimer() / 1000)));
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, allowRespawn);
			this.timer.start();
		}

		private function onPacket(packet:PacketRoundRespawn):void
		{
			if (Game.selfId != packet.playerId)
				return;

			if (packet.respawnType != PacketServer.RESPAWN_CLAN_TOTEM)
				return;

			if (packet.status == PacketServer.RESPAWN_FAIL)
			{
				Game.request(Game.selfId, PlayerInfoParser.CLAN | PlayerInfoParser.CLAN_TOTEM);
				ClanManager.request(Game.self['clan_id'], true, ClanInfoParser.TOTEMS);
				FooterGame.toggleFreeRespawn(false);
				return;
			}

			Game.self['clan_totem'] = this.bonus * 60;
			Game.self['last_update'] = getTimer() / 1000;
			startAllowTimer();
		}
	}
}