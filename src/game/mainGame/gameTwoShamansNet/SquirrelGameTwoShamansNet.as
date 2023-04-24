package game.mainGame.gameTwoShamansNet
{
	import game.mainGame.gameNet.CastNet;
	import game.mainGame.gameNet.SquirrelGameNet;

	public class SquirrelGameTwoShamansNet extends SquirrelGameNet
	{
		override protected function init():void
		{
			this.cast = new CastNet(this);
			this.map = new GameMapTwoShamansNet(this);
			this.squirrels = new SquirrelCollectionTwoShamansNet();
		}
	}
}