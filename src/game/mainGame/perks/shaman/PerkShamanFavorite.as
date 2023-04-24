package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.utils.Timer;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.perks.ICounted;
	import screens.ScreenGame;

	import protocol.Connection;
	import protocol.PacketClient;

	public class PerkShamanFavorite extends PerkShamanSelective implements ICounted
	{
		static public const DELAY_TIME_SEC:int = 60;

		private var delayTimer:Timer = new Timer(DELAY_TIME_SEC * 10, 100);

		public function PerkShamanFavorite(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_FAVORITE;

			this.delayTimer.delay -= countExtraBonus() * 10;
			this.selectionsCount = countBonus();
		}

		override public function get available():Boolean
		{
			return super.available && !this.delayTimer.running && this.hero.hasNut;
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
			super.resetRound();

			this.delayTimer.reset();
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

			if (!hero || hero.hasNut)
				return;

			super.selectedHero = heroId;

			ScreenGame.sendMessage(hero.player.id, "", ChatDeadServiceMessage.FAVORITE_PERK);

			if (!hero.isSelf)
				return;

			hero.setMode(Hero.NUT_MOD);
			Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
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