package game.mainGame.entity.magic
{
	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.simple.InvisibleBodyTemp;
	import game.mainGame.perks.clothes.PerkClothesFactory;

	import protocol.Connection;
	import protocol.PacketServer;
	import protocol.packages.server.PacketRoundSkill;

	public class HarlockFlag extends InvisibleBodyTemp
	{
		public function HarlockFlag()
		{
			super(HarlockPerkView, 0, 10);
		}

		private function onPacket(packet:PacketRoundSkill):void
		{
			if (packet.state != PacketServer.SKILL_DEACTIVATE)
				return;
			if (packet.type != PerkClothesFactory.HARLOCK)
				return;
			if (packet.targetId != this.playerId)
				return;
			if (!this.gameInst.squirrels.isSynchronizing)
				return;
			this.gameInst.map.destroyObjectSync(this, true);
		}

		override public function build(world:b2World):void
		{
			super.build(world);

			Connection.listen(onPacket, [PacketRoundSkill.PACKET_ID]);
		}

		override public function dispose():void
		{
			super.dispose();

			Connection.forget(onPacket, [PacketRoundSkill.PACKET_ID]);
		}
	}
}