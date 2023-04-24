package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.behaviours.StateBanshee;

	public class PerkClothesBanshee extends PerkClothes

	{
		static private const MAX_SPEED:Number = 2.5;

		private var bonusSpeed:Number;

		private var stateBanshee:StateBanshee;

		public function PerkClothesBanshee(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
			this.stateBanshee = new StateBanshee(0);
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override public function get activeTime():Number
		{
			return 2;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero.game)
				return;
			this.hero.behaviourController.addState(this.stateBanshee);
			this.bonusSpeed = this.hero.runSpeed * 0.5;
			this.hero.runSpeed -= this.bonusSpeed;
			this.hero.changeView(new BansheeMagicView());

			var velocity:b2Vec2 = this.hero.body.GetLinearVelocity();
			if (velocity.Length() > MAX_SPEED)
			{
				velocity.Normalize();
				velocity.x *= MAX_SPEED;
				velocity.y *= MAX_SPEED;
			}
			this.hero.body.SetLinearVelocity(velocity);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero || !this.hero.game)
				return;
			this.hero.behaviourController.removeState(this.stateBanshee);
			this.hero.runSpeed += this.bonusSpeed;
			this.hero.changeView();
		}
	}
}