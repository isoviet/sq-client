package landing.game.mainGame.entity.editor
{
	import flash.display.DisplayObject;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.CollisionGroup;
	import landing.game.mainGame.entity.simple.GameBody;
	import landing.game.mainGame.entity.ISizeable

	public class Stone extends GameBody implements ISizeable
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY ;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.8, 0.1, 3, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const DEFAULT_WIDTH:Number = 44.95 / WallShadow.PIXELS_TO_METRE;
		static private const DEFAULT_HEIGHT:Number = 44.45 / WallShadow.PIXELS_TO_METRE;

		private static const MIN_SIZE:Number = 10 / WallShadow.PIXELS_TO_METRE;
		private static const MAX_SIZE:Number = 300 / WallShadow.PIXELS_TO_METRE;

		private var _size:b2Vec2 = new b2Vec2(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		private var view:DisplayObject = new StoneView();

		public function Stone()
		{
			addChild(view);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			var shape:b2CircleShape = new b2CircleShape(this.size.x / 2);
			FIXTURE_DEF.shape = shape;
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			super.build(world);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([[size.x, size.y]]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			this.size = new b2Vec2(data[3][0][0], data[3][0][1]);
		}

		public function get size():b2Vec2
		{
			return _size;
		}

		public function set size(value:b2Vec2):void
		{
			value.x = value.y = Math.max(Math.min(value.x, value.y, MAX_SIZE), MIN_SIZE);
			_size = value;
			this.view.scaleX = this.size.x / DEFAULT_WIDTH;
			this.view.scaleY = this.size.y / DEFAULT_HEIGHT;
		}
	}
}