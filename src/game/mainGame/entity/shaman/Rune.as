package game.mainGame.entity.shaman
{
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;

	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.controllers.PusherController;
	import game.mainGame.entity.editor.Pusher;
	import game.mainGame.entity.simple.GameBody;

	import com.greensock.TweenMax;

	import utils.IndexUtil;
	import utils.WorldQueryUtil;
	import utils.starling.StarlingAdapterSprite;

	public class Rune extends Pusher implements IUpdate, ILifeTime
	{
		private var controller:PusherController;
		private var world:b2World = null;

		private var direction:b2Vec2 = null;
		private var delta:b2Vec2 = null;
		private var startPoint:Point;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 30 * 1000;
		private var disposed:Boolean = false;

		public var velocity:Number = 0.3;

		public function Rune():void
		{
			super();

			while (this.numChildren)
				removeChildStarlingAt(0);

			addChildStarling(new StarlingAdapterSprite(new RuneImg));

			this.force = 10000;
		}

		override public function build(world:b2World):void
		{
			this.controller = new PusherController();
			this.controller.pusher = this;
			this.maxVelocity = 50;
			world.AddController(this.controller);

			this.world = world;

			this.direction = new b2Vec2(Math.cos(this.angle), Math.sin(this.angle));

			this.delta = this.direction.Copy();
			this.delta.Multiply(this.velocity);

			this.startPoint = new Point(this.x, this.y);
		}

		override public function dispose():void
		{
			if (this.parentStarling)
				this.parentStarling.removeChildStarling(this);

			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			if (this.controller)
			{
				this.controller.GetWorld().RemoveController(this.controller);
				this.controller.pusher = null;
			}

			this.body = null;
			this.controller = null;
			this.world = null;
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

		public function update(timeStep:Number = 0):void
		{
			if (this.aging && !this.disposed)
			{
				this._lifeTime -= timeStep * 1000;

				if (lifeTime <= 0)
					destroy();
			}

			if (this.body || !this.world)
				return;

			this.direction.Add(this.delta);

			var destination:b2Vec2 = this.direction.Copy();
			destination.Add(new b2Vec2(this.startPoint.x / Game.PIXELS_TO_METRE, this.startPoint.y / Game.PIXELS_TO_METRE));

			this.position = destination.Copy();

			this.body = findBody();

			if (!this.body)
				return;

			this.body.addChildStarling(this);
			this.position = this.body.body.GetLocalPoint(this.position);
			this.angle = this.angle - body.angle;
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

			var dataPointer:Array = data.pop();

			this.aging = Boolean(dataPointer[0]);
			this.lifeTime = dataPointer[1];
		}

		public function findBody():GameBody
		{
			var bodies:Array = WorldQueryUtil.findBodiesAtPoint(this.world, this.position, GameBody);
			for (var i:int = 0; i < bodies.length; i++)
				bodies[i] = (bodies[i] as b2Body).GetUserData();

			return IndexUtil.getMaxIndex(bodies) as GameBody;
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
			if (!this.world)
				return;

			(this.world.userData as SquirrelGame).map.destroyObjectSync(this, true);
		}
	}
}