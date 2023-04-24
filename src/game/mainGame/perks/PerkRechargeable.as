package game.mainGame.perks
{
	import flash.events.Event;

	import game.mainGame.perks.hare.IReborn;

	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundHero;

	public class PerkRechargeable extends Perk
	{
		public var inc:int = 0;
		public var dec:int = 0;
		public var charge:Number = 100;

		public function PerkRechargeable(hero:Hero):void
		{
			super(hero);

			initVars();
			this.activateSound = "";
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (this.lastAvalibleState != available)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = available;

			if (this.hero.isDead && !(this is IReborn))
				return;

			var charge:Number = this.charge;

			this.charge = this.charge + (this.active ? -this.dec : this.inc) * timeStep;

			if (this.charge <= 0)
				this.active = false;

			if (this.charge >= 100)
				this.charge = 100;

			if (this.charge != charge)
				dispatchEvent(new Event("STATE_CHANGED"));
		}

		override protected function get packets():Array
		{
			return [PacketRoundHero.PACKET_ID];
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			var pktHero: PacketRoundHero = packet as PacketRoundHero;

			if (this.hero == null || pktHero.playerId != this.hero.id)
				return;

			if (pktHero.keycode == this.code)
				this.active = true;

			if (pktHero.keycode == -this.code)
				this.active = false;
		}

		protected function initVars():void
		{}
	}
}