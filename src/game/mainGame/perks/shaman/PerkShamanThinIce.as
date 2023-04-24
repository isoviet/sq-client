package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.utils.Timer;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.perks.ICounted;
	import screens.ScreenGame;

	public class PerkShamanThinIce extends PerkShamanSelective implements ICounted
	{
		static private const MAX_LEVEL_DELAY_BONUS:int = 30 * 1000;

		private var useCount:int = 0;
		private var delayTimer:Timer = new Timer(600, 100);

		public function PerkShamanThinIce(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_THIN_ICE;
			this.useCount = countBonus();

			this.delayTimer.delay -= this.isMaxLevel ? MAX_LEVEL_DELAY_BONUS / 100 : 0;
		}

		override public function get available():Boolean
		{
			return super.available && !this.delayTimer.running && this.useCount > 0;
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
			this.useCount = countBonus();
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

		override protected function set selectedHero(heroId:int):void
		{
			if (!this.hero.game)
				return;

			var hero:Hero = this.hero.game.squirrels.get(heroId);
			if (!hero)
				return;

			super.selectedHero = heroId;

			hero.ghost = true;
			hero.dispatchEvent(new SquirrelEvent(SquirrelEvent.GHOST, hero));

			this.useCount--;
			ScreenGame.sendMessage(hero.player.id, "", ChatDeadServiceMessage.THIN_ICE_PERK);
		}

		override protected function onSelectionFinish(selectedHeroesCount:int):void
		{
			super.onSelectionFinish(selectedHeroesCount);

			if (!this.hero.isSelf || selectedHeroesCount == 0)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}
	}
}