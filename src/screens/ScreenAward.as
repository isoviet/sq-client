package screens
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonScreenshot;
	import dialogs.Dialog;
	import game.gameData.EducationQuestManager;
	import loaders.ScreensLoader;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import views.AwardListView;

	public class ScreenAward extends Screen
	{
		static private var _instance:ScreenAward;

		static public var imageId:int = 0;

		private var awardView:AwardListView = null;

		private var inited:Boolean = false;

		public function ScreenAward():void
		{
			super();

			_instance = this;
		}

		static public function get instance():ScreenAward
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

			if (!this.inited)
			{
				init();
				this.inited = true;
			}

			this.awardView.onShow();
			EducationQuestManager.done(EducationQuestManager.ACHIEVE);
		}

		private function init():void
		{
			this.graphics.beginFill(0xF7F0DD);
			this.graphics.drawRect(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT);
			this.graphics.beginFill(0xB68E6C, 0.4);
			this.graphics.drawRect(0, 80, Config.GAME_WIDTH, 62);

			var field:GameField = new GameField(gls("Достижения"), 0, 5, new TextFormat(GameField.PLAKAT_FONT, 21, 0xFFCC00));
			field.x = int((Config.GAME_WIDTH - field.textWidth) * 0.5);
			field.filters = Dialog.FILTERS_CAPTION;
			addChild(field);

			var buttonExit:ButtonCross = new ButtonCross();
			buttonExit.x = 870;
			buttonExit.y = 10;
			buttonExit.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				GameSounds.play(SoundConstants.BUTTON_CLICK);
				Screens.show(Screens.screenToComeback);
			});
			addChild(buttonExit);

			var screenshotButton:ButtonScreenshot = new ButtonScreenshot(true);
			screenshotButton.x = 840;
			screenshotButton.y = 10;
			addChild(screenshotButton);

			this.awardView = new AwardListView();
			addChild(this.awardView);
		}
	}
}