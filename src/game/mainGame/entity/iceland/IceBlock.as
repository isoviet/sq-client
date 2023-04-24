package game.mainGame.entity.iceland
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.simple.GameBody;

	import utils.starling.StarlingAdapterMovie;

	public class IceBlock extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(32 / Game.PIXELS_TO_METRE, 16 / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const TIMES:Array = [30.0, 20.0, 10.0, 0.0];
		static private const VIEWS:Array = [IceBlockView0, IceBlockView1, IceBlockView2];

		private var timeLife:Number;

		public var views:Array = [];

		public function IceBlock():void
		{
			super(body);

			for (var i:int = 0; i < VIEWS.length; i++)
			{
				var viewClass:Class = VIEWS[i];
				this.views.push(addChildStarling(new StarlingAdapterMovie(new viewClass)));
				this.views[i].x = -32;
				this.views[i].y = -16;
				this.views[i].visible = false;
			}
			this.views[0].visible = true;

			this.fixed = true;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body || this.timeLife <= 0)
				return;
			this.timeLife -= timeStep;
			for (var i:int = 0; i < this.views.length; i++)
			{
				this.views[i].visible = TIMES[i] > this.timeLife && this.timeLife >= TIMES[i + 1];
				if (this.views[i])
					this.views[i].play();
			}

			if (this.timeLife <= 0)
				this.gameInst.map.destroyObjectSync(this, true);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			super.build(world);

			this.timeLife = TIMES[0];
		}

		override public function set angle(value:Number):void
		{}
	}
}