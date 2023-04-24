package game.mainGame.entity.controllers
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Controllers.b2Controller;
	import Box2D.Dynamics.b2TimeStep;

	import game.mainGame.entity.simple.BalloonBody;

	public class BalloonController extends b2Controller
	{
		public var balloon:BalloonBody;
		public var forcePos:b2Vec2 = new b2Vec2(0, -0.1);
		public var active:Boolean = true;
		public var force:b2Vec2 = new b2Vec2(0, -2500);

		public function BalloonController():void
		{}

		override public function Step(step:b2TimeStep):void
		{
			if (step) {/*unused*/}

			if (this.balloon && this.balloon.body.GetLinearVelocity().y > this.balloon.velocityLimit && this.active)
				this.balloon.body.ApplyForce(force, this.balloon.body.GetWorldPoint(this.forcePos));
		}
	}
}