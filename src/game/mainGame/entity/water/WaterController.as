package game.mainGame.entity.water
{
	import flash.utils.Dictionary;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Controllers.b2Controller;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2TimeStep;

	import game.mainGame.ActiveBodiesCollector;
	import game.mainGame.entity.magic.Gum;
	import game.mainGame.entity.simple.DragonFlamer;
	import game.mainGame.entity.simple.GameBody;
	import sounds.GameSounds;

	public class WaterController extends b2Controller
	{
		protected var bodies:Dictionary = new Dictionary(false);

		public var skipStep:Boolean = false;
		public var waterSurface:Water;
		public var density:Number = 1;
		public var velocity:b2Vec2 = new b2Vec2(0, 0);
		public var linearDrag:Number = 2;
		public var angularDrag:Number = 1;
		public var useDensity:Boolean = true;
		public var useWorldGravity:Boolean = true;
		public var gravity:b2Vec2 = new b2Vec2();

		public function WaterController(waterSurface:Water):void
		{
			this.waterSurface = waterSurface;
		}

		override public function Step(step:b2TimeStep):void
		{
			if (step) {/*unused*/}

			if (this.useWorldGravity)
				this.gravity = GetWorld().GetGravity().Copy();
			if (!this.waterSurface)
				return;

			for each (var i:b2Body in ActiveBodiesCollector.bodies)
			{
				var body:b2Body = i;

				if (!body.IsAwake())
					continue;

				var userData:* = body.GetUserData();

				if (userData is GameBody && (userData as GameBody).fixed)
					continue;

				var isHero:Boolean = userData is Hero;
				var data:Array = this.waterSurface.getSurfaceData(body.GetPosition().x, body.GetPosition().y);
				if (!data[2]) {
					var hero:Hero = (userData as Hero);
					if (isHero && hero.id == Game.selfId)
						hero.lastStateSwim = false;
					continue;
				}

				var fixture:b2Fixture = body.GetFixtureList();
				if (!fixture)
					continue;

				var normal:b2Vec2 = data[0];
				var offset:Number = data[1];
				var wasInWater:Boolean = Boolean(this.bodies[body]);

				if (isHero)
				{
					hero = (userData as Hero);
					if (Math.random() > 0.9999)
					{
						var pos:b2Vec2 = hero.position.Copy();
						pos.Add(new b2Vec2(0, -1));
						pos.Add(new b2Vec2(hero.heroView.direction ? -1 : 1));
						this.waterSurface.addBubble(pos, Math.random() * 0.5 + 0.5);
					}
				}

				var areac:b2Vec2 = new b2Vec2();
				var massc:b2Vec2 = new b2Vec2();
				var area:Number = 0.0;
				var mass:Number = 0.0;

				var sc:b2Vec2 = new b2Vec2();
				var sarea:Number = fixture.GetShape().ComputeSubmergedArea(normal, offset, body.GetTransform(), sc);
				area += sarea;
				areac.x += sarea * sc.x;
				areac.y += sarea * sc.y;

				var shapeDensity:Number = this.useDensity ? fixture.GetDensity(): 1;
				mass += sarea * shapeDensity;
				massc.x += sarea * sc.x * shapeDensity;
				massc.y += sarea * sc.y * shapeDensity;

				areac.x /= area;
				areac.y /= area;
				massc.x /= mass;
				massc.y /= mass;

				if (area < Number.MIN_VALUE)
				{
					this.bodies[body] = false;
					continue;
				}

				this.bodies[body] = true;

				if (userData is DragonFlamer)
				{
					var dragonFire:DragonFlamer = userData as DragonFlamer;
					if ((area >= Number.MIN_VALUE) && this.waterSurface.allowSwim)
						dragonFire.destroy();
					continue;
				}

				if (isHero)
				{
					hero = (userData as Hero);
					if(hero.ghost)
						continue;

					hero.swim = (area >= Number.MIN_VALUE) && this.waterSurface.allowSwim;
					if (hero.lastStateSwim == false && hero.swim == true && hero.id == Game.selfId)
						GameSounds.play('water');

					hero.lastStateSwim = hero.swim;

					if (hero.onFire && hero.swim)
						hero.setOnFire(false);
				}

				if (!wasInWater)
					this.waterSurface.applyVelocity(body.GetPosition(), body.GetLinearVelocity());

				var speedFactor:Number = isHero && hero.swim ? hero.swimFactor : 1;
				// Buoyancy force
				var bForce:b2Vec2 = gravity.Copy();
				bForce.NegativeSelf();
				bForce.Multiply(density * area * (isHero ? speedFactor / (3 * (hero.scale * hero.scale)) : 1) * 2);

				if (!isHero && !(userData is Gum) || isHero && (userData as Hero).up && this.waterSurface.allowSwim)
					body.ApplyForce(bForce, massc);

				// Linear drag
				var lDrag:b2Vec2 = body.GetLinearVelocityFromWorldPoint(areac);
				lDrag.Subtract(velocity);
				lDrag.Multiply(-linearDrag * area);
				body.ApplyForce(lDrag, areac);

				// Angular drag
				body.ApplyTorque(-body.GetInertia() / body.GetMass() * area * body.GetAngularVelocity() * angularDrag);
			}
		}
	}
}