package game.mainGame.entity.editor
{
	import game.mainGame.entity.simple.InvisibleBody;

	import utils.starling.StarlingAdapterMovie;

	public class HintArrowObject extends InvisibleBody
	{
		public function HintArrowObject():void
		{
			var view:StarlingAdapterMovie = new StarlingAdapterMovie(new ArrowMovie());
			view.rotation = -90;
			view.x = -13;
			view.y = -2;
			addChildStarling(view);
		}
	}

}