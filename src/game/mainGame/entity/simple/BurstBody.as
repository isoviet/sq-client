package game.mainGame.entity.simple
{
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;

	import utils.starling.StarlingAdapterMovie;

	public class BurstBody extends InvisibleBody
	{
		static private const RADIUS:Number = 60 / Game.PIXELS_TO_METRE;
		static private const POWER:Number = 100;

		private var world:b2World;

		public var radius:Number = RADIUS;
		public var power:Number = POWER;
		public var affectShaman:Boolean = true;

		public function BurstBody():void
		{
			this.view = new StarlingAdapterMovie(new BombPrepere());
			this.view.loop = true;
			this.view.play();
			addChildStarling(this.view);
		}

		override public function dispose():void
		{
			super.dispose();
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			this.world = world;

			this.view.stop();

			this.view.removeFromParent();

			this.view = new StarlingAdapterMovie(new BombExplode());
			this.view.loop = false;
			this.view.play();
			this.view.addEventListener(Event.COMPLETE, onExplode);
			addChildStarling(this.view);

			for (var body:b2Body = this.world.GetBodyList(); body != null; body = body.GetNext())
			{
				var pos:b2Vec2 = body.GetPosition().Copy();
				pos.Subtract(this.position);
				if (pos.Length() > this.radius || pos.Length() == 0 || (body.GetUserData() is Hero) && (body.GetUserData() as Hero).shaman && !this.affectShaman)
					continue;
				var velocity:b2Vec2 = new b2Vec2(this.power * (pos.x / pos.Length()), this.power * (pos.y / pos.Length()));
				body.SetAwake(true);
				body.SetLinearVelocity(velocity);
			}
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.radius, this.power, this.affectShaman]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.radius = data[1][0];
			this.power = data[1][1];
			this.affectShaman = Boolean(data[1][2]);
		}

		private function onExplode(e: Event):void {
			if (!this.gameInst)
				return;

			this.view.removeEventListener(Event.COMPLETE, onExplode);

			if (containsStarling(this.view))
				removeChildStarling(this.view);
			this.view = null;
			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}