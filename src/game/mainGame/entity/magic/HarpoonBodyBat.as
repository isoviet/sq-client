package game.mainGame.entity.magic
{
	import utils.starling.StarlingAdapterMovie;

	public class HarpoonBodyBat extends HarpoonBody
	{
		public function HarpoonBodyBat():void
		{
			super();
		}

		override protected function getView():StarlingAdapterMovie
		{
			return new StarlingAdapterMovie(new BatmanHarpoonView());
		}
	}
}