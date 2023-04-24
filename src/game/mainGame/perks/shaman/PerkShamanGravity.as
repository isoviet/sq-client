package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.Cast;
	import game.mainGame.entity.shaman.GravityBlock;
	import game.mainGame.perks.ICounted;

	public class PerkShamanGravity extends PerkShamanCast implements ICounted
	{
		static private const BLOCK_LIFE_TIME_BONUS:int = 10 * 1000;

		private var delayTimer:Timer = new Timer(200, 100);

		private var useCount:int = 0;

		public function PerkShamanGravity(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_GRAVITY;
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
			var graviBlock:GravityBlock = new GravityBlock();
			var size:Number = 20 * (1 + countBonus() / 100);
			graviBlock.outSize = new b2Vec2(size, size);
			if (this.isMaxLevel)
				graviBlock.lifeTime += BLOCK_LIFE_TIME_BONUS;

			this.castObject = graviBlock;
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