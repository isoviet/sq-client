package game.mainGame.entity.magic
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.behaviours.StateStun;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.simple.GameBody;

	import utils.starling.StarlingAdapterMovie;

	public class AmericaShield extends GameBody implements ILifeTime
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(2 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 1.0, 0.5, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static public const MAX_VELOCITY:int = 100;

		public var direction:Boolean = false;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 2 * 1000;

		private var disposed:Boolean = false;

		private var controller:b2ConstantAccelController;
		private var view:StarlingAdapterMovie;

		private var victims:Array = [];

		public function AmericaShield()
		{
			this.view = new StarlingAdapterMovie(new CaptainAmericaPerkView());
			this.view.visible = false;
			this.view.scaleX = this.view.scaleY = 0.5;
			addChildStarling(this.view);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			this.body.SetBullet(true);

			super.build(world);

			if (!this.builded)
				this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(this.direction ? -MAX_VELOCITY : MAX_VELOCITY, 0)));

			this.view.visible = true;
			this.view.loop = true;
			this.view.play();

			this.controller = new b2ConstantAccelController();
			this.controller.A = world.GetGravity().GetNegative();
			this.controller.AddBody(this.body);
			world.AddController(this.controller);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;
			if (!this.aging || this.disposed)
				return;

			for each (var hero:Hero in this.gameInst.squirrels.players)
			{
				if (hero.id == this.playerId || hero.isDead || hero.inHollow || this.victims.indexOf(hero.id) != -1)
					continue;
				var pos:b2Vec2 = this.position.Copy();
				pos.Subtract(hero.position);
				if (pos.Length() > 4)
					continue;
				this.victims.push(hero.id);
				hero.behaviourController.addState(new StateStun(1.0));
			}

			this.lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.aging, this.lifeTime, this.playerId, this.victims, this.direction]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.aging = Boolean(data[1][0]);
			this.lifeTime = data[1][1];
			this.playerId = data[1][2];
			this.victims = data[1][3];
			this.direction = data[1][4];
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