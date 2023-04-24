package game.mainGame.perks.shaman
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomJoin;
	import protocol.packages.server.PacketRoundDie;

	public class PerkShamanSafeWay extends PerkShamanActive
	{
		private var timer:Timer = new Timer(100, 100);
		private var respawnTimer:Timer = new Timer(2 * 1000, 1);

		public function PerkShamanSafeWay(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_SAFE_WAY;

			this.timer.delay = countBonus() * 10;
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}

		override public function get available():Boolean
		{
			return super.available && !this.active;
		}

		override public function dispose():void
		{
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
			this.timer.stop();

			this.respawnTimer.stop();

			this.active = false;

			super.dispose();
		}

		override public function reset():void
		{
			this.timer.reset();
			this.respawnTimer.reset();

			super.reset();
		}

		override protected function activate():void
		{
			if (!this.hero || !this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			deactivateOtherPerks();

			if (!this.buff)
				this.buff = createBuff(0.5);

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (!checkHero(hero))
					continue;

				hero.immortal = true;
				hero.heroView.showActiveAura();
				hero.addBuff(this.buff, this.timer);
			}

			this.timer.reset();
			this.timer.start();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero || !this.hero.game)
				return;

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (!hero)
					continue;

				hero.immortal = false;
				hero.removeBuff(this.buff);
			}
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoomJoin.PACKET_ID, PacketRoundDie.PACKET_ID]);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (!this.hero)
				return;
			var hero: Hero;

			switch (packet.packetId)
			{
				case PacketRoomJoin.PACKET_ID:
					var join: PacketRoomJoin = packet as PacketRoomJoin;

					if (!this.active)
						return;

					if (join.isPlaying == PacketServer.JOIN_PLAYING)
						return;
					hero = this.hero.game.squirrels.get(join.playerId);
					if (hero)
						this.hero.game.squirrels.get(join.playerId).immortal = true;
					break;
				case PacketRoundDie.PACKET_ID:
					var die: PacketRoundDie = packet as PacketRoundDie;

					if (!this.respawnTimer || !this.respawnTimer.running)
						return;

					if (die.playerId == this.hero.id)
						return;

					hero = this.hero.game.squirrels.get(die.playerId);
					if (!hero || !hero.isSelf)
						return;

					setTimeout(Connection.sendData, 1000, PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_IMMORTAL);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function onComplete(e:TimerEvent):void
		{
			this.active = false;

			if (!this.isMaxLevel)
				return;

			this.respawnTimer.reset();
			this.respawnTimer.start();
		}

		private function deactivateOtherPerks():void
		{
			if (!this.hero || !this.hero.game)
				return;

			var squirrels:Object = this.hero.game.squirrels.players;
			for each (var hero:Hero in squirrels)
			{
				if (!hero || hero.isDead || hero.inHollow || !hero.shaman)
					continue;

				for (var i:int = 0; i < hero.perksShaman.length; i++)
				{
					if ((hero.perksShaman[i] is PerkShamanSafeWay || hero.perksShaman[i] is PerkShamanMassImmortal) && (hero.perksShaman[i] != this) && hero.perksShaman[i].active)
						hero.perksShaman[i].active = false;
				}
			}
		}

		private function checkHero(hero:Hero):Boolean
		{
			return hero && !hero.inHollow && !hero.isHare;
		}
	}
}