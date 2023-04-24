package footers
{
	import flash.display.Sprite;
	import flash.events.Event;

	import events.ScreenEvent;
	import screens.Screen;
	import screens.ScreenClan;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.ScreenLocation;
	import screens.ScreenProfile;
	import screens.ScreenSchool;
	import screens.Screens;

	public class Footers extends Sprite
	{
		public static const FOOTER_HEIGHT:int = 115;
		public static const FOOTER_OFFSET:int = 505;

		static private const TYPE_TOP:int = 0;
		static private const TYPE_GAME:int = 1;
		static private const TYPE_EDIT:int = 2;
		static private const TYPE_LEARNING:int = 3;
		static private const TYPE_HOME:int = 4;

		static private var _instance:Footers = null;

		private var screenActive:Screen = null;

		public function Footers():void
		{
			super();

			_instance = this;

			init();
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onFullScreen);
		}

		static public function get instance():Footers
		{
			return _instance;
		}

		public function onFullScreen(e: Event): void
		{
			this.x = Game.starling.stage.stageWidth / 2 - Config.GAME_WIDTH / 2;
			this.y = Game.starling.stage.stageHeight - FOOTER_HEIGHT;
		}

		private function init():void
		{
			this.y = FOOTER_OFFSET;

			addChild(new FooterTop());
			addChild(new FooterGame());
			addChild(new FooterLearning());

			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			if (getFooterType(this.screenActive) == getFooterType(e.screen))
				return;

			hide();

			this.screenActive = e.screen;

			switch (getFooterType(e.screen))
			{
				case TYPE_TOP:
					FooterTop.show(false);
					break;
				case TYPE_HOME:
					FooterTop.show(true);
					break;
				case TYPE_GAME:
					FooterGame.show();
					break;
				case TYPE_LEARNING:
					FooterLearning.show();
					break;
				case TYPE_EDIT:
					FooterGame.hide();
					FooterTop.hide();
					FooterLearning.hide();
					break;
			}
		}

		private function hide():void
		{
			if (this.screenActive == null)
				return;

			switch (getFooterType(this.screenActive))
			{
				case TYPE_TOP:
				case TYPE_HOME:
					FooterTop.hide();
					break;
				case TYPE_GAME:
					FooterGame.hide();
					break;
				case TYPE_LEARNING:
					FooterLearning.hide();
					break;
				case TYPE_EDIT:
					FooterGame.hide();
					break;
			}
		}

		private function getFooterType(screen:Screen):int
		{
			if (screen is ScreenLocation)
				return TYPE_TOP;

			if (screen is ScreenProfile || screen is ScreenClan)
				return TYPE_HOME;

			if (screen is ScreenLearning)
				return TYPE_LEARNING;

			if (screen is ScreenGame || screen is ScreenSchool)
				return TYPE_GAME;

			if (screen is ScreenEdit)
				return TYPE_EDIT;

			return -1;
		}
	}
}