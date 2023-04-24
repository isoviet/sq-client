package game.mainGame.entity.magic
{
	import utils.starling.StarlingAdapterMovie;

	public class HarpoonBodyCat extends HarpoonBody
	{
		public function HarpoonBodyCat():void
		{
			super();
		}

		override protected function getView(): StarlingAdapterMovie
		{
			return new StarlingAdapterMovie(new CatwomanHarpoonView());
		}
	}
}