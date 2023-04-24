package game.mainGame.gameSurvivalNet
{
	import game.mainGame.gameNet.CastNet;
	import game.mainGame.gameNet.SquirrelGameNet;

	public class SquirrelGameSurvivalNet extends SquirrelGameNet
	{
		override protected function init():void
		{
			this.cast = new CastNet(this);
			this.map = new GameMapSurvivalNet(this);
			this.squirrels = new SquirrelCollectionSurvivalNet();
		}
	}
}