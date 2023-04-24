package game.mainGame.entity.editor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IJumpable;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.simple.GameBody;
	import sensors.ISensor;

	import utils.WorldQueryUtil;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class Branch extends GameBody implements ISizeable, ISensor, IJumpable
	{
		static private const MIN_SIZE:Number = 20 / Game.PIXELS_TO_METRE;
		static private const MAX_SIZE:Number = 380 / Game.PIXELS_TO_METRE;

		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.8, 0.1, 10000, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		protected var originBranchView:Sprite;

		protected var branchView:StarlingAdapterSprite = new StarlingAdapterSprite();
		protected var branchMask:Shape = new Shape();
		private var _size:b2Vec2 = new b2Vec2();

		public function Branch():void
		{
			init();
		}

		protected function init():void
		{
			this.addChildStarling(branchView);

			this.originBranchView = new BranchView();
			this.originBranchView.x = -3;
			this.originBranchView.y = 0;
			this.originBranchView.mask = this.branchMask;

			size = new b2Vec2(MAX_SIZE, 0);

			this.branchMask.graphics.beginFill(0x000000);
			this.branchMask.graphics.drawRect(0, 0, 1, this.originBranchView.height);
			this.branchMask.graphics.endFill();
			this.originBranchView.addChild(this.branchMask);

			this.fixed = true;
			updateViewBranch();
		}

		protected function updateViewBranch(): void {
			var mx: Matrix = new Matrix();

			while(branchView.numChildren > 0)
				branchView.removeChildStarlingAt(0);

			var rect:Rectangle = this.originBranchView.getBounds(this.originBranchView);

			var b:BitmapData = new BitmapData(rect.width * StarlingConverter.scaleFactor, rect.height * StarlingConverter.scaleFactor, true, 0x0);
			mx.scale(this.originBranchView.scaleX * StarlingConverter.scaleFactor, this.originBranchView.scaleY * StarlingConverter.scaleFactor);
			if (this.originBranchView.scaleY < 0) {
				mx.translate(0, rect.height);
			}

			b.draw(this.originBranchView, mx);

			var bitmap:Bitmap = new Bitmap(b);
			branchView.alignPivot();

			if (this.originBranchView.scaleY < 0) {
				branchView.pivotY = rect.height / StarlingConverter.scaleFactor;
			}

			bitmap.x = this.originBranchView.x * StarlingConverter.scaleFactor;

			var item: StarlingAdapterSprite = new StarlingAdapterSprite(bitmap);
			item.getStarlingView().scaleX = item.getStarlingView().scaleY = 1 / StarlingConverter.scaleFactor;
			branchView.addChildStarling(item);
		}

		override public function hitTestObject(obj:DisplayObject):Boolean
		{
			var selectionA:Point = new Point(obj.getRect(this.parent).x, obj.getRect(this.parent).y);
			var selectionB:Point = new Point(obj.getRect(this.parent).x, obj.getRect(this.parent).y + obj.height);
			var selectionC:Point = new Point(obj.getRect(this.parent).x + obj.width, obj.getRect(this.parent).y);
			var selectionD:Point = new Point(obj.getRect(this.parent).x + obj.width, obj.getRect(this.parent).y + obj.height);

			var a:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(-this._size.x / 2, 0));
			var b:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(this._size.x / 2, 0));
			var c:b2Vec2 = WorldQueryUtil.GetWorldPoint(this, new b2Vec2(this._size.x / 2, this._size.y));
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
			var shape:b2PolygonShape = b2PolygonShape.AsBox(size.x / 2, 0.1);
			this.fixture.shape = shape;
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(this.fixture).SetUserData(this);
			super.build(world);
		}

		protected function get fixture():b2FixtureDef
		{
			return FIXTURE_DEF;
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			if (contact.GetFixtureB().GetUserData() == this)
				contact.SetEnabled(maniFold.m_normal.y >= 0);
			else
				contact.SetEnabled(!(maniFold.m_normal.y >= 0));
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{

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

		override public function set rotation(value:Number):void
		{
			var newScale: int = Math.abs(value) > 90 ? -1 : 1;

			if (newScale != this.originBranchView.scaleY) {
				this.originBranchView.scaleY = newScale;
				updateViewBranch();
			}

			super.rotation = value;
		}

		override public function dispose():void
		{
			super.dispose();
			if (!this.originBranchView)
				return;

			this.originBranchView.mask = null;
			this.originBranchView = null;
		}

		public function get size():b2Vec2
		{
			return _size;
		}

		public function set size(value:b2Vec2):void
		{
			_size.x = Math.max(Math.min(value.x, MAX_SIZE), MIN_SIZE);
			_size.y = 0;
			branchMask.scaleX = size.x * Game.PIXELS_TO_METRE;
			originBranchView.x = - _size.x / 2 * Game.PIXELS_TO_METRE;
			updateViewBranch();
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