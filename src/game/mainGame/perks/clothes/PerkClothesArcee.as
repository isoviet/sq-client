package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	public class PerkClothesArcee extends PerkClothes
	{
		public function PerkClothesArcee(hero:Hero):void
		{
			super(hero);

			this.activateSound = "arcee";
		}

		override public function get totalCooldown():Number
		{
			return 5;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.velocity = new b2Vec2();
			var bounce:b2Vec2 = this.hero.body.GetTransform().R.col2.Copy();
			bounce.Multiply(-150);
			this.hero.applyImpulse(bounce);
		}
	}
}