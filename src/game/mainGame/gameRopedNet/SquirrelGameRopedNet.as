package game.mainGame.gameRopedNet
{
	import game.mainGame.gameNet.CastNet;
	import game.mainGame.gameNet.GameMapNet;
	import game.mainGame.gameNet.SquirrelGameNet;

	public class SquirrelGameRopedNet extends SquirrelGameNet
	{
		private var isSnake:Boolean;

		public function SquirrelGameRopedNet(isSnake:Boolean = false):void
		{
			this.isSnake = isSnake;

			super();
		}

		override protected function init():void
		{
			this.cast = new CastNet(this);
			this.map = new GameMapNet(this);
			this.squirrels = new SquirrelCollectionRopedNet(this.isSnake);
		}
	}
}