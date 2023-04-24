package game.mainGame.entity.magic
{
	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.IPinFree;
	import game.mainGame.entity.simple.InvisibleBody;

	import protocol.Connection;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;
	import protocol.packages.server.PacketRoundSkillAction;

	public class SavePointObject extends InvisibleBody implements IPinFree
	{
		protected var sended:Boolean = false;

		protected var perkCode:int;

		public function SavePointObject(offsetX:int = 0, offsetY:int = 0):void
		{
			super(this.animation, offsetX, offsetY);
		}

		override public function build(world:b2World):void
		{
			super.build(world);

			Connection.listen(onPacket, [PacketRoundSkill.PACKET_ID, PacketRoundSkillAction.PACKET_ID]);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
		}

		override public function dispose():void
		{
			super.dispose();

			Connection.forget(onPacket, [PacketRoundSkill.PACKET_ID, PacketRoundSkillAction.PACKET_ID]);
		}

		protected function get animation():Class
		{
			return null;
		}

		protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var packetSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (packetSkill.type != this.perkCode)
						return;
					if (packetSkill.targetId != this.playerId)
						return;
					this.gameInst.map.destroyObjectSync(this, true);
					break;
				case PacketRoundSkillAction.PACKET_ID:
					var packetAction:PacketRoundSkillAction = packet as PacketRoundSkillAction;
					if (packetAction.type != this.perkCode)
						return;
					if (packetAction.targetId != this.playerId)
						return;
					this.gameInst.map.destroyObjectSync(this, true);
					break;
			}
		}
	}
}