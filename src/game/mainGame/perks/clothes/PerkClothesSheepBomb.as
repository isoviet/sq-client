package game.mainGame.perks.clothes
{
	import flash.display.Sprite;
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.magic.SheepBomb;
	import game.mainGame.entity.simple.GameBody;
	import sounds.GameSounds;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;
	import protocol.packages.server.PacketRoundSkillAction;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class PerkClothesSheepBomb extends PerkClothesSelectPoint
	{
		static private const TIME:Number = 5.0;
		static private const COOLDOWN:Array = [30, 28, 26, 24, 22,
							22, 22, 22, 22, 22, 20];

		private var victims:Object = {};

		public function PerkClothesSheepBomb(hero:Hero):void
		{
			super(hero);
			this.activateSound = SOUND_TELEPORT;
		}

		override public function get json():String
		{
			if (this.active)
				return "";
			var point:Point = this.hero.heroView.localToGlobal(new Point(0, -20));
			var heroPosition:Point = new Point(this.hero.position.x, this.hero.position.y);
			return by.blooddy.crypto.serialization.JSON.encode([this.selectedPoint, new Point(point.x, point.y), heroPosition]);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			for (var id:String in this.victims)
			{
				this.victims[id] -= timeStep;
				if (this.victims[id] > 0)
					continue;
				Connection.sendData(PacketClient.ROUND_SKILL_ACTION, PerkClothesFactory.ALCHEMIST_SHEEP, id, 1);
				delete this.victims[id];
			}
		}

		override public function get totalCooldown():Number
		{
			return COOLDOWN[this.perkLevel];
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundSkillAction.PACKET_ID]);
		}

		override public function dispose():void
		{
			for (var id:String in this.victims)
			{
				var victim:Hero = this.hero.game.squirrels.get(int(id));
				if (!victim)
					continue;
				victim.changeView();
				victim.isStoped = false;
			}
			this.victims = {};

			super.dispose();
		}

		override protected function get arrowMode():Boolean
		{
			return true;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
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

					var castObject:SheepBomb = new SheepBomb();
					castObject.angle = weaponAngle;
					castObject.position = new b2Vec2(roundSkill.scriptJson[2].x, roundSkill.scriptJson[2].y);
					castObject.playerId = this.hero.id;
					castObject.velocity = 100 * (Math.min(heroPoint.subtract(targetPoint).length, this.maxLength) / this.maxLength);
					(castObject as GameBody).linearVelocity = new b2Vec2(Math.cos(weaponAngle) * (castObject as IShoot).maxVelocity, Math.sin(weaponAngle) * (castObject as IShoot).maxVelocity);

					this.hero.game.map.add(castObject);
					castObject.build(this.hero.game.world);
					break;
				case PacketRoundSkillAction.PACKET_ID:
					var packetAction:PacketRoundSkillAction = packet as PacketRoundSkillAction;
					if (packetAction.type != this.code || packetAction.playerId != this.hero.id)
						return;
					var victim:Hero = this.hero.game.squirrels.get(packetAction.targetId);
					if (victim == null)
						return;

					if (packetAction.data == 0)
					{
						victim.changeView(this.skillView);
						victim.isStoped = true;

						this.victims[victim.id] = TIME;
						GameSounds.play("sheep_bomb");
					}
					else
					{
						victim.changeView();
						victim.isStoped = false;
					}
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function get skillView():Sprite
		{
			var sprite:StarlingAdapterSprite = new StarlingAdapterSprite();
			var view:StarlingAdapterMovie = new StarlingAdapterMovie(new SheepView());
			view.x = -int(view.width * 0.5);
			view.y = -int(view.height);
			view.play();
			sprite.addChildStarling(view);

			return sprite;
		}
	}
}