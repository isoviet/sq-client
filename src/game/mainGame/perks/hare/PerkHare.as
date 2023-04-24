package game.mainGame.perks.hare
{
	import flash.events.Event;

	import game.mainGame.perks.PerkRechargeable;
	import screens.ScreenGame;

	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundHero;

	public class PerkHare extends PerkRechargeable
	{
		static private const BLOCKED_STEP:int = 5;

		protected var isBlocked:Boolean = false;

		public function PerkHare(hero:Hero):void
		{
			super(hero);
		}

		override public function update(timeStep:Number = 0):void
		{
			if (this.lastAvalibleState != available)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = available;

			if (this.hero.isDead && !(this is IReborn))
				return;

			var charge:Number = this.charge;

			if (this.isBlocked)
				this.charge = this.charge + (BLOCKED_STEP * timeStep);
			else
				this.charge = this.charge + (this.active ? -this.dec : this.inc) * timeStep;

			if (this.charge <= 0)
			{
				this.active = false;
				this.charge = 0;
			}

			if (this.charge >= 100)
			{
				this.isBlocked = false;
				this.charge = 100;
			}

			if (this.charge != charge)
				dispatchEvent(new Event("STATE_CHANGED"));
		}

		override public function get available():Boolean
		{
			return super.available && this.hero.isHare && (!this.active && charge == 100 || this.active);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			var pktHero: PacketRoundHero = packet as PacketRoundHero;
			if (this.hero == null)
				return;

			if (pktHero.playerId != this.hero.id)
			{
				if (ScreenGame.mode != Locations.HARD_MODE)
					return;

				if (pktHero.keycode == this.code)
					block();
				return;
			}

			super.onPacket(packet);
		}

		override protected function initVars():void
		{
			this.inc = HarePerkFactory.getData(this)['inc'];
			this.dec = HarePerkFactory.getData(this)['dec'];
		}

		protected function block():void
		{}
	}
}