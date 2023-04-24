package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.Cast;
	import game.mainGame.entity.shaman.ShamanTotem;
	import game.mainGame.perks.ICounted;

	public class PerkShamanStronghold extends PerkShamanCast implements ICounted
	{
		private var delayTimer:Timer = new Timer(600, 100);

		private var useCount:int = 0;

		public function PerkShamanStronghold(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_STRONGHOLD;
			this.delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			onComplete();
		}

		override public function get available():Boolean
		{
			return super.available && !this.delayTimer.running;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable || this.delayTimer.running)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override public function dispose():void
		{
			this.delayTimer.stop();
			this.delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			super.dispose();
		}

		override public function resetRound():void
		{
			this.delayTimer.reset();
			onComplete();

			super.resetRound();
		}

		public function get charge():int
		{
			return this.delayTimer.currentCount;
		}

		public function get count():int
		{
			return this.delayTimer.repeatCount;
		}

		public function resetTimer():void
		{}

		override protected function initCastObject():void
		{
			var totem:ShamanTotem = new ShamanTotem();
			totem.radius *= (countBonus() / 100 + 1);
			totem.playerId = this.hero.id;
			this.castObject = totem;
		}

		override protected function onCast(result:String):void
		{
			if (this.hero.game.cast.castObject != this.castObject)
				return;

			super.onCast(result);

			if (result != Cast.CAST_COMPLETE)
				return;

			if (--this.useCount > 0)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}

		private function onComplete(e:TimerEvent = null):void
		{
			this.useCount = this.isMaxLevel ? 2 : 1;
		}
	}
}