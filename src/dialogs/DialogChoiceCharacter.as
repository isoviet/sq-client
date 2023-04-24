package dialogs
{
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import game.mainGame.GameMap;
	import views.CharactersButtonsView;

	import utils.ColorMatrix;

	public class DialogChoiceCharacter extends Dialog
	{
		static private const TEXT_FORMAT_RIBBORN:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14,
			0xffffff, null, null, null, null, null, TextFormatAlign.CENTER);

		private var becomeButtons:CharactersButtonsView = null;
		private var background:ImageDialogChoiceCharacter = null;

		protected var ribbornText:GameField = null;

		public function DialogChoiceCharacter():void
		{
			super(null, false, true, null, false);

			init();

			this.buttonClose.scaleX = this.buttonClose.scaleY = 0.7;
			this.buttonClose.x = 115;
			this.buttonClose.y = 25;
		}

		override public function show():void
		{
			super.show();

			this.becomeButtons.update();

			onChangeFullScreenState();
		}

		public function get available():Boolean
		{
			return this.becomeButtons.hasAvailable;
		}

		private function init():void
		{
			this.background = new ImageDialogChoiceCharacter();
			addChild(this.background);

			var colorMatrix:ColorMatrix = new ColorMatrix();

			var ribborn:ImageRibborn = new ImageRibborn();
			ribborn.stop();
			this.addChild(ribborn);
			ribborn.scaleX = 0.29;
			ribborn.scaleY = 0.9;
			ribborn.x = 22;
			ribborn.y = 31;
			colorMatrix.adjustColor(-44, -3, 14, -178);
			ribborn.filters = [new ColorMatrixFilter(colorMatrix)];

			this.ribbornText = new GameField(gls("Выбирай кем играть"), 23, 40, TEXT_FORMAT_RIBBORN, 117);
			this.ribbornText.filters = [new DropShadowFilter(0, 0, 0x081F3A, 1, 4, 4, 2)];
			addChild(this.ribbornText);

			this.becomeButtons = new CharactersButtonsView(ribbornText, this.background.bg);

			addChild(this.becomeButtons);

			place();

			this.width = 245;
			this.height = 180;

			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN,
				onChangeFullScreenState);
		}

		private function onChangeFullScreenState(event:Event = null):void
		{
			if(FullScreenManager.instance().fullScreen == true)
			{
				this.x = GameMap.gameScreenWidth - 163;
			}
			else
			{
				this.x = Config.GAME_WIDTH - 163;
			}

			this.y = 40;
		}
	}
}