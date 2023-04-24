package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.magic.Muffin;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesMuffin extends PerkClothesSelectPoint
	{
		public function PerkClothesMuffin(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override public function get json():String
		{
			if (this.active)
				return "";
			return by.blooddy.crypto.serialization.JSON.encode(this.selectedPoint);
		}

		override protected function get maxRadius():Number
		{
			return 100;
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

					var castObject:Muffin = new Muffin();
					castObject.position = targetPoint;
					castObject.playerId = this.hero.id;

					this.hero.game.map.add(castObject);
					castObject.build(this.hero.game.world);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}
	}
}