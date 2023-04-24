package game.mainGame.perks.shaman
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomJoin;

	public class PerkShamanMadness extends PerkShamanActive
	{
		private var timer:Timer = new Timer(10, 100);

		public function PerkShamanMadness(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_MADNESS;

			this.timer.delay = countBonus() * 10;
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}

		override public function dispose():void
		{
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
			this.timer.stop();

			this.active = false;

			super.dispose();
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoomJoin.PACKET_ID]);
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
			setMadness(true);

			this.timer.reset();
			this.timer.start();
		}

		override protected function deactivate():void
		{
			setMadness(false);
			this.timer.stop();

			super.deactivate();
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoomJoin:
					var join: PacketRoomJoin = packet as PacketRoomJoin;
					if (this.hero == null || !this.active)
						return;

					if (join.isPlaying == PacketServer.JOIN_PLAYING)
						return;

					var hero:Hero = this.hero.game.squirrels.get(join.playerId);
					this.isMaxLevel ? (hero.collideSquirrels = true) : (hero.headWalker = true);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function onComplete(e:TimerEvent):void
		{
			this.active = false;
		}

		private function setMadness(value:Boolean):void
		{
			if (!this.hero || !this.hero.game)
				return;

			var squirrels:Object = this.hero.game.squirrels.players;
			for each (var hero:Hero in squirrels)
			{
				if (value && !checkHero(hero) || !hero || !hero.isExist)
					continue;

				this.isMaxLevel ? (hero.collideSquirrels = value) : (hero.headWalker = value);

				if (value && !this.buff)
					this.buff = createBuff(0.5);

				(value ? hero.addBuff(this.buff, this.timer) : hero.removeBuff(this.buff, this.timer));
				if (value)
					hero.heroView.showActiveAura();
			}
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
					if ((hero.perksShaman[i] is PerkShamanMadness) && (hero.perksShaman[i] != this) && hero.perksShaman[i].active)
						hero.perksShaman[i].active = false;
				}
			}
		}

		private function checkHero(hero:Hero):Boolean
		{
			return !hero.isHare && !hero.isDragon && !hero.inHollow && (hero.shaman && (hero.id == this.hero.id) || !hero.shaman);
		}
	}
}