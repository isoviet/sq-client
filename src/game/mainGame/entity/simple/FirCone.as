package game.mainGame.entity.simple
{
	import utils.starling.StarlingAdapterSprite;

	public class FirCone extends Poise
	{
		public function FirCone():void
		{
			super();

			if (this.view)
				removeChildStarling(this.view);
			this.view = new StarlingAdapterSprite(new FirConeView());
			this.view.x = -13.5;
			this.view.y = -13.5;
			addChildStarling(this.view);
		}
	}
}