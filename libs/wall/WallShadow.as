package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import landing.game.mainGame.gameLending.SquirrelGameLending;

	public class WallShadow extends MovieClip
	{
		static public const PIXELS_TO_METRE:int = 10;
		static public const VELOCITY_ITERATIONS:int = 10;
		static public const POSITION_ITERATIONS:int = 8;

		static public const SELF_ID:int = 1;

		static public const WIDTH:int = 607;
		static public const HEIGHT:int = 412;

		static private var _instance:WallShadow;

		private var owner:DisplayObject;
		private var squirrelGame:SquirrelGameLending = null;

		static public function get stage():Stage
		{
			return _instance.owner.stage
		}

		public function WallShadow(owner:DisplayObject):void
		{
			_instance = this;

			this.owner = owner;

			super();

			this.squirrelGame = new SquirrelGameLending();
			addChild(this.squirrelGame);
		}
	}
}