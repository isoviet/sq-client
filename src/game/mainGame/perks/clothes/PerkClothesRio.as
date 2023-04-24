package game.mainGame.perks.clothes
{
	import flash.events.Event;

	import sounds.GameSounds;

	public class PerkClothesRio extends PerkClothes
	{
		static private const RIO_FALL_VELOCITY:Number = 5;

		public function PerkClothesRio(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_WINGS;
			this.soundOnlyHimself = true;

		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.fallVelocities.push(RIO_FALL_VELOCITY);
			this.hero.jumpVelocity *= 1.2;
			this.hero.addEventListener(Hero.EVENT_UP, onJump);

			if (!this.hero.isSelf)
				return;

			this.hero.heroView.showPerkAnimationPermanent(new SlowFallButton);
		}

		private function onJump(event:Event):void
		{
			if (!this || !this.active || !this.hero || !this.hero.onFloor || !event || !this.hero.isSelf)
				return;

			GameSounds.play(SOUND_WINGS);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;

			this.hero.removeEventListener(Hero.EVENT_UP, onJump);

			this.hero.changeView();
			var index:int = this.hero.fallVelocities.indexOf(RIO_FALL_VELOCITY);
			if (index != -1)
				this.hero.fallVelocities.splice(index, 1);

			this.hero.jumpVelocity /= 1.2;

			if (this.hero.isSelf)
				this.hero.heroView.hidePerkAnimationPermanent();
		}
	}
}