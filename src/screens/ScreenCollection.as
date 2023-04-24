package screens
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonFooterTab;
	import buttons.ButtonScreenshot;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import dialogs.Dialog;
	import game.gameData.CollectionManager;
	import game.gameData.EducationQuestManager;
	import loaders.ScreensLoader;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import views.storage.CollectionsView;
	import views.storage.ScratsClothesView;

	public class ScreenCollection extends Screen
	{
		static public const FORMATS:Array = [new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653), new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFCC33), new TextFormat(GameField.PLAKAT_FONT, 16, 0x554623)];

		static private var _instance:ScreenCollection;

		private var inited:Boolean = false;

		private var buttonsGroup:ButtonTabGroup;
		private var buttonClothes:ButtonTab;
		private var buttonCollections:ButtonTab;

		public function ScreenCollection():void
		{
			_instance = this;

			super();
		}

		static public function get instance():ScreenCollection
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
			EducationQuestManager.done(EducationQuestManager.COLLECTIONS);
		}

		private function init():void
		{
			addChild(new ScreenCollectionBackground);

			var field:GameField = new GameField(gls("Коллекции"), 0, 5, new TextFormat(GameField.PLAKAT_FONT, 21, 0xFFCC00));
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

			var collectionView:CollectionsView = new CollectionsView();
			addChild(collectionView);

			var clothesView:ScratsClothesView = new ScratsClothesView();
			addChild(clothesView);

			this.buttonCollections = new ButtonTab(new ButtonFooterTab(gls("Наборы коллекций"), FORMATS, ButtonCollectionTabBack, 6));
			this.buttonCollections.x = 17;
			this.buttonCollections.y = 42;

			this.buttonClothes = new ButtonTab(new ButtonFooterTab(gls("Награда за коллекции"), FORMATS, ButtonCollectionTabBack, 6));
			this.buttonClothes.x = 451;
			this.buttonClothes.y = 42;

			this.buttonsGroup = new ButtonTabGroup();
			this.buttonsGroup.insert(this.buttonCollections, collectionView);
			this.buttonsGroup.insert(this.buttonClothes, clothesView);
			addChild(this.buttonsGroup);

			CollectionManager.loadSelf();
		}
	}
}