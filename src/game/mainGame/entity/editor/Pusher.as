package game.mainGame.entity.editor
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;

	import game.mainGame.ISerialize;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.controllers.PusherController;
	import game.mainGame.entity.joints.IJoint;
	import game.mainGame.entity.simple.GameBody;

	import interfaces.IDispose;

	import utils.IndexUtil;
	import utils.WorldQueryUtil;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class Pusher extends StarlingAdapterSprite implements IGameObject, ISerialize, IJoint, IDispose
	{
		private var controller:PusherController;

		public var bodyId:int = -1;
		public var body:GameBody;
		public var force:Number = 0;
		public var maxVelocity:Number = 100;

		private var view: StarlingAdapterMovie;

		public function Pusher():void
		{
			super();

			view = new StarlingAdapterMovie(new ArrowMovie());
			view.rotation = 180;
			view.y = view.height / 2;
			addChildStarling(view);
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
		}

		public function get angle():Number
		{
			return this.rotation * Game.D2R;
		}

		public function set angle(value:Number):void
		{
			this.rotation = value * Game.R2D;
		}

		public function build(world:b2World):void
		{
			this.controller = new PusherController();
			this.controller.pusher = this;
			world.AddController(this.controller);

			if (bodyId == -1)
			{
				var bodies:Array = WorldQueryUtil.findBodiesAtPoint(world, this.position, GameBody);
				for (var i:int = 0; i < bodies.length; i++)
					bodies[i] = (bodies[i] as b2Body).GetUserData();

				this.body = IndexUtil.getMaxIndex(bodies) as GameBody;

				if (body == null)
					return;

				this.body.addChildStarling(this);
				this.position = this.body.body.GetLocalPoint(this.position);
				this.angle = this.angle - body.angle;
			}
			view.play();
		}

		public function serialize():*
		{
			var result:Array = [[this.position.x, this.position.y], this.angle, this.force, this.maxVelocity];
			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.angle = data[1];
			this.force = data[2];
			this.maxVelocity = data[3];
		}

		public function dispose():void
		{
			if (this.parentStarling)
				this.parentStarling.removeChildStarling(this);

			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			if (controller)
			{
				this.controller.GetWorld().RemoveController(this.controller);
				this.controller.pusher = null;
			}

			this.body = null;
			this.controller = null;
		}
	}
}