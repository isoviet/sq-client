package game.mainGame.entity.simple
{
	import Box2D.Dynamics.b2World;

	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.simple.GameBody;

	import utils.starling.StarlingAdapterMovie;

	public class InvisibleBody extends GameBody
	{
		protected var view:StarlingAdapterMovie = null;

		public function InvisibleBody(imageClass:Class = null, offsetX:int = 0, offsetY:int = 0):void
		{
			if (!imageClass)
				return;

			this.view = new StarlingAdapterMovie(new imageClass());
			this.view.x = -this.view.width / 2 + offsetX;
			this.view.y = -this.view.height + offsetY;

			addChildStarling(this.view);
		}

		override public function build(world:b2World):void
		{
			this.gameInst = world.userData as SquirrelGame;

			super.showDebug = false;
		}

		override public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			if (this.parentStarling != null)
				this.removeChildStarling(this);
		}
	}
}