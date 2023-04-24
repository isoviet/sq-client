package game.mainGame.gameSurvivalNet
{
	import Box2D.Dynamics.b2World;

	public class HeroSurvival extends Hero
	{
		public function HeroSurvival(playerId:int, world:b2World, x:int = 0, y:int = 0)
		{
			super(playerId, world, x, y);
		}

		override public function set shaman(value:Boolean):void
		{
			super.shaman = value;

			this.team = value ? TEAM_BLACK : TEAM_NONE;
		}
	}
}