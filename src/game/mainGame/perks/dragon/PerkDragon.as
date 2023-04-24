package game.mainGame.perks.dragon
{
	import game.mainGame.perks.PerkRechargeable;

	public class PerkDragon extends PerkRechargeable
	{
		public function PerkDragon(hero:Hero):void
		{
			super(hero);
		}

		override public function get available():Boolean
		{
			return this.hero && !this.hero.isDead && !this.hero.inHollow && this.hero.isDragon && (!this.active && charge == 100 || this.active);
		}

		override protected function initVars():void
		{
			this.inc = DragonPerkFactory.getData(this)['inc'];
			this.dec = DragonPerkFactory.getData(this)['dec'];
		}
	}
}