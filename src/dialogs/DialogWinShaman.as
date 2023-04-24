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

	public class DialogWinShaman extends DialogResults
	{
		static private const TEXT_FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 90, 0xffffff, null,
			null, null, null, null, TextFormatAlign.CENTER);
		static private const TEXT_FORMAT_FIELDS:TextFormat = new TextFormat(null, 14, 0x877735, true,
			null, null, null, null, TextFormatAlign.CENTER);

		private var fieldNuts:GameField = null;
		private var fieldExtra:GameField = null;
		private var fieldExp:GameField = null;

		protected var fieldTime:GameField = null;
		protected var fieldPlace:GameField = null;
		protected var iconsLayer:Sprite = null;

		private var imageShamanExp:DisplayObject = null;

		public function DialogWinShaman()
		{
			super(MovieEndRoundShaman);
		}

		override public function show():void
		{
			super.show();
			updateBonus();
			MovieClipUtils.playOnceAndStop(this.animation);

			GameSounds.play("dialog_shaman");
		}

		override protected function init(classHeader:Class):void
		{
			super.init(classHeader);

			this.iconsLayer = new Sprite();
			this.iconsLayer.x = 39;
			this.iconsLayer.y = 23;
			addChild(this.iconsLayer);

			var image:DisplayObject= new ImageBgNutsEndRound();
			new Status(image, gls("Орехи"));
			image.x = 241;
			image.y = 39;
			this.iconsLayer.addChild(image);

			image = new ImageBgTimeEndRound();
			image.x = 19;
			image.y = 58;
			new Status(image, gls("Время прохождения"));
			this.iconsLayer.addChild(image);

			this.imageShamanExp = new ImageBgManaEndRound();
			this.imageShamanExp.x = 80;
			this.imageShamanExp.y = 44;
			new Status(this.imageShamanExp, gls("Шаманский опыт"));
			this.iconsLayer.addChild(this.imageShamanExp);

			var imageExp:ImageBgStarEndRound = new ImageBgStarEndRound();
			imageExp.x = 158;
			imageExp.y = 39;
			new Status(imageExp, gls("Опыт"));
			this.iconsLayer.addChild(imageExp);

			this.ribbonText.text = gls("Поздравляем!");

			this.fieldNuts = this.iconsLayer.addChild(new GameField("", 262, 48, TEXT_FORMAT_FIELDS, 45)) as GameField;
			this.fieldTime = this.iconsLayer.addChild(new GameField("-:--", 3, 48, TEXT_FORMAT_FIELDS, 60)) as GameField;
			this.fieldExtra = this.iconsLayer.addChild(new GameField("", 103, 48, TEXT_FORMAT_FIELDS, 45)) as GameField;
			this.fieldExp = this.iconsLayer.addChild(new GameField("", 186, 48, TEXT_FORMAT_FIELDS, 45)) as GameField;

			this.fieldPlace = new GameField("", 106, -138, TEXT_FORMAT, 145);
			this.fieldPlace.filters = [new DropShadowFilter(0, 0, 0x6D0E1C, 1, 3, 3, 2)];
			this.headerLayer.addChild(this.fieldPlace);

			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(0, 0, 0, -87);

			MovieClipUtils.playOnceAndStop(this.animation);
			this.ribbon.filters = [new ColorMatrixFilter(colorMatrix)];

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

			this.fieldTime.text = (self.isDead || !self.initedTime) ? "-:--" : DateUtil.formatTime(self.time);
			updateBonus();
		}

		public function updateBonus():void
		{
			this.fieldNuts.text = SquirrelCollectionNet.bonusAcorns.toString();
			this.fieldExtra.text = SquirrelCollectionNet.bonusShamanExp.toString();
			this.fieldExp.text = SquirrelCollectionNet.bonusExperience.toString();
		}
	}
}