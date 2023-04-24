package game.mainGame.perks.clothes
{
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.magic.ShadowBomb;
	import game.mainGame.entity.simple.GameBody;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesShadowBomb extends PerkClothesSelectPoint
	{
		static private const COOLDOWN:Array = [30, 30, 30, 30, 30,
							30, 28, 26, 24, 22, 20];

		public function PerkClothesShadowBomb(hero:Hero):void
		{
			super(hero);
			this.activateSound = "teleport";
		}

		override public function get totalCooldown():Number
		{
			return COOLDOWN[this.perkLevel];
		}

		override public function get json():String
		{
			if (this.active)
				return "";
			var point:Point = this.hero.heroView.localToGlobal(new Point(0, -20));
			var heroPosition:Point = new Point(this.hero.position.x, this.hero.position.y);
			return by.blooddy.crypto.serialization.JSON.encode([this.selectedPoint, new Point(point.x, point.y), heroPosition]);
		}

		override protected function get arrowMode():Boolean
		{
			return true;
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

					var targetPoint:Point = new Point(roundSkill.scriptJson[0].x * Game.PIXELS_TO_METRE, roundSkill.scriptJson[0].y * Game.PIXELS_TO_METRE);
					var heroPoint:Point = new Point(roundSkill.scriptJson[1].x, roundSkill.scriptJson[1].y);
					var weaponAngle:Number = Math.atan2(targetPoint.y - heroPoint.y, targetPoint.x - heroPoint.x);

					var castObject:ShadowBomb = new ShadowBomb();
					castObject.angle = weaponAngle;
					castObject.position = new b2Vec2(roundSkill.scriptJson[2].x, roundSkill.scriptJson[2].y);
					castObject.playerId = this.hero.id;
					castObject.velocity = 100 * (Math.min(heroPoint.subtract(targetPoint).length, this.maxLength) / this.maxLength);
					(castObject as GameBody).linearVelocity = new b2Vec2(Math.cos(weaponAngle) * (castObject as IShoot).maxVelocity, Math.sin(weaponAngle) * (castObject as IShoot).maxVelocity);

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