package game.mainGame.gameDesertNet
{
	import game.mainGame.gameNet.CastNet;
	import game.mainGame.gameNet.SquirrelGameNet;

	public class SquirrelGameDesertNet extends SquirrelGameNet
	{
		private var isRoped:Boolean = false;

		public function SquirrelGameDesertNet(isRoped:Boolean = false):void
		{
			this.isRoped = isRoped;

			super();
		}

		override protected function init():void
		{
			this.cast = new CastNet(this);
			this.map = new GameMapDesertNet(this);
			this.squirrels = new SquirrelCollectionDesertNet(this.isRoped);
		}
	}
}