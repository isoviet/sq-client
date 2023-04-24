package screens
{
	import dialogs.DialogLocation;
	import game.mainGame.SquirrelGame;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import loaders.ScreensLoader;

	import utils.GuardUtil;

	public class ScreenEdit extends Screen
	{
		static private var _instance:ScreenEdit;

		static public var allowedPerks:Object = {};

		private var game:SquirrelGame = null;

		public function ScreenEdit():void
		{
			_instance = this;

			super();
		}

		static public function get instance():ScreenEdit
		{
			return _instance;
		}

		override public function firstShow():void
		{
			show();
		}

		override public function show():void
		{
			super.show();

			if (!ScreensLoader.loaded)
				return;

			GuardUtil.startRecheck();

			this.game = new SquirrelGameEditor();
			addChild(this.game);
			ScreenStarling.upLayer.addChild(this.game.getStarlingView());

			if (Game.editor_access != 0)
				DialogLocation.show();
			else
				(this.game as SquirrelGameEditor).onNew();
		}

		override public function hide():void
		{
			if (!this.game)
				return;

			if (this.game && this.game.getStarlingView() && ScreenStarling.upLayer.contains(this.game.getStarlingView()))
				ScreenStarling.upLayer.removeChild(this.game.getStarlingView());

			if (contains(this.game))
				removeChild(this.game);

			this.game.dispose();
			this.game = null;

			super.hide();

			GuardUtil.stopRecheck();
		}
	}
}