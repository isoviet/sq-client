package screens
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonFooterTab;
	import buttons.ButtonScreenshot;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import dialogs.Dialog;
	import game.gameData.EducationQuestManager;
	import game.gameData.HolidayManager;
	import game.gameData.RatingManager;
	import loaders.ScreensLoader;
	import ratings.RatingView;
	import ratings.RatingViewFriend;
	import ratings.RatingViewHoliday;
	import ratings.RatingViewTop;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import utils.FiltersUtil;

	public class ScreenRating extends Screen
	{
		static public const FORMATS:Array = [new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653), new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653), new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653)];

		static public const HOLIDAY_TAB:int = 5;

		static private var _instance:ScreenRating;
		static public var selected:int = -1;

		private var inited:Boolean = false;
		private var buttonGroup:ButtonTabGroup = null;
		private var buttonsTab:Array = [];

		public function ScreenRating():void
		{
			_instance = this;

			super();
		}

		static public function get instance():ScreenRating
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

			if (selected != -1)
			{
				this.buttonGroup.setSelected(this.buttonsTab[selected]);
				selected = -1;
			}

			EducationQuestManager.done(EducationQuestManager.RATING);
		}

		private function init():void
		{
			addChild(new ScreenRatingBackground);

			var field:GameField = new GameField(gls("Рейтинги"), 0, 5, new TextFormat(GameField.PLAKAT_FONT, 21, 0xFFCC00));
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

			this.buttonGroup = new ButtonTabGroup();
			this.buttonGroup.x = HolidayManager.isHolidayEnd ? 35 : 0;
			var buttonArray:Array = [
				new ButtonFooterTab(gls("Моя лига"), FORMATS, ButtonRatingSquirrelLeague, 12, 13),
				new ButtonFooterTab(gls("Лучшие\nигроки"), FORMATS, ButtonRatingSquirreTop, 4, 18),
				new ButtonFooterTab(gls("Друзья"), FORMATS, ButtonRatingSquirrelFriends, 12, 12),
				new ButtonFooterTab(gls("Мой клан"), FORMATS, ButtonRatingClanLeague, 12, 16),
				new ButtonFooterTab(gls("Лучшие\nкланы"), FORMATS, ButtonRatingClanTop, 4, 35)];

			var viewsArray:Array = [new RatingView(RatingManager.PLAYER_TYPE), new RatingViewTop(RatingManager.PLAYER_TYPE),
				new RatingViewFriend(RatingManager.PLAYER_TYPE), new RatingView(RatingManager.CLAN_TYPE),
				new RatingViewTop(RatingManager.CLAN_TYPE)];

			if (!HolidayManager.isHolidayEnd)
			{
				buttonArray.push(new ButtonRatingHoliday());
				viewsArray.push(new RatingViewHoliday(RatingManager.PLAYER_TYPE));
			}

			for (var i:int = 0; i < buttonArray.length; i++)
			{
				viewsArray[i].y = 85;
				addChild(viewsArray[i]);

				var button:ButtonTab = new ButtonTab(buttonArray[i]);
				button.x = 166 * i;
				button.y = 35;
				if (i == 3 || i == 4)
				{
					button.filters = FiltersUtil.GREY_FILTER;
					button.block = true;
				}
				this.buttonGroup.insert(button, viewsArray[i]);
				this.buttonsTab.push(button);
			}
			addChild(this.buttonGroup);
		}
	}
}