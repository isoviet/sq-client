package game.mainGame.gameIceland
{
	import game.mainGame.gameNet.CastNet;
	import game.mainGame.gameNet.SquirrelGameNet;

	public class SquirrelGameIcelandNet extends SquirrelGameNet
	{
		public function SquirrelGameIcelandNet()
		{
			super();
		}

		override protected function init():void
		{
			this.cast = new CastNet(this);
			this.map = new GameMapIcelandNet(this);
			this.squirrels = new SquirrelCollectionIcelandNet();
		}
	}
}