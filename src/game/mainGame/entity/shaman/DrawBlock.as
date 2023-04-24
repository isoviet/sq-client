package game.mainGame.entity.shaman
{
	import flash.display.Shape;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.Cast;
	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.cast.ICastChange;
	import game.mainGame.entity.cast.ICastDrawable;
	import game.mainGame.entity.simple.SquareBody;

	import com.greensock.TweenMax;

	import utils.starling.StarlingAdapterSprite;

	public class DrawBlock extends SquareBody implements ICastChange, ICastDrawable, ILifeTime
	{
		static private const BLOCK_SIZE:int = 10 / Game.PIXELS_TO_METRE;

		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(BLOCK_SIZE / 2, BLOCK_SIZE / 2, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, -1);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private var shape: Shape = null;

		private var _cast:Cast = null;
		private var oldCastTime:Number;

		private var oldRunCast:Boolean = false;
		private var tail:b2Vec2 = null;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 0;
		private var disposed:Boolean = false;

		public var useRunCast:Boolean = false;

		public function DrawBlock():void
		{

			if (shape == null)
			{
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0xCD00CD);
				shape.graphics.drawRect(0, 0, BLOCK_SIZE * Game.PIXELS_TO_METRE, BLOCK_SIZE * Game.PIXELS_TO_METRE);
				shape.graphics.endFill();
			}

			this.view = new StarlingAdapterSprite(shape, true);
			view.x = -BLOCK_SIZE * Game.PIXELS_TO_METRE / 2;
			view.y = -BLOCK_SIZE * Game.PIXELS_TO_METRE / 2;
			addChildStarling(view);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			super.build(world);

			this.fixed = true;
		}

		override public function dispose():void
		{
			this._cast = null;

			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.aging, this.lifeTime]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.aging = Boolean(data[1][0]);
			this.lifeTime = data[1][1];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body)
			{
				if (!this.aging || this.disposed)
					return;

				this._lifeTime -= timeStep * 1000;

				if (lifeTime <= 0)
					destroy();
			}
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

		public function set cast(cast:Cast):void
		{
			this._cast = cast;
		}

		public function setCastParams():void
		{
			this.oldCastTime = this._cast.castTime;

			this._cast.castTime = 0;

			if (!Hero.self)
				return;

			this.oldRunCast = Hero.self.useRunningCast;
			Hero.self.useRunningCast = this.oldRunCast || this.useRunCast;
		}

		public function resetCastParams():void
		{
			if (!this._cast)
				return;

			this._cast.castTime = this.oldCastTime;

			if (!Hero.self)
				return;

			Hero.self.useRunningCast = this.oldRunCast;
		}

		public function resolve():Boolean
		{
			if (this.tail == null)
			{
				this.tail = this.position.Copy();
				return true;
			}

			var distance:b2Vec2 = b2Math.SubtractVV(this.position, this.tail);

			if (!((Math.abs(distance.x) < BLOCK_SIZE) && (Math.abs(distance.y) < BLOCK_SIZE)))
			{
				if (distance.x >= 0 && distance.x < BLOCK_SIZE / 2)
					distance.x = 0;
				else if (distance.x >= BLOCK_SIZE / 2)
					distance.x = BLOCK_SIZE;

				if (distance.x <= 0 && distance.x > -BLOCK_SIZE / 2)
					distance.x = 0;
				else if (distance.x <= -BLOCK_SIZE / 2)
					distance.x = -BLOCK_SIZE;

				if (distance.y >= 0 && distance.y < BLOCK_SIZE / 2)
					distance.y = 0;
				else if (distance.y >= BLOCK_SIZE / 2)
					distance.y = BLOCK_SIZE;

				if (distance.y <= 0 && distance.y > -BLOCK_SIZE / 2)
					distance.y = 0;
				else if (distance.y <= -BLOCK_SIZE / 2)
					distance.y = -BLOCK_SIZE;

				this.position = b2Math.AddVV(this.tail, distance);

				this.tail = this.position.Copy();
				return true;
			}

			return false;
		}

		public function clone():*
		{
			var blockClone:DrawBlock = new DrawBlock();
			blockClone.deserialize(this.serialize());
			return blockClone;
		}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			TweenMax.to(this, 0.1, {'alpha': 0, 'onComplete': death});
		}

		private function death():void
		{
			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}