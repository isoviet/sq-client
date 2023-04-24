package game.mainGame.perks.shaman
{
	import flash.events.Event;

	import game.mainGame.events.SquirrelEvent;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkillShaman;

	public class PerkShamanActive extends PerkShaman
	{
		public function PerkShamanActive(hero:Hero, levels:Array):void
		{
			super(hero, levels);
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override protected function get packets():Array
		{
			return [PacketRoundSkillShaman.PACKET_ID];
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (!(packet is PacketRoundSkillShaman))
				return;

			var skillShaman: PacketRoundSkillShaman = packet as PacketRoundSkillShaman;

			if (skillShaman.state == PacketServer.SKILL_ERROR)
				return;

			if (!this.hero || skillShaman.type != this.code || skillShaman.playerId != this.hero.id)
				return;

			this.active = skillShaman.state == PacketServer.SKILL_ACTIVATE;
			dispatchEvent(new Event("STATE_CHANGED"));
		}

		override protected function onShaman(e:SquirrelEvent):void
		{
			update();
		}
	}
}