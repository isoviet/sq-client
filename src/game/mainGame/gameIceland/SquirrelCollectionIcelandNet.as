package game.mainGame.gameIceland
{
	import game.mainGame.gameNet.SquirrelCollectionNet;

	public class SquirrelCollectionIcelandNet extends SquirrelCollectionNet
	{
		public function SquirrelCollectionIcelandNet():void
		{
			super();

			this.heroClass = HeroIceland;
		}

		override protected function initCastItems():void
		{}

		override public function checkSquirrelsCount(resetAvailable:Boolean = true):void
		{}
	}
}