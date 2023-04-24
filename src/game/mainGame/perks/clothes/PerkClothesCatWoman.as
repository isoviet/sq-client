package game.mainGame.perks.clothes
{
	import flash.events.Event;

	public class PerkClothesCatWoman extends PerkClothes
	{
		static private const JUMP_VALUE:Number = 0.5;

		protected var jumpBonus:Number = 0;

		public function PerkClothesCatWoman(hero: Hero):void
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
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

			this.jumpBonus = this.hero.jumpVelocity * JUMP_VALUE;
			this.hero.jumpVelocity += this.jumpBonus;
			this.hero.addEventListener(Hero.EVENT_UP_END, onJump);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.jumpVelocity -= this.jumpBonus;
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		protected function onJump(e:Event):void
		{
			this.hero.removeEventListener(Hero.EVENT_UP_END, onJump);
			this.active = false;
		}
	}
}