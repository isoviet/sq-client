package game.mainGame
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;

	import game.gameData.FlagsManager;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelCollectionEditor;
	import screens.ScreenGame;
	import screens.ScreenStarling;
	import screens.Screens;

	import interfaces.IDispose;

	import protocol.Flag;

	public class CameraController implements IUpdate, IDispose
	{
		static private const TOP_BORDER:int = 40;
		static private const BOTTOM_BORDER:int = 60;

		static private const MODE_SELF:int = 0;
		static private const MODE_SPECTATOR:int = 1;
		static private const MODE_SPY:int = 2;
		static private const MODE_EDITOR:int = 3;
		static private const MODE_FOLLOW:int = 4;

		static public var dispatcher:EventDispatcher = new EventDispatcher();
		static public var heroId:int = -1;

		private var game:SquirrelGame;

		public var enabled:Boolean = true;

		public function CameraController(game:SquirrelGame):void
		{
			this.game = game;
		}

		public function update(timeStep:Number = 0):void
		{
			if (!this.enabled)
				return;

			var state:int = this.state;
			var id:int = -1;

			switch (state)
			{
				case MODE_SELF:
					id = Game.selfId;
					break;
				case MODE_SPECTATOR:
					if (SquirrelCollection.instance.getShamans().length == 0)
						return;
					id = (this.game.squirrels.getShamans()[0] as Hero).id;
					break;
				case MODE_SPY:
					id = ScreenGame.cheaterId;
					break;
				case MODE_FOLLOW:
					id = Hero.self.followId;
					break;
			}

			var hero:Hero = SquirrelCollection.instance.get(state == MODE_EDITOR ? (SquirrelCollection.instance as SquirrelCollectionEditor).selfHeroId : id);
			if (hero == null)
				return;

			if (id != heroId)
			{
				heroId = id;
				dispatcher.dispatchEvent(new SquirrelEvent("CAMERA_CHANGE", hero));
			}
			var appendWidth: Number = (GameMap.gameScreenWidth - Config.GAME_WIDTH * ScreenStarling.scaleFactorScreen) / ScreenStarling.scaleFactorScreen;
			var appendHeight: Number = (GameMap.gameScreenHeight - Config.GAME_HEIGHT *  ScreenStarling.scaleFactorScreen) / ScreenStarling.scaleFactorScreen;
			if (!FullScreenManager.instance().fullScreen)
			{
				appendWidth = 0;
				appendHeight = 0;
			}
			var value:Point = new Point(-hero.x + (Config.GAME_WIDTH + appendWidth) / 2, -hero.y + (Config.GAME_HEIGHT) / 2);
			if (FlagsManager.has(Flag.CAMERA_TRACK) || ScreenGame.mode == Locations.VOLCANO_MODE || !(Screens.active is ScreenGame))
			{
				value.x = Math.max(value.x, (Config.GAME_WIDTH + appendWidth) - this.game.map.size.x);
				value.y = Math.max(value.y, 0);

				value.x = Math.min(value.x, 0);
				value.y = Math.min(value.y - BOTTOM_BORDER, - ((Config.GAME_HEIGHT) - TOP_BORDER - this.game.map.size.y));

				value.x += Math.max(((Config.GAME_WIDTH + appendWidth) - this.game.map.size.x) * 0.5, 0);
			}

			var dir:Point = value.subtract(this.game.shift);
			var length:Number = dir.length;

			dir.normalize(length / 6);

			this.game.shift = this.game.shift.add(dir);
		}

		public function dispose():void
		{
			this.enabled = false;
			this.game = null;
		}

		private function get state():int
		{
			if (SquirrelCollection.instance is SquirrelCollectionEditor)
				return MODE_EDITOR;
			if (ScreenGame.cheaterId > 0)
			{
				var cheater:Hero = SquirrelCollection.instance.get(ScreenGame.cheaterId);
				if (cheater && !cheater.inHollow && !cheater.isDead)
					return MODE_SPY;
				else
					return MODE_SPECTATOR;
			}
			if (Hero.selfAlive)
			{
				if (Hero.self.followId > 0)
					return MODE_FOLLOW;
				else
					return MODE_SELF;
			}

			return MODE_SPECTATOR;
		}
	}
}