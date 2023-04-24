package game.mainGame.perks.shaman
{
	import flash.events.Event;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.entity.shaman.IceCube;
	import screens.ScreenGame;

	public class PerkShamanIceCube extends PerkShamanSelective
	{
		private var useCount:int = 0;

		public function PerkShamanIceCube(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_ICE_CUBE;
			this.useCount = countBonus();
		}

		override public function get available():Boolean
		{
			return super.available && this.useCount > 0;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override public function resetRound():void
		{
			this.useCount = countBonus();
			super.resetRound();
		}

		override protected function set selectedHero(heroId:int):void
		{
			if (!this.hero || !this.hero.game)
				return;

			var hero:Hero = this.hero.game.squirrels.get(heroId);

			super.selectedHero = heroId;

			if (!hero || !this.hero.isSelf)
				return;

			ScreenGame.sendMessage(hero.player.id, "", ChatDeadServiceMessage.ICE_CUBE_PERK);

			var iceCube:IceCube = new IceCube();
			iceCube.heroId = hero.id;
			iceCube.size *= (1 + countExtraBonus() / 100);
			iceCube.objectFixture = this.isMaxLevel;
			this.hero.game.map.createObjectSync(iceCube, true);

			this.useCount--;
		}

		override protected function checkHero(hero:Hero):Boolean
		{
			return super.checkHero(hero) && !hero.frozen;
		}
	}
}