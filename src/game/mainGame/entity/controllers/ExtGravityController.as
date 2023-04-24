package game.mainGame.entity.controllers
{
	import Box2D.Common.Math.b2Mat22;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Transform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.Controllers.b2Controller;
	import Box2D.Dynamics.Controllers.b2ControllerEdge;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2TimeStep;

	import game.mainGame.ActiveBodiesCollector;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.editor.ClickButton;
	import game.mainGame.entity.editor.RectGravity;
	import game.mainGame.entity.editor.Sensor;
	import game.mainGame.entity.simple.GameBody;

	public class ExtGravityController extends b2Controller
	{
		public var G:Number = 1;
		public var body:IGameObject;
		public var affectHero:Boolean = true;
		public var affectObjects:Boolean;
		public var posOffset:b2Vec2;

		public var inSize:b2Vec2;
		public var outSize:b2Vec2;
		public var direction:b2Vec2;

		public var addExtGrav:Boolean = true;
		public var disableGlobalGravity:Boolean = true;

		private var bvel:b2Vec2 = new b2Vec2();
		private var vel:b2Vec2 = new b2Vec2();
		private var bpos:b2Vec2 = new b2Vec2();

		public function ExtGravityController():void
		{}

		public function dispose():void
		{
			this.G = 0;
			this.affectHero = this.affectObjects = false;
			this.GetWorld().RemoveController(this);
		}

		public override function Step(step:b2TimeStep):void
		{
			if (!this.affectHero && !this.affectObjects || this.G == 0)
				return;

			var m:b2Mat22 = new b2Mat22();
			m.Set(body.angle);

			var tr:b2Transform = new b2Transform(b2Math.AddVV(posOffset, body.position.Copy()), m);

			for each (var j:b2Body in ActiveBodiesCollector.bodies)
			{
				if (this.body is RectGravity && (this.body as RectGravity).parentPlatform && (this.body as RectGravity).parentPlatform.body && (this.body as RectGravity).parentPlatform.body == j)
					continue;

				var userData:* = j.GetUserData();

				if (!this.affectHero && userData is Hero)
					continue;
				if (!this.affectObjects && (!(userData is Hero) || userData is Sensor || userData is ClickButton))
					continue;
				if (!j.IsAwake())
					continue;
				if (userData is GameBody && (userData as GameBody).fixed)
					continue;

				this.bvel.x = j.GetLinearVelocity().x;
				this.bvel.y = j.GetLinearVelocity().y;

				this.vel.x = 0.0;
				this.vel.y = 0.0;

				var dir:b2Vec2;

				this.bpos.x = j.GetPosition().x;
				this.bpos.y = j.GetPosition().y;

				var localbpos:b2Vec2 = b2Math.MulXT(tr, bpos);

				if ((localbpos.x < -this.outSize.x / 2 || localbpos.x > this.outSize.x / 2) || (localbpos.y < -this.outSize.y / 2 || localbpos.y > this.outSize.y / 2))
				{
					continue;
				}

				if (direction.x == 0 && direction.y == 0)
				{
					var toPoint:b2Vec2 = new b2Vec2();
					if (localbpos.x > -this.inSize.x / 2 && localbpos.x < this.inSize.x / 2)
						toPoint.x = localbpos.x;
					if (localbpos.y > -this.inSize.y / 2 && localbpos.y < this.inSize.y / 2)
						toPoint.y = localbpos.y;

					toPoint = b2Math.MulX(tr, toPoint);
					dir = b2Math.SubtractVV(bpos, toPoint);
				}
				else
					dir = direction.Copy();

				dir.Normalize();
				dir.Multiply(step.dt * G);
				vel.Add(dir);

				if (addExtGrav && userData is Hero)
				{
					(userData as Hero).extGravityAdd(vel.Copy());
					(userData as Hero).useGravity = !disableGlobalGravity;
				}

				if (this.disableGlobalGravity)
				{
					var controllers:b2ControllerEdge = j.GetControllerList();
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
						var g:b2Vec2 = this.globalGravity.GetNegative();

						g.Multiply(step.dt);
						vel.Add(g);
					}
				}

				bvel.Add(vel);

				j.SetLinearVelocity(bvel.Copy());
			}
		}

		private function get globalGravity():b2Vec2
		{
			if (!this.GetWorld() || !this.GetWorld().userData)
				return new b2Vec2();

			return (this.GetWorld().userData as SquirrelGame).gravity;
		}
	}
}