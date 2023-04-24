package game.mainGame.perks.clothes.base
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;

	import game.mainGame.behaviours.StateStun;
	import game.mainGame.perks.clothes.PerkClothes;

	import utils.starling.StarlingAdapterMovie;

	public class PerkClothesExplode extends PerkClothes
	{
		protected var view:StarlingAdapterMovie = null;
		protected var exploded:Boolean = false;

		public function PerkClothesExplode(hero:Hero)
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override protected function activate():void
		{
			super.activate();

			this.exploded = false;
			createView();
		}

		protected function get power():Number
		{
			return 0;
		}

		protected function get radius():Number
		{
			return 0;
		}

		protected function createView():void
		{}

		protected function explode():void
		{
			if (this.exploded)
				return;
			this.exploded = true;

			var currentPosition:b2Vec2 = this.hero.position.Copy();
			currentPosition.Add(this.hero.rCol2);
			for (var body:b2Body = this.hero.game.world.GetBodyList(); body != null; body = body.GetNext())
			{
				var pos:b2Vec2 = body.GetPosition().Copy();
				pos.Subtract(currentPosition);
				if (pos.Length() > this.radius || pos.Length() == 0 || (body.GetUserData() == this.hero))
					continue;
				var velocity:b2Vec2 = new b2Vec2(this.power * (pos.x / pos.Length()), this.power * (pos.y / pos.Length()));
				body.SetAwake(true);
				body.SetLinearVelocity(velocity);

				if (body.GetUserData() is Hero)
					(body.GetUserData() as Hero).behaviourController.addState(new StateStun(0.75));
			}
		}
	}
}