package game.mainGame.perks.clothes
{
	public class PerkClothesViking extends PerkClothes
	{
		static private const BONUS_SPEED:Number = 3;

		private var highSpeed:Boolean = false;

		public function PerkClothesViking(hero:Hero):void
		{
			super(hero);

			this.activateSound = "viking";
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override public function get totalCooldown():Number
		{
			return 60;
		}

		override public function dispose():void
		{
			super.dispose();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.highSpeed)
			{
				this.highSpeed = false;
				this.hero.runSpeed -= BONUS_SPEED;
			}
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero.game)
				return;

			this.hero.runSpeed += BONUS_SPEED;
			this.highSpeed = true;
		}
	}
}