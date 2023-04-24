package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import game.mainGame.events.SquirrelEvent;
	import screens.ScreenGame;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundHollow;

	import utils.Sector;

	public class PerkShamanLazy extends PerkShamanPassive
	{
		static private const SQUIRRELS_COUNT:int = 3;

		static public const DELAY_TIME_SEC:int = 120;

		private var delayTimer:Timer = new Timer(DELAY_TIME_SEC * 10, 100);
		private var sector:Sector = new Sector();
		private var _available:Boolean = false;
		private var heroPicked:int = 0;

		public function PerkShamanLazy(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.delayTimer.stop();
			this.delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, checkSquirrelsCount);
			this.delayTimer.addEventListener(TimerEvent.TIMER, updateBuff);

			this.code = PerkShamanFactory.PERK_LAZY;
		}

		override public function dispose():void
		{
			if (this.hero)
				this.hero.removeEventListener(SquirrelEvent.ACORN, checkSquirrelsCount);

			super.dispose();

			this.delayTimer.stop();
			this.delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, checkSquirrelsCount);
			this.delayTimer.removeEventListener(TimerEvent.TIMER, updateBuff);
		}

		override public function resetRound():void
		{
			super.resetRound();

			this.delayTimer.reset();
			this.sector.start = 0;
		}

		override protected function activate():void
		{
			super.activate();

			this.sector.start = 0;
			this.sector.radius = 18;
			this.sector.x = 17;
			this.sector.y = 17;
			this.sector.color = 0xFF0000;
			this.sector.alpha = 0.5;
			this.buff.addChild(this.sector);

			this.hero.addEventListener(SquirrelEvent.ACORN, checkSquirrelsCount);

			var roundTime:int = ScreenGame.roundTime;

			var delay:int = (DELAY_TIME_SEC - countBonus() - (roundTime > 0 ? roundTime : 0)) * 10;
			this.delayTimer.delay = (delay > 0 ? delay : 0);

			if (roundTime <= 0)
				return;

			checkSquirrelsCount();

			if (this.delayTimer.delay == 0)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}

		override protected function get packets():Array
		{
			return [PacketRoomRound.PACKET_ID, PacketRoundHollow.PACKET_ID, PacketRoundDie.PACKET_ID,
				PacketRoomLeave.PACKET_ID];
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (!this.hero || !this.hero.game)
				return;

			switch (packet.packetId)
			{
				case PacketRoomRound.PACKET_ID:
					var round: PacketRoomRound = packet as PacketRoomRound;

					if (round.type != PacketServer.ROUND_CUT)
					{
						this._available = false;
						this.heroPicked = 0;
					}

					if (round.type != PacketServer.ROUND_START)
						return;

					if (this.delayTimer.delay == 0)
						return;

					this.delayTimer.reset();
					this.delayTimer.start();
					break;
				case PacketRoundHollow.PACKET_ID:
					var hollow: PacketRoundHollow = packet as PacketRoundHollow;

					if (hollow.success == 1 || hollow.playerId == this.hero.id)
						return;

					if (++this.heroPicked >= SQUIRRELS_COUNT)
						this._available = true;

					checkSquirrelsCount();
					break;
				case PacketRoomLeave.PACKET_ID:
					if ((packet as PacketRoomLeave).playerId == this.hero.id)
						return;

					checkSquirrelsCount();
					break;
				case PacketRoundDie.PACKET_ID:
					var die: PacketRoundDie = packet as PacketRoundDie;
					if (die.playerId == this.hero.id)
						return;

					if (!this.hero || !this.hero.game)
						return;

					var squirrels:Object = this.hero.game.squirrels.players;
					for each (var hero:Hero in squirrels)
					{
						if (!hero || hero.isDead || hero.inHollow || !hero.shaman)
							continue;

						for (var i:int = 0; i < hero.perksShaman.length; i++)
						{
							if ((hero.perksShaman[i] is PerkShamanHeavensGate) && (hero.perksShaman[i] != this) && hero.perksShaman[i].active)
								return;
						}
					}

					checkSquirrelsCount();
					break;
			}
		}

		private function checkSquirrelsCount(e:Event = null):void
		{
			if (!this.active || !this._available)
				return;

			if (!this.hero || !this.hero.isSelf)
				return;

			if (!this.isMaxLevel && !this.hero.hasNut)
				return;

			if (!this.hero.game || !this.hero.game.squirrels || !this.hero.game.map)
				return;

			if (this.hero.game.squirrels.getActiveSquirrels().length != 0)
				return;

			if (this.delayTimer.running)
				return;

			if (this.isMaxLevel && !this.hero.hasNut && this.heroPicked >= SQUIRRELS_COUNT)
			{
				this.hero.setMode(Hero.NUT_MOD);
				Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
			}

			setTimeout(toHollow, 0);
		}

		private function toHollow():void
		{
			if (!this.hero)
				return;
			this.hero.onHollow(this.hero.team);
			Connection.sendData(PacketClient.ROUND_HOLLOW, this.hero.team);
		}

		private function updateBuff(e:TimerEvent):void
		{
			this.sector.end = Math.PI * 2 - this.delayTimer.currentCount / 100 * Math.PI * 2;
		}
	}
}