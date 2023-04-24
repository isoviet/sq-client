package dialogs
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import sounds.SoundConstants;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.StageQualityUtil;
	import utils.WallTool;

	public class DialogNewLevel extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 13px;
				color: #000000;
				font-weight: bold;
				text-align: center;
				letter-spacing: -1;
			}
			.redText {
				color: #D95F00;
			}
			.blue {
				font-size: 16px;
				color: #008DED;
			}
			.green {
				font-size: 16px;
				color: #38CC00;
			}
		]]>).toString();

		static private var NUMBER_IMAGES:Array = null;
		static private var NUMBER_SCALING:Array = [1.0, 0.75, 0.6];

		static private const WIDTH:int = 440;

		private var locationName:String = "";
		private var title:String = "";
		private var level:int = 0;
		private var awardSprite:Sprite = null;
		private var awardArray:Array = null;

		public function DialogNewLevel(level:int):void
		{
			super(gls("Поздравляем!"));

			this.level = level;
			this.title = Experience.getTitle(this.level);
			this.locationName = Locations.getLocationsName(this.level);
			this.sound = SoundConstants.REWARD;

			init();
		}

		override public function show():void
		{
			super.show();

			Connection.sendData(PacketClient.COUNT, PacketClient.CAN_REPOST, Game.self['type']);
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, 29, 0xFFCC00, null, null, null, null, null, "center");
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 1;
			this.rightOffset = 0;
			this.topOffset = 10;
			this.bottomOffset = 0;
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.awardSprite = new Sprite();
			this.awardSprite.mouseChildren = false;
			this.awardSprite.mouseEnabled = false;

			this.awardArray = [];

			var spriteImages:Sprite = new Sprite();
			spriteImages.addChild(getAwardImage(new ImageGetCoins, gls("1 золотая монета")));
			spriteImages.addChild(getAwardImage(new ImageGetPowers, gls("Мана и энергия\nвосстановлены")));

			for (var i:int = 0; i < spriteImages.numChildren; i++)
			{
				spriteImages.getChildAt(i).x = (i % 2) * 190 + (i == spriteImages.numChildren - 1 && i % 2 == 0 ? 95 : 0);
				spriteImages.getChildAt(i).y = int(i / 2) * 50;
			}

			pushAward(spriteImages);

			if (this.locationName != "")
				pushAward(gls("<body>Открыта локация <span class = 'redText'>«{0}»</span></body>", this.locationName));

			if (this.level == Game.LEVEL_TO_OPEN_CLANS)
				pushAward(gls("<body>Теперь тебе доступны <span class = 'redText'>Кланы</span></body>"));

			var fieldCaption:GameField = new GameField(gls("Ты достиг нового уровня"), 0, 0, new TextFormat(null, 18, 0x663C0D, true));
			fieldCaption.x = int((WIDTH - fieldCaption.textWidth) / 2);
			addChild(fieldCaption);

			var spriteLevel:Sprite = new Sprite();
			spriteLevel.y = fieldCaption.y + fieldCaption.height;

			var background:ImageLevelUpBack = new ImageLevelUpBack();
			spriteLevel.addChild(background);

			var spriteDigits:Sprite = getImageFromNumber(this.level);
			spriteDigits.x = int(background.width / 2 - spriteDigits.width / 2);
			spriteDigits.y = 77;
			spriteLevel.addChild(spriteDigits);

			spriteLevel.x = int(WIDTH / 2 - spriteLevel.width / 2);
			addChild(spriteLevel);

			var captionFormat:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0x8C653D);
			captionFormat.align = TextFormatAlign.CENTER;

			var textAwardField:GameField = new GameField(gls("Твоя награда:"), 0, 0, captionFormat);
			textAwardField.y = spriteLevel.y + spriteLevel.height - 20;
			textAwardField.mouseEnabled = false;
			textAwardField.wordWrap = true;
			textAwardField.width = WIDTH;
			textAwardField.visible = this.awardArray.length > 0;
			addChild(textAwardField);

			this.awardSprite.y = textAwardField.y + textAwardField.height + 5;
			this.awardSprite.x = WIDTH / 2 - this.awardSprite.width / 2 - 4;
			addChild(this.awardSprite);

			if (WallTool.canPost && this.level < 200)
			{
				var button:ButtonBase = new ButtonBase(gls("Получить и рассказать всем"));
				button.addEventListener(MouseEvent.CLICK, posting);
				button.x = int((WIDTH - button.width) / 2) + 15;
				button.y = this.awardSprite.y + this.awardSprite.height + 5;
				addChild(button);
			}

			for each (var award:Object in this.awardArray)
				award.x = int((this.awardSprite.width - award.width) / 2);

			place();

			this.height += 55;
			this.buttonClose.x -= 20;
		}

		private function pushAward(text:Object):void
		{
			if (text is String)
			{
				var style:StyleSheet = new StyleSheet();
				style.parseCSS(CSS);
				var awardField:GameField = new GameField(text as String, 0, 0, style);
				awardField.y = this.awardArray.length ? this.awardSprite.height: 0;
				this.awardSprite.addChild(awardField);
				this.awardArray.push(awardField);
			}
			else if (text is DisplayObject)
			{
				text.y = this.awardArray.length ? this.awardSprite.height: 0;
				this.awardSprite.addChild(text as DisplayObject);
				this.awardArray.push(text);
			}
		}

		private function getAwardImage(image:DisplayObject, text:String):Sprite
		{
			var answer:Sprite = new Sprite();
			image.scaleX = image.scaleY = 0.75;
			answer.addChild(image);

			var field:GameField = new GameField(text, 45, 0, new TextFormat(null, 12, 0x673401, true));
			field.y = 20 - int(field.textHeight * 0.5) - 2;
			answer.addChild(field);

			return answer;
		}

		private function posting(e:MouseEvent):void
		{
			var quality:String = Game.stage.quality;
			StageQualityUtil.toggleQuality(StageQuality.HIGH);

			var sprite:Sprite = new Sprite();

			var image:ImageLevelUpBack = new ImageLevelUpBack();
			image.x = -84;
			image.y = -22;
			sprite.addChild(image);

			var numbers:Sprite = getImageFromNumber(this.level);
			numbers.x = 130 - int(numbers.width * 0.5);
			numbers.y = 53;
			sprite.addChild(numbers);

			var emblem:DisplayObject = PreLoader.getLogo();
			emblem.scaleX = emblem.scaleY = Config.isRus ? 1.0 : 0.5;
			emblem.x = int((280 - emblem.width) * 0.5);
			emblem.y = 275 - emblem.height;
			sprite.addChild(emblem);

			var bd:BitmapData = new BitmapData(280, 280);
			bd.draw(sprite);

			NewsImageGenerator.save(bd, this.level.toString(), false);

			WallTool.place(Game.self, WallTool.WALL_EXP, this.level, new Bitmap(bd), gls("У меня уже {0} уровень «{1}» в игре Трагедия Белок ", this.level, this.title));

			StageQualityUtil.toggleQuality(quality);

			Connection.sendData(PacketClient.COUNT, PacketClient.LEVEL_REPOST, 0);

			hide();
		}

		private function get numberImages():Array
		{
			if (!NUMBER_IMAGES)
				NUMBER_IMAGES = [ImageLevelUp0, ImageLevelUp1, ImageLevelUp2, ImageLevelUp3, ImageLevelUp4, ImageLevelUp5, ImageLevelUp6, ImageLevelUp7, ImageLevelUp8, ImageLevelUp9];
			return NUMBER_IMAGES;
		}

		private function getImageFromNumber(value:int):Sprite
		{
			var answer:Sprite = new Sprite();

			if (value == 0)
				answer.addChild(new ImageLevelUp0);
			else while (value > 0)
			{
				for (var i:int = 0; i < answer.numChildren; i++)
					answer.getChildAt(i).x += 35;
				answer.addChildAt(new numberImages[value % 10], 0).x = 15;
				value = int(value / 10);
			}
			answer.scaleX = answer.scaleY = NUMBER_SCALING[answer.numChildren - 1];
			return answer;
		}
	}
}