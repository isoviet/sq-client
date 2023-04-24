package game.mainGame.entity.controllers
{
	public class PlanetControllerPersonal extends PlanetController
	{
		public var playerId:int;

		public function PlanetControllerPersonal():void
		{
			super();
		}

		override protected function checkHero(hero:Hero):Boolean
		{
			if (hero == null)
				return true;
			return hero.id == this.playerId;
		}
	}
}