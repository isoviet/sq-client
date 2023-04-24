package game.mainGame.perks.clothes
{
	public class PerkClothesOlympus extends PerkClothes
	{
		private var _highSpeed:Boolean = false;
		private var speedBonus:Number = 0;
		private var jumpBonus:int = 0;

		public function PerkClothesOlympus(hero:Hero):void
		{
			super(hero);
		}

		override public function get maxCountUse():int
		{
			return 1;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override protected function activate():void
		{
			super.activate();

			this.highSpeed = true;
			showPerkAnimation();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.highSpeed = false;

			if (this.hero && this.hero.isSelf)
				this.hero.heroView.hidePerkAnimationPermanent();
		}

		protected function get bonus():Number
		{
			return 0.15;
		}

		private function set highSpeed(value:Boolean):void
		{
			if (this._highSpeed == value)
				return;

			this._highSpeed = value;

			if (value)
			{
				this.speedBonus = this.hero.runSpeed * this.bonus;
				this.jumpBonus = this.hero.jumpVelocity * this.bonus;
			}

			this.hero.runSpeed += this.speedBonus * (value ? 1 : -1);
			this.hero.jumpVelocity += this.jumpBonus * (value ? 1 : -1);
		}

		private function showPerkAnimation():void
		{
			if (!this.hero)
				return;

			if (this.hero.isSelf)
				this.hero.heroView.showPerkAnimationPermanent(new HighSpeedButton);
		}
	}
}