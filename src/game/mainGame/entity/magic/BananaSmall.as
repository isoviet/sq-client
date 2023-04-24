package game.mainGame.entity.magic
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.behaviours.StateBanana;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.PerkClothesFactory;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundSkillAction;

	import utils.starling.StarlingAdapterSprite;

	public class BananaSmall extends GameBody implements ILifeTime
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_NONE_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(1 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 10, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, true, b2Body.b2_dynamicBody);

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 5 * 1000;
		private var disposed:Boolean = false;

		private var view:StarlingAdapterSprite;

		public var currentId:int = 0;

		public function BananaSmall()
		{
			this.view = new StarlingAdapterSprite(new MinionPerkView());
			this.view.scaleX = this.view.scaleY = 0.7;
			addChildStarling(this.view);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;

			if (!this.aging || this.disposed)
				return;

			if (this.gameInst.squirrels.isSynchronizing)
			{
				this._lifeTime -= timeStep * 1000;

				if (lifeTime <= 0)
					destroy();
			}

			if (Hero.selfAlive)
			{
				if (Hero.self.behaviourController.getState(StateBanana) != null)
					return;
				var pos:b2Vec2 = Hero.self.position.Copy();
				pos.Subtract(this.position);
				if (pos.Length() < 4)
				{
					Connection.sendData(PacketClient.ROUND_SKILL_ACTION, PerkClothesFactory.MINION, this.playerId, this.currentId);
					this.view.visible = false;
					return;
				}
			}

		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);
			this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(0, -20)));

			Connection.listen(onPacket, [PacketRoundSkillAction.PACKET_ID]);
		}

		private function onPacket(packet:PacketRoundSkillAction):void
		{
			if (this.disposed)
				return;
			if (packet.type != PerkClothesFactory.MINION)
				return;
			if (packet.targetId != this.playerId)
				return;
			if (packet.data != this.currentId)
				return;
			var hero:Hero = this.gameInst.squirrels.get(packet.playerId);
			if (hero)
				hero.behaviourController.addState(new StateBanana(5));
			destroy();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.lifeTime, this.playerId, this.currentId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.lifeTime = data[1][0];
			this.playerId = data[1][1];
			this.currentId = data[1][2];
		}

		public function get aging():Boolean
		{
			return this._aging;
		}

		public function set aging(value:Boolean):void
		{
			this._aging = value;
		}

		public function get lifeTime():Number
		{
			return this._lifeTime;
		}

		public function set lifeTime(value:Number):void
		{
			this._lifeTime = value;
		}

		override public function dispose():void
		{
			super.dispose();

			Connection.forget(onPacket, [PacketRoundSkillAction.PACKET_ID]);
		}

		private function destroy():void
		{
			if (this.disposed)
				return;
			this.disposed = true;
			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}