package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.editor.PlatformGroundBody;
	import game.mainGame.entity.simple.AcornBody;
	import game.mainGame.entity.simple.CollectionElement;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.simple.HollowBody;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkillAction;

	import utils.starling.particleSystem.CollectionEffects;

	public class PerkClothesFlash extends PerkClothes
	{
		private static const SPEED_VALUE:Number = 2;
		static private const RADIUS:Number = 40 / Game.PIXELS_TO_METRE;
		static private const LINEAR_VELOCITY:Number = -50;

		private var squirrels:Array = [];
		private var _vecImpulse: b2Vec2 = new b2Vec2(0, LINEAR_VELOCITY);
		private var changeSpeed: Boolean = false;

		public function PerkClothesFlash(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_ACCELERATION;
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.active || this.hero.id != Game.selfId)
				return;
			findVictims();
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundSkillAction.PACKET_ID]);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			var body: GameBody;
			var gameBody: * = null;
			var pos:b2Vec2 = null;

			switch (packet.packetId)
			{
				case PacketRoundSkillAction.PACKET_ID:
					var action:PacketRoundSkillAction = packet as PacketRoundSkillAction;
					if (action.type != this.code || this.hero.id == action.playerId)
						return;

					switch (action.data)
					{
						case 2:
							for (var i:int = 0, len:int = this.hero.game.map.gameObjects().length; i < len; i++)
							{
								gameBody = this.hero.game.map.gameObjects()[i];
								if (gameBody && gameBody is GameBody &&
									gameBody.visible && !(gameBody is PlatformGroundBody) &&
									!(gameBody is AcornBody) && !(gameBody is CollectionElement) &&
									!(gameBody is HollowBody))
								{

									body = gameBody;
									if (body && body.id == action.targetId)
										body.body.SetLinearVelocity(this.hero.body.GetWorldVector(_vecImpulse));
								}
							}
							break;
						case 1:
							var hero:Hero = this.hero.game.squirrels.get(action.targetId);
							hero.body.SetLinearVelocity(this.hero.body.GetWorldVector(_vecImpulse));
							break;
					}
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.runSpeed *= SPEED_VALUE;
			this.changeSpeed = true;

			this.hero.applyEffect(CollectionEffects.EFFECTS_LIGHTNING);
			this.hero.applyEffect(CollectionEffects.EFFECTS_LIGHTNING_TAIL, -1);

			for each(var hero:Hero in this.hero.game.squirrels.players)
			{
				if (hero.isSelf || hero.isHare || hero.inHollow)
					continue;
				this.squirrels.push(hero);
			}
		}

		override protected function deactivate():void
		{
			this.squirrels = [];

			super.deactivate();

			if (this.changeSpeed)
			{
				this.hero.runSpeed /= SPEED_VALUE;
				this.changeSpeed = false;
			}

			this.hero.disableEffect(CollectionEffects.EFFECTS_LIGHTNING);
			this.hero.disableEffect(CollectionEffects.EFFECTS_LIGHTNING_TAIL);
		}

		private function findVictims():void
		{
			var len:int = this.squirrels.length;
			var pos:b2Vec2 = null;
			var hero:Hero;

			if (Math.abs(this.hero.velocity.Length()) < 10)
				return;

			while(len--)
			{
				hero = this.squirrels[len];

				if (hero.inHollow || hero.isDead)
					continue;

				pos = this.hero.position.Copy();
				pos.Subtract(hero.position);

				if (pos.Length() > RADIUS)
					continue;

				hero.body.SetLinearVelocity(this.hero.body.GetWorldVector(_vecImpulse));
				Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, hero.id, 1);
			}

			findObject();
		}

		private function findObject():void
		{
			var body: GameBody;
			var gameBody: * = null;
			var pos:b2Vec2 = null;

			for (var i: int = 0, len: int = this.hero.game.map.gameObjects().length; i < len; i++)
			{
				gameBody = this.hero.game.map.gameObjects()[i];
				if (gameBody && gameBody is GameBody &&
					gameBody.visible && !(gameBody is PlatformGroundBody) &&
					!(gameBody is AcornBody) && !(gameBody is CollectionElement) &&
					!(gameBody is HollowBody)) {

					body = gameBody;

					pos = this.hero.position.Copy();
					pos.Subtract(body.position);

					if (pos.Length() > RADIUS)
						continue;

					body.body.SetLinearVelocity(this.hero.body.GetWorldVector(_vecImpulse));
					Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, body.id, 2);
				}
			}
		}

	}
}