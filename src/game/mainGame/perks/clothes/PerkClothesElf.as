package game.mainGame.perks.clothes
{
	public class PerkClothesElf extends PerkClothesJumpCloud
	{
		protected var jumpCount:int = 0;

		public function PerkClothesElf(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
		}

		override protected function activate():void
		{
			super.activate();

			this.jumpCount = 3;
		}

		override protected function get useCooldown():Number
		{
			return 0.01;
		}

		override public function get activeTime():Number
		{
			return 5;
		}

		override protected function onAllowDoubleJump():void
		{
			if (this.allowDoubleJump || !this.hero)
				return;
			this.allowDoubleJump = true;
			this.hero.maxInAirJumps++;
			this.jumpCount--;
			if (this.jumpCount <= 0)
				this.active = false;
		}
	}
}