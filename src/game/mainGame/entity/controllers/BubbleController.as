package game.mainGame.entity.controllers
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Controllers.b2Controller;
	import Box2D.Dynamics.b2TimeStep;

	import game.mainGame.entity.simple.BubbleBody;

	public class BubbleController extends b2Controller
	{
		public var bubble:BubbleBody = null;
		public var force:b2Vec2 = new b2Vec2(0, -2500);
		public var speedLimit:Number = -10;

		public function BubbleController():void
		{}

		override public function Step(step:b2TimeStep):void
		{
			if (step) {/*unused*/}

			if (this.bubble && this.bubble.body && this.bubble.body.GetLinearVelocity().y > this.speedLimit)
				this.bubble.body.ApplyForce(this.force, this.bubble.body.GetWorldCenter());
		}
	}
}