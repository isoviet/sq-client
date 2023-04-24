package game.mainGame.gameSchool
{
	import game.mainGame.GameMap;
	import game.mainGame.SquirrelGame;
	import game.mainGame.events.HollowEvent;
	import screens.ScreenSchool;

	public class GameMapSchool extends GameMap
	{
		public function GameMapSchool(game:SquirrelGame):void
		{
			super(game);
		}

		override protected function onHollow(e:HollowEvent):void
		{
			super.onHollow(e);

			ScreenSchool.newGame();
		}
	}
}