package game.mainGame.entity.magic
{
	import game.mainGame.entity.view.RopeView;
	import sounds.GameSounds;

	import utils.starling.StarlingAdapterMovie;

	public class SpiderWeb extends HarpoonBody
	{
		public var lastWeb:SpiderWeb = null;

		public function SpiderWeb():void
		{
			super();
		}

		override protected function getView():StarlingAdapterMovie
		{
			return new StarlingAdapterMovie(new SpiderWebInAir());
		}

		override protected function getRopeView():RopeView
		{
			return new RopeView(SpiderWebMiddle);
		}

		override public function get minLength():Number
		{
			return 10;
		}

		override protected function createJoint():void
		{
			super.createJoint();

			GameSounds.play("web");

			if (this.lastWeb)
				this.lastWeb.breakJoint();
		}
	}
}