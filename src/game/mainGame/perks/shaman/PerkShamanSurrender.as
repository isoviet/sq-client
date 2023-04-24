package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.utils.setTimeout;

	import game.mainGame.entity.simple.AcornBody;
	import headers.HeaderShort;

	public class PerkShamanSurrender extends PerkShamanActive
	{
		static private const TIME:int = 30;

		public function PerkShamanSurrender(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_SURRENDER;
		}

		override public function get available():Boolean
		{
			return super.available && this.activationCount < 1;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override protected function activate():void
		{
			this.hero.shaman = false;

			super.activate();

			if (this.hero.game && this.hero.game.cast && this.hero.game.cast.castObject)
				this.hero.game.cast.castObject = null;

			setTimeout(teleport, 500);

			this.hero.heroView.showActiveAura();
			this.hero.heroView.showPerkAnimation(new PerkShamanFactory.perkData[PerkShamanFactory.getClassById(this.code)]['buttonClass'], 1000);

			this.active = false;
		}

		private function teleport():void
		{
			if (!this.hero || !this.hero.game || !this.hero.game.map || this.hero.isDead)
				return;

			var acorns:Array = this.hero.game.map.get(AcornBody);

			if (acorns.length == 0 || !this.isMaxLevel || this.hero.hasNut || HeaderShort.getTimeInt() > TIME)
			{
				this.hero.teleport(Hero.TELEPORT_DESTINATION_SHAMAN);
				return;
			}

			this.hero.teleportTo((acorns.pop() as AcornBody).position);
		}
	}
}