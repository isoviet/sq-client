package game.mainGame.perks.shaman
{
	import game.mainGame.entity.shaman.LifetimePortal;
	import game.mainGame.entity.shaman.PortalGB;
	import game.mainGame.entity.shaman.PortalGR;
	import game.mainGame.entity.shaman.PortalGreen;

	public class PerkShamanPortalMaster extends PerkShamanCast
	{
		public function PerkShamanPortalMaster(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_PORTAL_MASTER;
		}

		override protected function initCastObject():void
		{
			var portal:LifetimePortal = null;
			switch (this.hero.team)
			{
				case Hero.TEAM_NONE:
				case Hero.TEAM_BLACK:
					portal = new PortalGreen();
					break;
				case Hero.TEAM_BLUE:
					portal = new PortalGB();
					break;
				case Hero.TEAM_RED:
					portal = new PortalGR();
					break;
			}
			portal.aging = !this.isMaxLevel;
			if (portal.aging)
				portal.lifeTime = countBonus() * 1000;

			this.castObject = portal;
		}
	}
}