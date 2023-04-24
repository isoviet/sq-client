package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;

	import game.mainGame.GameMap;
	import game.mainGame.SquirrelCollection;
	import sounds.GameSounds;

	import starling.filters.ColorMatrixFilter;

	public class PerkClothesCharli extends PerkClothes
	{
		static public var filter:ColorMatrixFilter = null;
		static public var _enabled:int = 0;

		static private var movieView:MovieClip = null;

		public function PerkClothesCharli(hero:Hero)
		{
			super(hero);
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return true;
		}

		override public function resetRound():void
		{
			super.resetRound();

			_enabled = 0;

			if (movieView != null && movieView.parent != null)
				movieView.parent.removeChild(movieView);
			movieView = null;

			if (!SquirrelCollection.instance || !GameMap.instance)
				return;
			SquirrelCollection.instance.filters = [];
			GameMap.instance.filters = [];
		}

		override public function dispose():void
		{
			super.dispose();

			if (movieView != null && movieView.parent != null)
				movieView.parent.removeChild(movieView);
			movieView = null;
		}

		override protected function activate():void
		{
			super.activate();

			this.enabled = true;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.enabled = false;
		}

		public function set enabled(value:Boolean):void
		{
			var lastState:Boolean = this.enabled;
			_enabled += value ? 1 : -1;

			if (lastState == this.enabled)
				return;
			if (!SquirrelCollection.instance || !GameMap.instance)
				return;
			if (this.enabled)
			{
				filter = new ColorMatrixFilter();
				filter.adjustSaturation(-1);
			}
			SquirrelCollection.instance.filters = this.enabled ? [filter] : [];
			GameMap.instance.filters = this.enabled ? [filter] : [];

			if (this.enabled)
			{
				if (movieView == null)
					movieView = new CharliPerkView();
				movieView.mouseEnabled = false;
				movieView.mouseChildren = false;
				movieView.x = Config.GAME_WIDTH * 0.5;
				movieView.y = Config.GAME_HEIGHT * 0.5;
				if (!Game.gameSprite.contains(movieView))
					Game.gameSprite.addChild(movieView);

				GameSounds.play("perk_chaplin");
			}
			else
			{
				if (movieView != null && Game.gameSprite.contains(movieView))
					Game.gameSprite.removeChild(movieView);
			}
		}

		public function get enabled():Boolean
		{
			return _enabled > 0;
		}
	}
}