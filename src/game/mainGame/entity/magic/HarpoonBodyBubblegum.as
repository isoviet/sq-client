package game.mainGame.entity.magic
{
	import game.mainGame.entity.view.RopeView;

	import utils.starling.StarlingAdapterMovie;

	public class HarpoonBodyBubblegum extends HarpoonBody
	{
		public function HarpoonBodyBubblegum():void
		{
			super();
		}

		override protected function getView():StarlingAdapterMovie
		{
			return new StarlingAdapterMovie(new BubblegumHarpoonView());
		}

		override protected function getRopeView():RopeView
		{
			return new RopeView(BubblegumSegmentView);
		}
	}
}