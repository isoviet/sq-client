package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.utils.Timer;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.entity.simple.BlueHollowBody;
	import game.mainGame.entity.simple.HollowBody;
	import game.mainGame.entity.simple.RedHollowBody;
	import game.mainGame.perks.ICounted;
	import screens.ScreenGame;

	public class PerkShamanSquirrelHappiness extends PerkShamanSelective implements ICounted
	{
		static public const DELAY_TIME_SEC:int = 60;

		private var delayTimer:Timer = new Timer(DELAY_TIME_SEC * 10, 100);

		public function PerkShamanSquirrelHappiness(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_SQUIRRELS_HAPPINESS;

			this.delayTimer.delay -= countBonus() * 10;
			this.selectionsCount = countExtraBonus();
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

			var hollowClass:Class = null;

			switch (this.hero.team)
			{
				case Hero.TEAM_BLACK:
					return;
				case Hero.TEAM_BLUE:
					hollowClass = BlueHollowBody;
					break;
				case Hero.TEAM_RED:
					hollowClass = RedHollowBody;
					break;
				case Hero.TEAM_NONE:
					hollowClass = HollowBody;
					break;
			}

			var hollows:Array = this.hero.game.map.get(hollowClass);
			if (hollows.length == 0)
				return;

			var hollow:HollowBody = hollows.shift();

			var hero:Hero = this.hero.game.squirrels.get(heroId);

			if (!hero || !hero.hasNut)
				return;

			hero.teleportTo(hollow.position);

			ScreenGame.sendMessage(hero.player.id, "", ChatDeadServiceMessage.SQUIRREL_HAPPINESS_PERK);
		}

		override protected function onSelectionFinish(selectedHeroesCount:int):void
		{
			super.onSelectionFinish(selectedHeroesCount);

			if (this.delayTimer.delay == 0 || !this.hero.isSelf || selectedHeroesCount == 0)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}
	}
}