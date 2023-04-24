package game.mainGame.perks.mana
{
	import game.mainGame.gameEvent.HeroZombie;

	public class PerkTeleport extends PerkMana
	{
		public function PerkTeleport(hero:Hero):void
		{
			super(hero);
			this.delay = 0;

			this.code = PerkFactory.SKILL_TELEPORT;
		}

		override public function get switchable():Boolean
		{
			return false;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.shaman && !(this.hero is HeroZombie);
		}

		override protected function activate():void
		{
			if (this.hero.isDead)
			{
				this.active = false;
				return;
			}

			super.activate();

			this.hero.teleport(Hero.TELEPORT_DESTINATION_SHAMAN);
			this.active = false;
		}
	}
}