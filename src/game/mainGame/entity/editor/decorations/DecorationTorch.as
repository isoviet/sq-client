package game.mainGame.entity.editor.decorations
{
	import Box2D.Dynamics.b2World;

	import utils.starling.StarlingAdapterMovie;

	public class DecorationTorch extends Decoration
	{
		private var view:StarlingAdapterMovie = null;

		public function DecorationTorch():void
		{
			super(null);
			this.view = new StarlingAdapterMovie(new Torch);
			this.view.x = -3;
			this.view.y = 3;
			this.view.stop();
			addChildStarling(this.view);
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			this.view.play();
		}

		override public function dispose():void
		{
			this.view.removeFromParent();

			super.dispose();
		}
	}
}