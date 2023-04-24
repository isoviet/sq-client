package game.mainGame.entity.magic
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.simple.SquareBody;

	import utils.starling.StarlingAdapterMovie;

	public class AnubisObelisk extends SquareBody implements ILifeTime, IPersonalObject
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(35 / Game.PIXELS_TO_METRE, 70 / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 7 * 1000;

		private var disposed:Boolean = false;

		public function AnubisObelisk():void
		{
			this.view = new StarlingAdapterMovie(new PerkAnubisView());
			this.view.x = -87;
			this.view.y = -114;
			(this.view as StarlingAdapterMovie).play();
			(this.view as StarlingAdapterMovie).loop = false;
			addChildStarling(this.view);

			this.fixed = true;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			super.build(world);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;
			if (!this.aging || this.disposed)
				return;

			this.lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.aging, this.lifeTime, this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.aging = Boolean(data[1][0]);
			this.lifeTime = data[1][1];
			this.playerId = data[1][2];
		}

		public function get personalId():int
		{
			return this.playerId;
		}

		public function breakContact(playerId:int):Boolean
		{
			return this.personalId == playerId;
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

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;
			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}