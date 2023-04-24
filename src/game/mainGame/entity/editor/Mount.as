package game.mainGame.entity.editor
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILandSound;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.simple.GameBody;

	import utils.WorldQueryUtil;
	import utils.starling.StarlingAdapterSprite;

	public class Mount extends GameBody implements ISizeable, ILandSound
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.8, 0.1, 500, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const DEFAULT_WIDTH:Number = 300 / Game.PIXELS_TO_METRE;
		static private const DEFAULT_HEIGHT:Number = 300 / Game.PIXELS_TO_METRE;

		static private const MIN_WIDTH:Number = 50 / Game.PIXELS_TO_METRE;
		static private const MIN_HEIGHT:Number = 50 / Game.PIXELS_TO_METRE;

		static private const MAX_WIDTH:Number = 500 / Game.PIXELS_TO_METRE;
		static private const MAX_HEIGHT:Number = 500 / Game.PIXELS_TO_METRE;

		private var _size:b2Vec2 = new b2Vec2(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		private var view:StarlingAdapterSprite = new StarlingAdapterSprite();

		private var fixtureDef:b2FixtureDef;
		private var defaultWidth:Number;
		private var defaultHeight:Number;

		private var bitmapData:BitmapData = null;
		private var convertView: StarlingAdapterSprite;

		public function Mount(view:DisplayObject = null, fixtureDef:b2FixtureDef = null, defaultWidth:Number = NaN, defaultHeight:Number = NaN):void
		{
			if (view == null) {
				convertView = new StarlingAdapterSprite(new MountView());
			} else {
				convertView = new StarlingAdapterSprite(view);
			}

			this.fixtureDef = fixtureDef ? fixtureDef : FIXTURE_DEF;
			this.defaultWidth = !isNaN(defaultWidth) ? defaultWidth : DEFAULT_WIDTH;
			this.defaultHeight = !isNaN(defaultHeight) ? defaultHeight : DEFAULT_HEIGHT;
			this._size = new b2Vec2(this.defaultWidth, this.defaultHeight);

			addChildStarling(convertView);

			this.fixed = true;
		}

		public function get landSound():String
		{
			return "belka_land";
		}

		override public function dispose():void
		{
			super.dispose();

			if (!this.bitmapData)
				return;
			this.bitmapData.dispose();
			this.bitmapData = null;
		}

		override public function hitTestObject(obj:DisplayObject):Boolean
		{
			var selectionA:Point = new Point(obj.getRect(this.parent).x, obj.getRect(this.parent).y);
			var selectionB:Point = new Point(obj.getRect(this.parent).x, obj.getRect(this.parent).y + obj.height);
			var selectionC:Point = new Point(obj.getRect(this.parent).x + obj.width, obj.getRect(this.parent).y);
			var selectionD:Point = new Point(obj.getRect(this.parent).x + obj.width, obj.getRect(this.parent).y + obj.height);

			var a:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(-this._size.x / 2, this._size.y / 2));
			var b:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(0, -this._size.y / 2));
			var c:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(this._size.x / 2, this._size.y / 2));
			a.Multiply(Game.PIXELS_TO_METRE);
			b.Multiply(Game.PIXELS_TO_METRE);
			c.Multiply(Game.PIXELS_TO_METRE);

			if(this.hitTestPoint(selectionA.x, selectionA.y, true) || (a.x > selectionA.x && a.x < selectionC.x && a.y > selectionA.y && a.y < selectionB.y))
				return true;
			else
				return (Intersection(a.x, a.y, b.x, b.y, selectionA.x, selectionA.y, selectionB.x, selectionB.y) ||
				Intersection(a.x, a.y, b.x, b.y, selectionA.x, selectionA.y, selectionC.x, selectionC.y) ||
				Intersection(a.x, a.y, b.x, b.y, selectionC.x, selectionC.y, selectionD.x, selectionD.y) ||
				Intersection(a.x, a.y, b.x, b.y, selectionB.x, selectionB.y, selectionD.x, selectionD.y) ||

				Intersection(b.x, b.y, c.x, c.y, selectionA.x, selectionA.y, selectionB.x, selectionB.y) ||
				Intersection(b.x, b.y, c.x, c.y, selectionA.x, selectionA.y, selectionC.x, selectionC.y) ||
				Intersection(b.x, b.y, c.x, c.y, selectionC.x, selectionC.y, selectionD.x, selectionD.y) ||
				Intersection(b.x, b.y, c.x, c.y, selectionB.x, selectionB.y, selectionD.x, selectionD.y) ||

				Intersection(a.x, a.y, c.x, c.y, selectionA.x, selectionA.y, selectionB.x, selectionB.y) ||
				Intersection(a.x, a.y, c.x, c.y, selectionA.x, selectionA.y, selectionC.x, selectionC.y) ||
				Intersection(a.x, a.y, c.x, c.y, selectionC.x, selectionC.y, selectionD.x, selectionD.y) ||
				Intersection(a.x, a.y, c.x, c.y, selectionB.x, selectionB.y, selectionD.x, selectionD.y));
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
			this.rotation = rotation;
			this.ghost = ghost;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([[this.size.x, this.size.y]]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			if (GameBody.isOldStyle(data))
				this.size = new b2Vec2(data[3][0], data[3][1]);
			else
				this.size = new b2Vec2(data[1][0][0], data[1][0][1]);
		}

		public function get size():b2Vec2
		{
			return this._size;
		}

		public function set size(value:b2Vec2):void
		{
			this._size.x = Math.max(Math.min(MAX_WIDTH, value.x), MIN_WIDTH);
			this._size.y = Math.max(Math.min(MAX_HEIGHT, value.y), MIN_HEIGHT);

			this.convertView.scaleX = this.size.x / this.defaultWidth;
			this.convertView.scaleY = this.size.y / this.defaultHeight;
		}

		protected function get points():Vector.<b2Vec2>
		{
			var result:Vector.<b2Vec2> = new Vector.<b2Vec2>;
			result.push(new b2Vec2(0, -this.size.y / 2));
			result.push(new b2Vec2(this.size.x / 2, this.size.y / 2));
			result.push(new b2Vec2(-this.size.x / 2, this.size.y / 2));
			return result;
		}

		private function Intersection(ax1:int, ay1:int, ax2:int, ay2:int, bx1:int, by1:int, bx2:int, by2:int):Boolean
		{
			var v1:Number = (bx2 - bx1) * (ay1 - by1) - (by2 - by1) * (ax1 - bx1);
			var v2:Number = (bx2 - bx1) * (ay2 - by1) - (by2 - by1) * (ax2 - bx1);
			var v3:Number = (ax2 - ax1) * (by1 - ay1) - (ay2 - ay1) * (bx1 - ax1);
			var v4:Number = (ax2 - ax1) * (by2 - ay1) - (ay2 - ay1) * (bx2 - ax1);
			return ((v1 * v2 <= 0) && (v3 * v4 <= 0));
		}
	}
}