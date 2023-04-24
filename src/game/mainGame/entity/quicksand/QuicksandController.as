package game.mainGame.entity.quicksand
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2TimeStep;

	import game.mainGame.ActiveBodiesCollector;
	import game.mainGame.entity.simple.DragonFlamer;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.water.Water;
	import game.mainGame.entity.water.WaterController;
	import game.mainGame.perks.clothes.PerkClothesFactory;

	public class QuicksandController extends WaterController
	{
		public var viscosity:Number = 1.4;

		public function QuicksandController(quicksandSurface:Water):void
		{
			super(quicksandSurface);
		}

		override public function Step(step:b2TimeStep):void
		{
			if (step) {/*unused*/}

			if (!this.waterSurface)
				return;

			for each (var i:b2Body in ActiveBodiesCollector.bodies)
			{
				var body:b2Body = i;
				var userData:* = body.GetUserData();

				if (!body.IsAwake())
					continue;

				if (userData is GameBody && (userData as GameBody).fixed)
					continue;

				var data:Array = this.waterSurface.getSurfaceData(body.GetPosition().x, body.GetPosition().y);
				if (!data[2])
					continue;

				var fixture:b2Fixture = body.GetFixtureList();
				if (!fixture)
					continue;

				var normal:b2Vec2 = data[0];
				var offset:Number = data[1];
				var wasInWater:Boolean = (this.bodies[body] != null);

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

				var hero:Hero = (userData as Hero);

				if ((userData is Hero) && !hero.isDead && !hero.inHollow)
				{
					if(hero.ghost)
						continue;
					hero.submerge = (area >= Number.MIN_VALUE) && this.waterSurface.allowSwim;
					if (hero.onFire && hero.submerge)
						hero.setOnFire(false);
					if (hero.submerge && (this.waterSurface as Quicksand).bottomY && (hero.y + Hero.Y_POSITION_COEF >= (this.waterSurface as Quicksand).bottomY))
					{
						hero.dieReason = Hero.DIE_QUICKSAND;
						hero.kill();
						continue;
					}
				}

				if (!wasInWater)
					this.waterSurface.applyVelocity(body.GetPosition(), body.GetLinearVelocity());

				var isPharaon:Boolean = (hero && hero.up && hero.isSquirrel) as Boolean;
				isPharaon = isPharaon && hero.perkController.getPerkLevel(PerkClothesFactory.PHARAON_WOMAN) != -1;
				// Linear drag
				body.SetLinearVelocity(new b2Vec2(body.GetLinearVelocity().x / this.linearDrag, isPharaon ? -5 : 1 / this.viscosity));
				var force:b2Vec2 = GetWorld().GetGravity().Copy();
				force.Multiply(body.GetMass());
				force.NegativeSelf();
				body.ApplyForce(force, areac);

				// Angular drag
				body.SetAngularVelocity(body.GetAngularVelocity() / this.angularDrag);

				// Buoyancy force
			}
		}
	}
}