package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.utils.Timer;

	import game.mainGame.Cast;
	import game.mainGame.entity.shaman.ShamanBodyDestructor;
	import game.mainGame.perks.ICounted;

	public class PerkShamanDestroyer extends PerkShamanCast implements ICounted
	{
		private var useCount:int = 0;

		private var delayTimer:Timer = new Timer(100, 100);

		public function PerkShamanDestroyer(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_DESTROYER;
			this.useCount = countBonus();
		}

		override public function dispose():void
		{
			this.delayTimer.stop();

			super.dispose();
		}

		override public function resetRound():void
		{
			super.resetRound();

			this.delayTimer.reset();
			this.useCount = countBonus();
		}

		override public function get available():Boolean
		{
			return super.available && this.useCount > 0 && !this.delayTimer.running;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable || this.delayTimer.running)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
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
			this.castObject = new ShamanBodyDestructor();
		}

		override protected function onCast(result:String):void
		{
			if (this.hero.game.cast.castObject != this.castObject)
				return;

			super.onCast(result);

			if (result != Cast.CAST_COMPLETE)
				return;

			this.useCount--;

			if (this.isMaxLevel)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}
	}
}