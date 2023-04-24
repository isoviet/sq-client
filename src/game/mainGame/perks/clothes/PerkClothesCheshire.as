package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.behaviours.StateChechire;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesCheshire extends PerkClothesSelectPoint
	{
		public function PerkClothesCheshire(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_TELEPORT;
			this.soundOnlyHimself = true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get startCooldown():Number
		{
			return 5;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function get maxRadius():Number
		{
			return 200;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (this.hero == null)
				return;
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var roundSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (roundSkill.state == PacketServer.SKILL_ERROR)
						return;
					if (roundSkill.type != this.code || roundSkill.playerId != this.hero.id)
						return;
					this.active = roundSkill.state == PacketServer.SKILL_ACTIVATE;

					if (roundSkill.state != PacketServer.SKILL_ACTIVATE)
						return;

					var targetPoint:b2Vec2 = new b2Vec2(roundSkill.scriptJson.x, roundSkill.scriptJson.y);
					var state:StateChechire = new StateChechire(targetPoint);
					this.hero.behaviourController.addState(state);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}
	}
}