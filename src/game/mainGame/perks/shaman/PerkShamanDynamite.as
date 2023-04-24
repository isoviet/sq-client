package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.utils.Timer;

	import game.mainGame.Cast;
	import game.mainGame.entity.simple.BurstBody;
	import game.mainGame.perks.ICounted;

	public class PerkShamanDynamite extends PerkShamanCast implements ICounted
	{
		static public const DELAY_TIME_SEC:int = 20;

		static public const POWER_FACTOR:int = 20;
		static public const RADIUS_FACTOR:int = 20;

		private var delayTimer:Timer = new Timer(DELAY_TIME_SEC * 10, 100);

		public function PerkShamanDynamite(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_DYNAMITE;
			this.delayTimer.delay -= countBonus() * 10;
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

			super.dispose();
		}

		override public function resetRound():void
		{
			this.delayTimer.reset();

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
			var dynamite:BurstBody = new BurstBody();
			if (this.levelFree == 3)
				dynamite.power *= (1 + POWER_FACTOR / 100);

			if (this.levelPaid >= 2)
				dynamite.radius *= (1 + RADIUS_FACTOR / 100);

			dynamite.affectShaman = !this.isMaxLevel;

			this.castObject = dynamite;
		}

		override protected function onCast(result:String):void
		{
			if (this.hero.game.cast.castObject != this.castObject)
				return;

			super.onCast(result);

			if (result != Cast.CAST_COMPLETE)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}
	}
}