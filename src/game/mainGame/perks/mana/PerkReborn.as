package game.mainGame.perks.mana
{
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenSchool;
	import screens.Screens;

	public class PerkReborn extends PerkMana
	{
		public function PerkReborn(hero:Hero):void
		{
			super(hero);
			this.delay = 0;

			this.code = PerkFactory.SKILL_RESURECTION;
		}

		override public function get switchable():Boolean
		{
			return false;
		}

		override public function get available():Boolean
		{
			var screenAvalible:Boolean = Screens.active is ScreenGame || (Screens.active is ScreenSchool && (this.code in ScreenSchool.allowedPerks)) || (Screens.active is ScreenEdit && (this.code in ScreenEdit.allowedPerks));

			return this.hero && this.hero.isDead && !this.hero.inHollow && screenAvalible;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.teleport(Hero.TELEPORT_DESTINATION_SHAMAN);

			this.active = false;
		}
	}
}