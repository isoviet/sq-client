package game.mainGame.entity.controllers
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Controllers.b2Controller;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2TimeStep;

	public class ClimbController extends b2Controller
	{
		public var squirrelsArray:Array = null;

		public function ClimbController():void
		{}

		override public function Step(step:b2TimeStep):void
		{
			if (step) {/*unused*/}

			if (!this.squirrelsArray)
				return;

			var array:Array = this.squirrelsArray.concat();
			var hero:Hero = null;

			for (var i:int = array.length - 1; i >= 0; i--)
			{
				hero = array[i];

				if (!(hero && !hero.isDead && !hero.inHollow && hero.up && hero.isExist))
					continue;

				hero.climbing = true;

				var body:b2Body = hero.body;

				if (!body || !body.GetWorld() || !body.GetWorld().GetGravity() || body.GetLinearVelocity().y < -10)
					continue;

				var force:b2Vec2 = body.GetWorld().GetGravity().Copy();
				force.Multiply(body.GetMass() * 3);
				force.NegativeSelf();
				body.ApplyForce(force, body.GetWorldCenter());
			}
		}
	}
}