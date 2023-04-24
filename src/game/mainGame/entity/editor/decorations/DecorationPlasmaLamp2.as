package game.mainGame.entity.editor.decorations
{
	import Box2D.Dynamics.b2World;

	import utils.starling.StarlingAdapterMovie;

	public class DecorationPlasmaLamp2 extends Decoration
	{
		private var view: StarlingAdapterMovie = null;

		public function DecorationPlasmaLamp2():void
		{
			super(null);
			this.view = new StarlingAdapterMovie(new PlasmaLamp2);
			this.view.stop();
			this.view.y = -int(this.view.height / 2);
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