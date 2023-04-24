package game.mainGame.entity.controllers
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.Controllers.b2Controller;
	import Box2D.Dynamics.Controllers.b2ControllerEdge;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2TimeStep;

	import game.mainGame.SquirrelGame;
	import game.mainGame.behaviours.StateBanshee;
	import game.mainGame.entity.editor.ClickButton;
	import game.mainGame.entity.editor.Sensor;
	import game.mainGame.entity.simple.GameBody;

	public class PlanetController extends b2Controller
	{
		public var G:Number = 1;
		public var body:b2Body;
		public var invSqr:Boolean = true;
		public var affectHero:Boolean = true;
		public var affectObjects:Boolean;
		public var maxDistance:Number = Number.MAX_VALUE;
		public var addExtGrav:Boolean = true;
		public var biDirectional:Boolean = false;
		public var disableGlobalGravity:Boolean = true;

		public function PlanetController():void
		{

		}

		public override function Step(step:b2TimeStep):void{
			//Inlined
			if ((!this.affectHero && !this.affectObjects) || this.G == 0 || this.body == null)
				return;

			var i:b2Body = null;
			var body1:b2Body = body;
			var p1:b2Vec2 = body1.GetWorldCenter().Copy();
			var mass1:Number = body1.GetMass();
			var j:b2Body = null;
			var body2:b2Body = null;
			var p2:b2Vec2 = null;
			var dx:Number = 0;
			var dy:Number = 0;
			var r2:Number = 0;
			var f:b2Vec2 = null;

			for (j = this.GetWorld().GetBodyList(); j != i; j = j.GetNext())
			{
				if (j == this.body)
					continue;

				var userData:* = j.GetUserData();

				if (userData is Hero && (!this.affectHero || (userData as Hero).behaviourController.getState(StateBanshee) != null))
					continue;
				if (!this.affectObjects && (!(userData is Hero) || !checkHero(userData as Hero) || userData is Sensor || userData is ClickButton))
					continue;
				if (!j.IsAwake())
					continue;
				if (userData is GameBody && (userData as GameBody).fixed && !biDirectional)
					continue;

				body2 = j;
				p2 = body2.GetWorldCenter().Copy();
				dx = p2.x - p1.x;
				dy = p2.y - p1.y;
				r2 = dx * dx + dy * dy;

				if(r2<Number.MIN_VALUE)
					continue;

				if (Math.sqrt(r2) > maxDistance)
					continue;

				f = new b2Vec2(dx, dy);
				f.Multiply(G / r2 / Math.sqrt(r2) * mass1 * body2.GetMass());

				if (biDirectional)
					body1.ApplyForce(f.Copy(), p1);

				f.Multiply(-1);

				body2.ApplyForce(f.Copy(), p2);

				if (this.disableGlobalGravity)
				{
					var controllers:b2ControllerEdge = body2.GetControllerList();
					var applyGravity:Boolean = true;

					for (;controllers != null; controllers = controllers.nextController)
					{
						if (controllers.controller is b2ConstantAccelController)
						{
							applyGravity = false;
							break;
						}
					}

					if (applyGravity)
					{
						var vel:b2Vec2 = body2.GetLinearVelocity().Copy();
						var grav:b2Vec2 = globalGravity.GetNegative();
						grav.Multiply(step.dt);
						vel.Add(grav);
						body2.SetLinearVelocity(vel.Copy());
						if (body2.GetUserData() is Hero)
							(body2.GetUserData() as Hero).useGravity = false;
					}
				}

				if (addExtGrav && body2.GetUserData() is Hero)
				{
					var v:b2Vec2 = new b2Vec2(f.x, f.y);
					v.Multiply(step.dt / body2.GetMass());
					(body2.GetUserData() as Hero).extGravityAdd(v);
				}
			}
		}

		protected function checkHero(hero:Hero):Boolean
		{
			if (hero){/*unused*/}
			return true;
		}

		private function get globalGravity():b2Vec2
		{
			if (!this.GetWorld() || !this.GetWorld().userData)
				return new b2Vec2();

			return (this.GetWorld().userData as SquirrelGame).gravity;
		}
	}
}