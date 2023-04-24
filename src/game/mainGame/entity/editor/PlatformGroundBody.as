package game.mainGame.entity.editor
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IDragable;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.simple.GameBody;

	import starling.display.Sprite;

	import utils.WorldQueryUtil;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class PlatformGroundBody extends Covered implements ISizeable, IDragable
	{
		static protected const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static protected const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static protected const MIN_WIDTH:int = 20;
		static protected const MIN_HEIGHT:int = 20;

		static protected const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		private var beginPoint:Point;
		private var scale:Number;
		protected var icon:StarlingAdapterSprite;
		protected var _width:Number = MIN_WIDTH;
		protected var _height:Number = MIN_HEIGHT;
		protected var drawSprite: flash.display.Sprite = new flash.display.Sprite();
		protected var drawStarlingSprite:StarlingAdapterSprite = new StarlingAdapterSprite();
		protected var platform:DisplayObject = null;

		public var friction:Number = 0.8;
		public var restitution:Number = 0.0;
		public var density:Number = 500;

		public var isFixed:Boolean = false;
		public var isStretch:Boolean = false;

		public function PlatformGroundBody():void
		{
			initIcon();
			addChildStarling(this.icon);

			this.fixed = true;
			this.defaultLandSound = "belka_land";
		}

		public function init(scale:Number):void
		{
			this.scale = scale;
			Game.stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		protected function get maskBits():uint
		{
			return MASK_BITS;
		}

		protected function get categories():uint
		{
			return CATEGORIES_BITS;
		}

		override public function build(world:b2World):void
		{
			if (!this.body)
			{
				this.body = world.CreateBody(BODY_DEF);
				this.body.SetUserData(this);

				var shape:b2PolygonShape = b2PolygonShape.AsOrientedBox((this._width / 2) / Game.PIXELS_TO_METRE, (this._height / 2) / Game.PIXELS_TO_METRE, new b2Vec2((this._width / 2) / Game.PIXELS_TO_METRE, (this._height / 2) / Game.PIXELS_TO_METRE));
				var fixtureDef:b2FixtureDef = new b2FixtureDef(shape, this, friction, restitution, density, this.categories, this.maskBits, 0);
				this.body.CreateFixture(fixtureDef);
			}

			super.build(world);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([[this._width, this._height], this.coverId, this.friction, this.restitution, this.density]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			if (GameBody.isOldStyle(data))
			{
				resize(data[3][0], data[3][1]);

				this.coverId = -1;
				if (4 in data)
					this.coverId = data[4][0];
			}
			else
			{
				resize(data[1][0][0], data[1][0][1]);

				this.coverId = data[1][1];
				this.friction = data[1][2];
				this.restitution = data[1][3];
				this.density = data[1][4];
			}
			draw();
		}

		override public function hitTestObject(obj:DisplayObject):Boolean
		{
			var a:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(0, 0));
			var b:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(0, this._height/Game.PIXELS_TO_METRE));
			var c:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(this._width/Game.PIXELS_TO_METRE, 0));
			var d:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(this._width / Game.PIXELS_TO_METRE, this._height / Game.PIXELS_TO_METRE));

			a.Multiply(Game.PIXELS_TO_METRE);
			b.Multiply(Game.PIXELS_TO_METRE);
			c.Multiply(Game.PIXELS_TO_METRE);
			d.Multiply(Game.PIXELS_TO_METRE);

			var selectionA:Point = new Point(obj.getRect(this.parent).x, obj.getRect(this.parent).y);
			var selectionB:Point = new Point(obj.getRect(this.parent).x, obj.getRect(this.parent).y + obj.height);
			var selectionC:Point = new Point(obj.getRect(this.parent).x + obj.width, obj.getRect(this.parent).y);
			var selectionD:Point = new Point(obj.getRect(this.parent).x +obj.width, obj.getRect(this.parent).y + obj.height);

			if (this.hitTestPoint(selectionA.x, selectionA.y, true) || (a.x > selectionA.x && a.x < selectionC.x && a.y > selectionA.y && a.y < selectionB.y))
				return true;

			return (Intersection(a.x, a.y, b.x, b.y, selectionA.x, selectionA.y, selectionB.x, selectionB.y) ||
				Intersection(a.x, a.y, b.x, b.y, selectionA.x, selectionA.y, selectionC.x, selectionC.y) ||
				Intersection(a.x, a.y, b.x, b.y, selectionC.x, selectionC.y, selectionD.x, selectionD.y) ||
				Intersection(a.x, a.y, b.x, b.y, selectionB.x, selectionB.y, selectionD.x, selectionD.y) ||

				Intersection(a.x, a.y, c.x, c.y, selectionA.x, selectionA.y, selectionB.x, selectionB.y) ||
				Intersection(a.x, a.y, c.x, c.y, selectionA.x, selectionA.y, selectionC.x, selectionC.y) ||
				Intersection(a.x, a.y, c.x, c.y, selectionC.x, selectionC.y, selectionD.x, selectionD.y) ||
				Intersection(a.x, a.y, c.x, c.y, selectionB.x, selectionB.y, selectionD.x, selectionD.y) ||

				Intersection(c.x, c.y, d.x, d.y, selectionA.x, selectionA.y, selectionB.x, selectionB.y) ||
				Intersection(c.x, c.y, d.x, d.y, selectionA.x, selectionA.y, selectionC.x, selectionC.y) ||
				Intersection(c.x, c.y, d.x, d.y, selectionC.x, selectionC.y, selectionD.x, selectionD.y) ||
				Intersection(c.x, c.y, d.x, d.y, selectionB.x, selectionB.y, selectionD.x, selectionD.y) ||

				Intersection(b.x, b.y, d.x, d.y, selectionA.x, selectionA.y, selectionB.x, selectionB.y) ||
				Intersection(b.x, b.y, d.x, d.y, selectionA.x, selectionA.y, selectionC.x, selectionC.y) ||
				Intersection(b.x, b.y, d.x, d.y, selectionC.x, selectionC.y, selectionD.x, selectionD.y) ||
				Intersection(b.x, b.y, d.x, d.y, selectionB.x, selectionB.y, selectionD.x, selectionD.y));
		}

		public function setSize(x:int, y:int):void
		{
			var vec:b2Vec2 = new b2Vec2(x / 5, y / 5);
			this.size = vec;

			if (this.body)
			{
				var fixture:b2Fixture = body.GetFixtureList();
				if (!fixture)
					return;

				this.body.DestroyFixture(fixture);

				var shape:b2PolygonShape = b2PolygonShape.AsOrientedBox((this._width / 2) / Game.PIXELS_TO_METRE, (this._height / 2) / Game.PIXELS_TO_METRE, new b2Vec2((this._width / 2) / Game.PIXELS_TO_METRE, (this._height / 2) / Game.PIXELS_TO_METRE));
				var fixtureDef:b2FixtureDef = new b2FixtureDef(shape, this, friction, restitution, density, this.categories, this.maskBits, 0);
				this.body.CreateFixture(fixtureDef);
			}
		}

		public function get size():b2Vec2
		{
			return new b2Vec2(_width / 5, _height / 5);
		}

		public function set size(value:b2Vec2):void
		{
			resize(value.x * 5, value.y * 5);
		}

		protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new PlatformGround());
		}

		protected function draw():void
		{
			while (numChildren > 0)
				removeChildStarlingAt(0);

			if (!this.platform)
				initPlatformBD();

			var img: starling.display.Sprite = StarlingConverter.imageWithTextureFill(this.platform, this._width, this._height);
			this._width =  Math.ceil(this._width / this.platform.width) * this.platform.width;
			this._height =  Math.ceil(this._height / this.platform.height) * this.platform.height;

			addChildStarling(img);

			if (this.coverId != -1)
				drawCover(this._width);

			if (containsStarling(this.icon))
				removeChildStarling(this.icon);
		}

		protected function initPlatformBD():void
		{
			this.platform = new PlatformGround();
		}

		protected function resize(width:int, height:int):void
		{
			width = Math.max(MIN_WIDTH, width);
			height = Math.max(MIN_HEIGHT, height);

			width = Math.min(width, 1024);
			height = Math.min(height, 1024);

			this._width = width;
			this._height = height;

			draw();
		}

		private function Intersection(ax1:int, ay1:int, ax2:int, ay2:int, bx1:int, by1:int, bx2:int, by2:int):Boolean
		{
			var v1:Number = (bx2 - bx1) * (ay1 - by1) - (by2 - by1) * (ax1 - bx1);
			var v2:Number = (bx2 - bx1) * (ay2 - by1) - (by2 - by1) * (ax2 - bx1);
			var v3:Number = (ax2 - ax1) * (by1 - ay1) - (ay2 - ay1) * (bx1 - ax1);
			var v4:Number = (ax2 - ax1) * (by2 - ay1) - (ay2 - ay1) * (bx2 - ax1);
			return ((v1 * v2 <= 0) && (v3 * v4 <= 0));
		}

		private function fix():void
		{
			this.isFixed = true;
			this.isStretch = false;
		}

		private function onClick(e:MouseEvent):void
		{
			if (this.isFixed)
			{
				Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				Game.stage.removeEventListener(MouseEvent.CLICK, onClick);
				return;
			}

			fix();

			Game.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.beginPoint = new Point(e.stageX, e.stageY);
			resize(MIN_WIDTH, MIN_HEIGHT);

			if (containsStarling(this.icon))
				removeChildStarling(this.icon);
		}

		private function onMove(e:MouseEvent):void
		{
			resize((e.stageX - this.beginPoint.x) / this.scale, (e.stageY - this.beginPoint.y) / this.scale);
		}
	}
}