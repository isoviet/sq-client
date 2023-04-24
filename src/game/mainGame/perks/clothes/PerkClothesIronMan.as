package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;

	import utils.starling.StarlingAdapterSprite;

	public class PerkClothesIronMan extends PerkClothes
	{
		static public const DISTNANCE:Number = 900;
		static public const POWER:Number = 100;
		static public const POWER_OBJECTS:Number = 500;

		static public const BEAM_TIME:Number = 0.5;

		private var beam:StarlingAdapterSprite = null;
		private var beamTime:Number = 0;

		public function PerkClothesIronMan(hero:Hero):void
		{
			super(hero);

			this.activateSound = "ironman";
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.beamTime <= 0)
				return;
			this.beamTime -= timeStep;
			this.beam.alpha = Math.max(0, this.beamTime / BEAM_TIME);
			if (this.beamTime > 0)
				return;
			this.hero.game.map.removeChildStarling(this.beam);
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.running) && !(this.hero.heroView.fly);
		}

		override protected function activate():void
		{
			super.activate();

			var startPoint:b2Vec2 = this.hero.position.Copy();
			var endPoint:b2Vec2 = this.hero.rCol1;
			endPoint.Multiply(this.hero.heroView.direction ? -DISTNANCE : DISTNANCE);
			endPoint.Add(this.hero.rCol2);
			endPoint = b2Math.AddVV(this.hero.position, endPoint);

			var impulse:b2Vec2 = b2Math.SubtractVV(endPoint, startPoint);
			impulse.Normalize();
			impulse.Multiply(POWER);

			var impulseObject:b2Vec2 = b2Math.SubtractVV(endPoint, startPoint);
			impulseObject.Normalize();
			impulseObject.Multiply(POWER_OBJECTS);

			var fixtures:Vector.<b2Fixture> = this.hero.game.world.RayCastAll(startPoint, endPoint);
			for each (var fixture:b2Fixture in fixtures)
			{
				var body:b2Body = fixture.GetBody();
				if (body.GetUserData() == this.hero)
					continue;
				if (body.GetUserData() is Hero)
					body.ApplyImpulse(impulse, body.GetWorldCenter());
				else
					body.ApplyImpulse(impulseObject, body.GetWorldCenter());
			}

			this.beam = new StarlingAdapterSprite(new Beam());
			this.beam.mouseEnabled = false;
			this.beam.mouseChildren = false;
			this.beam.scaleX = 900 / this.beam.width;

			this.beam.x = this.hero.x + (this.hero.heroView.direction ? -DISTNANCE : 0);
			this.beam.y = this.hero.y;
			this.beam.alpha = 1.0;
			this.beamTime = BEAM_TIME;
			this.hero.game.map.addChildStarling(this.beam);
		}
	}
}