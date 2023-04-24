package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import game.mainGame.gameNet.SquirrelCollectionNet;
	import sounds.GameSounds;
	import statuses.Status;
	import tape.list.PlayerResultListElement;
	import tape.list.events.ListDataEvent;

	import utils.ColorMatrix;
	import utils.DateUtil;
	import utils.MovieClipUtils;
	import utils.StringUtil;

	public class DialogWinSquirrel extends DialogResults
	{
		static private const TEXT_FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 90, 0xffffff, null,
			null, null, null, null, TextFormatAlign.CENTER);

		private var fieldNuts:GameField = null;
		private var fieldExp:GameField = null;

		protected var fieldTime:GameField = null;
		protected var fieldPlace:GameField = null;
		protected var iconsLayer:Sprite = null;

		private var imageExp:DisplayObject = null;
		private var placeNumber:int = -1;
		private var isOtherPlaces:Boolean = false;

		public function DialogWinSquirrel()
		{
			super(MovieEndRoundDeath);
		}

		override public function show():void
		{
			super.show();
			updateBonus();
			MovieClipUtils.playOnceAndStop(this.animation);

			if (isOtherPlaces)
				GameSounds.play("dialog_place");
			else
				GameSounds.play("dialog_win");
		}

		override protected function init(classHeader:Class):void
		{
			super.init(classHeader);

			var format:TextFormat = new TextFormat(null, 14, 0x877735, true,
				null, null, null, null, TextFormatAlign.CENTER);

			this.iconsLayer = new Sprite();
			this.iconsLayer.x = 39;
			this.iconsLayer.y = 23;
			addChild(this.iconsLayer);

			var image:DisplayObject= new ImageBgNutsEndRound();
			new Status(image, gls("Орехи"));
			image.x = 226;
			image.y = 39;
			this.iconsLayer.addChild(image);

			image = new ImageBgTimeEndRound();
			image.x = 32;
			image.y = 58;
			new Status(image, gls("Время прохождения"));
			this.iconsLayer.addChild(image);

			this.imageExp = new ImageBgStarEndRound();
			this.imageExp.x = 115;
			this.imageExp.y = 39;
			new Status(this.imageExp, gls("Опыт"));
			this.iconsLayer.addChild(this.imageExp);

			this.fieldNuts = this.iconsLayer.addChild(new GameField("", 249, 48, format, 45)) as GameField;
			this.fieldExp = this.iconsLayer.addChild(new GameField("", 142, 48, format, 45)) as GameField;
			this.fieldTime = this.iconsLayer.addChild(new GameField("-:--", 13, 48, format, 60)) as GameField;

			this.fieldPlace = new GameField("", 106, -138, TEXT_FORMAT, 145);
			this.fieldPlace.filters = [new DropShadowFilter(0, 0, 0x6D0E1C, 1, 3, 3, 2)];
			this.headerLayer.addChild(this.fieldPlace);

			updateBonus();

			setBgHeight = 220;
		}

		override protected function updateListData(event:ListDataEvent):void
		{
			super.updateListData(event);

			updateBonus();
		}

		override protected function updateSelfData(event:ListDataEvent):void
		{
			super.updateSelfData(event);

			var self:PlayerResultListElement = this.listData.self;
			if (!self)
				return;

			if(self.number != this.placeNumber)
				updatePlace(self.number);

			this.fieldTime.text = (self.isDead || !self.initedTime) ? "-:--" : DateUtil.formatTime(self.time);
			updateBonus();
		}

		public function updatePlace(place:int):void
		{
			this.placeNumber = place;
			this.fieldPlace.text = String(place+1);

			if(place < 3)
				this.ribbonText.text = gls("Ты пришел ") + StringUtil.getNumerals(this.placeNumber+1);
			else
				this.ribbonText.text = gls("Поздравляем!");

			if(this.animation != null && this.headerLayer.contains(this.animation) == true)
				this.headerLayer.removeChild(this.animation);

			var textFormat:TextFormat = this.fieldPlace.getTextFormat(0);
			var colorMatrix:ColorMatrix = new ColorMatrix();

			this.isOtherPlaces = false;
			switch (place)
			{
				case 0:
					textFormat.color = 0xFAFFD7;
					colorMatrix.adjustColor(0, 0, 0, 0);
					this.animation = new MovieEndRound1();
					break;
				case 1:
					textFormat.color = 0xD9D9D9;
					colorMatrix.adjustColor(0, 0, 0, 0);
					this.animation = new MovieEndRound2();
					break;
				case 2:
					textFormat.color = 0xFFCAB1;
					colorMatrix.adjustColor(0, 0, 0, 0);
					this.animation = new MovieEndRound3();
					break;
				default:
					textFormat.color = 0xffffff;
					colorMatrix.adjustColor(0, 0, 0, -152);
					this.animation = new MovieEndRoundOther();
					this.isOtherPlaces = true;

			}

			this.animation.x = 175;
			this.animation.y = 63;

			MovieClipUtils.playOnceAndStop(this.animation);

			this.ribbon.filters = [new ColorMatrixFilter(colorMatrix)];
			this.fieldPlace.setTextFormat(textFormat,0);
			this.headerLayer.addChildAt(this.animation, 0);
		}

		public function updateBonus():void
		{
			this.fieldNuts.text = SquirrelCollectionNet.bonusAcorns.toString();
			this.fieldExp.text = SquirrelCollectionNet.bonusExperience.toString();
		}
	}
}