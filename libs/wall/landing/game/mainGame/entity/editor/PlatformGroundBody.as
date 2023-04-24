package landing.game.mainGame.entity.editor
{
	import flash.display.BitmapData;
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

	import landing.game.mainGame.CollisionGroup;

	import utils.ImageUtil;

	public class PlatformGroundBody extends Covered
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const MIN_WIDTH:int = 20;
		static private const MIN_HEIGHT:int = 20;

		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		protected var icon:DisplayObject;
		protected var _width:Number;
		protected var _height:Number;
		protected var drawSprite:Sprite = new Sprite();
		protected var platform:BitmapData = null;

		private var shadow:DisplayObject = null;
		private var beginPoint:Point;

		public var isFixed:Boolean = false;
		public var isStretch:Boolean = false;

		public function PlatformGroundBody():void
		{
			initIcon();
			addChild(this.icon);
			addChild(this.drawSprite);
			this.fixed = true;
		}

		public function init():void
		{
			WallShadow.stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);

			var shape:b2PolygonShape = b2PolygonShape.AsOrientedBox((this._width / 2) / WallShadow.PIXELS_TO_METRE, (this._height / 2) / WallShadow.PIXELS_TO_METRE, new b2Vec2((this._width / 2) / WallShadow.PIXELS_TO_METRE, (this._height / 2) / WallShadow.PIXELS_TO_METRE))
			var fixtureDef:b2FixtureDef = new b2FixtureDef(shape, null, 0.8, 0.0, 500, CATEGORIES_BITS, MASK_BITS, 0);
			var shapeFixture:b2Fixture = body.CreateFixture(fixtureDef);

			this.body.CreateFixture(fixtureDef);
			super.build(world);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this._width, this._height]);
			result.push([this.coverId]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			resize(data[3][0], data[3][1]);

			this.coverId = -1;
			if (4 in data)
				this.coverId = data[4][0];
			draw();
		}

		protected function initIcon():void
		{
			this.icon = new PlatformGround();
		}

		protected function draw():void
		{
			if (contains(this.icon))
				removeChild(this.icon);

			if (this.platform == null)
			{
				initPlatformBD();
				this.shadow = new MaskPlatform();
				addChild(this.shadow);
			}

			this.shadow.width = this._width;
			this.shadow.height = this._height;

			this.drawSprite.graphics.clear();
			this.drawSprite.graphics.beginBitmapFill(this.platform, null, true);
			this.drawSprite.graphics.drawRect(0, 0, this._width, this._height);
			this.drawSprite.graphics.endFill();

			if (this.coverId != -1)
				drawCover(this._width);

			if (contains(this.icon))
				removeChild(this.icon);
		}

		protected function initPlatformBD():void
		{
			this.platform = ImageUtil.getBitmapData(new PlatformGround());
		}

		private function beginStretch():void
		{
			this.isStretch = true;
			this.isFixed = false;
		}

		private function fix():void
		{
			this.isFixed = true;
			this.isStretch = false;
		}

		private function onClick(e:MouseEvent):void
		{
			if (!this.isFixed)
			{
				fix();

				WallShadow.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				this.beginPoint = new Point(e.stageX, e.stageY);
				resize(MIN_WIDTH, MIN_HEIGHT);

				if (contains(this.icon))
					removeChild(this.icon);
			}
			else
			{
				WallShadow.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				WallShadow.stage.removeEventListener(MouseEvent.CLICK, onClick);
			}
		}

		private function onMove(e:MouseEvent):void
		{
			resize(e.stageX - this.beginPoint.x, e.stageY - this.beginPoint.y);
		}

		private function resize(width:int, height:int):void
		{
			width = Math.max(MIN_WIDTH, width);
			height = Math.max(MIN_HEIGHT, height);

			this._width = width;
			this._height = height;

			draw();
		}
	}
}