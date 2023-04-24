package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.utils.Timer;

	import game.mainGame.Cast;
	import game.mainGame.entity.shaman.StormCloud;
	import game.mainGame.perks.ICounted;

	public class PerkShamanStorm extends PerkShamanCast implements ICounted
	{
		private var delayTimer:Timer = new Timer(500, 100);

		public function PerkShamanStorm(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_STORM;
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
			var cloud:StormCloud = new StormCloud();
			cloud.bonusTime = countBonus() * 1000;
			cloud.lifeTime = countExtraBonus() * 1000;
			cloud.playerId = this.hero.id;
			this.castObject = cloud;
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