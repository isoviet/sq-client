package game.mainGame.entity.simple
{
	import flash.display.BitmapData;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.PinUtil;

	import utils.starling.StarlingAdapterSprite;

	public class Wheel extends GameBody implements ISizeable, IPinable
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.8, 0.2, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const DEFAULT_WIDTH:Number = 65 / Game.PIXELS_TO_METRE;
		static private const DEFAULT_HEIGHT:Number = 65 / Game.PIXELS_TO_METRE;

		static private const MIN_SIZE:Number = 30 / Game.PIXELS_TO_METRE;
		static private const MAX_SIZE:Number = 300 / Game.PIXELS_TO_METRE;

		static private const PINS:Array = [[0, 0]];

		private var _size:b2Vec2 = new b2Vec2(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		private var view:StarlingAdapterSprite = null;

		private var bitmapData:BitmapData = null;

		public var density:Number = 1;

		public function Wheel():void
		{
			this.view = new StarlingAdapterSprite(new WheelImg());
			addChildStarling(this.view);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			var shape:b2CircleShape = new b2CircleShape(this.size.x / 2);
			FIXTURE_DEF.shape = shape;
			FIXTURE_DEF.density = this.density;
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			super.build(world);

			if (!this.cacheBitmap)
				rasterize();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([[size.x, size.y], this.density]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.size = new b2Vec2(data[1][0][0], data[1][0][1]);
			this.density = data[1][1];
		}

		public function get size():b2Vec2
		{
			return _size;
		}

		public function set size(value:b2Vec2):void
		{
			value.x = value.y = Math.max(Math.min(Math.max(value.x, value.y), MAX_SIZE), MIN_SIZE);
			_size = value;
			this.view.scaleX = this.size.x / DEFAULT_WIDTH;
			this.view.scaleY = this.size.y / DEFAULT_HEIGHT;
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}

		override public function dispose():void
		{
			super.dispose();

			this.removeFromParent();

			if (!this.bitmapData)
				return;

			this.bitmapData.dispose();
			this.bitmapData = null;
		}

		private function rasterize():void
		{
			var rotation:Number = this.rotation;
			this.rotation = 0;

			var ghost:Boolean = this.ghost;
			this.ghost = false;
			/*
			var bounds:Rectangle = this.getBounds(this);
			this.bitmapData = new BitmapData(this.width, this.height, true, 0x00FFFFFF);
			this.bitmapData.draw(this, new Matrix(1, 0, 0, 1, this.width / 2, this.height / 2));

			while (this.numChildren > 0)
				removeChildAt(0);

			var bitmap:Bitmap = new Bitmap(this.bitmapData);
			bitmap.x = bounds.x;
			bitmap.y = bounds.y;
			bitmap.smoothing = true;

			addChild(bitmap);*/

			this.rotation = rotation;
			this.ghost = ghost;
		}
	}
}