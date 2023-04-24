package game.mainGame.entity.controllers
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Controllers.b2Controller;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2TimeStep;

	import game.mainGame.entity.editor.Pusher;

	public class PusherController extends b2Controller
	{
		public var pusher:Pusher;

		public override function Step(step:b2TimeStep):void
		{
			if (step) {/*unused*/}

			if (pusher == null || pusher.body == null || pusher.body.body == null)
				return;

			var vel:b2Vec2 = pusher.body.body.GetLocalVector(pusher.body.body.GetLinearVelocityFromLocalPoint(pusher.position));

			if (vel.Length() > this.pusher.maxVelocity)
				return;

			var body:b2Body = pusher.body.body;

			body.SetAwake(true);

			var a:Number = pusher.angle + pusher.body.angle;
			var f:b2Vec2 = new b2Vec2(Math.cos(a), Math.sin(a));

			f.Multiply(pusher.force);

			body.ApplyForce(f, body.GetWorldPoint(pusher.position));
		}
	}

}