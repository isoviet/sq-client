package landing.game.mainGame.entity.editor
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.CollisionGroup;
	import landing.game.mainGame.entity.ISizeable;
	import landing.game.mainGame.entity.simple.GameBody;

	public class Mount extends GameBody implements ISizeable
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY ;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.8, 0.1, 500, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const DEFAULT_WIDTH:Number = 300 / WallShadow.PIXELS_TO_METRE;
		static private const DEFAULT_HEIGHT:Number = 300 / WallShadow.PIXELS_TO_METRE;

		static private const MIN_WIDTH:Number = 50 / WallShadow.PIXELS_TO_METRE;
		static private const MIN_HEIGHT:Number = 50 / WallShadow.PIXELS_TO_METRE;

		private var _size:b2Vec2 = new b2Vec2(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		private var view:Sprite = new Sprite();

		private var fixtureDef:b2FixtureDef;
		private var defaultWidth:Number;
		private var defaultHeight:Number;

		public function Mount(view:DisplayObject = null, fixtureDef:b2FixtureDef = null, defaultWidth:Number = NaN, defaultHeight:Number = NaN):void
		{
			if (view == null)
				view = new MountView();

			this.fixtureDef = fixtureDef ? fixtureDef : FIXTURE_DEF;
			this.defaultWidth = !isNaN(defaultWidth) ? defaultWidth : DEFAULT_WIDTH;
			this.defaultHeight = !isNaN(defaultHeight) ? defaultHeight : DEFAULT_HEIGHT;
			this._size = new b2Vec2(this.defaultWidth, this.defaultHeight);

			this.view.addChild(view);
			addChild(this.view);

			this.fixed = true;
		}

		override public function build(world:b2World):void
		{
			var vector:Vector.<b2Vec2> = this.points;
			var shape:b2PolygonShape = b2PolygonShape.AsVector(vector, vector.length);
			this.fixtureDef.shape = shape;
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(this.fixtureDef);
			super.build(world);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.size.x, this.size.y]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			this.size = new b2Vec2(data[3][0], data[3][1]);
		}

		public function get size():b2Vec2
		{
			return this._size;
		}

		public function set size(value:b2Vec2):void
		{
			this._size.x = value.x >= MIN_WIDTH ? value.x : this._size.x;
			this._size.y = value.y >= MIN_HEIGHT ? value.y : this._size.y;
			this.view.scaleX = this.size.x / this.defaultWidth;
			this.view.scaleY = this.size.y / this.defaultHeight;
		}

		protected function get points():Vector.<b2Vec2>
		{
			var result:Vector.<b2Vec2> = new Vector.<b2Vec2>;
			result.push(new b2Vec2(0, -this.size.y / 2));
			result.push(new b2Vec2(this.size.x / 2, this.size.y / 2));
			result.push(new b2Vec2(-this.size.x / 2, this.size.y / 2));
			return result;
		}
	}
}