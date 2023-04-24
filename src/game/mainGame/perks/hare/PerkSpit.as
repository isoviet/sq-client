package game.mainGame.perks.hare
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;

	import game.SpitAnimation;
	import sounds.GameSounds;

	public class PerkSpit extends PerkHare implements ICounted
	{
		static private const MAX_COUNT_PER_ROUND:int = 1;

		private var spitAnimation:SpitAnimation;

		private var counter:int = 0;

		private var timerSpit:Timer = new Timer(1900, 1);
		private var timerSpitAnimation:Timer = new Timer(3000, 1);

		public function PerkSpit(hero:Hero):void
		{
			super(hero);

			this.code = Keyboard.END;

			this.spitAnimation = new SpitAnimation();

			this.timerSpit.addEventListener(TimerEvent.TIMER_COMPLETE, spit);
			this.timerSpitAnimation.addEventListener(TimerEvent.TIMER_COMPLETE, spitAnimationStop);
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.hareView as HareView).stomp && !(this.hero.heroView.hareView as HareView).rock && !(this.hero.heroView.hareView as HareView).chew && (this.counter < MAX_COUNT_PER_ROUND);
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.spitAnimation == null)
				return;

			this.timerSpit.stop();
			this.timerSpitAnimation.stop();

			this.spitAnimation.reset();

			if (Game.gameSprite.contains(this.spitAnimation))
				Game.gameSprite.removeChild(this.spitAnimation);
		}

		/*override public function reset():void
		{
			super.reset();

			this.counter = 0;

			if (this.spitAnimation == null)
				return;

			this.timerSpit.stop();
			this.timerSpitAnimation.stop();

			this.spitAnimation.reset();

			if (Game.gameSprite.contains(this.spitAnimation))
				Game.gameSprite.removeChild(this.spitAnimation);
		}*/

		override protected function activate():void
		{
			super.activate();

			(this.hero.heroView.hareView as HareView).spit = true;
			this.hero.isStoped = true;

			this.counter++;

			this.timerSpit.reset();
			this.timerSpit.start();

			this.timerSpitAnimation.reset();
			this.timerSpitAnimation.start();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			(this.hero.heroView.hareView as HareView).spit = false;
			this.hero.isStoped = false;
		}

		override protected function block():void
		{
			if (!super.available)
				return;

			this.charge = 0;
			this.isBlocked = true;
			dispatchEvent(new Event("STATE_CHANGED"));
		}

		private function spit(e:TimerEvent):void
		{
			if (this.hero == null)
				return;

			GameSounds.play("spit");
			GameSounds.playUnrepeatable("hare_spit", HareView.SOUND_PROBABILITY);

			this.spitAnimation.activate();
			Game.gameSprite.addChild(this.spitAnimation);
		}

		private function spitAnimationStop(e:TimerEvent):void
		{
			if (this.hero == null)
				return;

			this.active = false;

			if (this.counter == MAX_COUNT_PER_ROUND)
			{
				this.charge = 0;
				dispatchEvent(new Event("STATE_CHANGED"));
			}
		}
	}
}