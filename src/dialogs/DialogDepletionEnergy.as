package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import events.DiscountEvent;
	import game.gameData.GameConfig;
	import game.gameData.VIPManager;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class DialogDepletionEnergy extends Dialog
	{
		static private const FORMAT:TextFormat = new TextFormat(null, 12, 0x673401, true);
		static private const FORMAT_CAPTION:TextFormat = new TextFormat(null, 12, 0x673401, true, null, null, null, null, 'center');

		static private const NAMES:Array = [gls("VIP на сутки за "), gls("VIP на неделю за "), gls("VIP на месяц за ")];

		static private var _instance:DialogDepletionEnergy;

		static private var locationId:int = 0;

		private var textField:GameField = null;

		private var spriteVIP:Sprite = new Sprite();
		private var spriteEnergy:Sprite = new Sprite();

		private var buttonsVIP:Vector.<ButtonBase> = new Vector.<ButtonBase>;

		public function DialogDepletionEnergy():void
		{
			this.textField = new GameField("", 0, 0, FORMAT_CAPTION);
			this.textField.width = 625;
			this.textField.wordWrap = true;
			addChild(this.textField);

			super(gls("Белка истощена"));

			initSpriteVIP();
			initSpriteEnergy();

			place();

			this.height += 30;
			this.buttonClose.x -= 25;

			DiscountManager.addEventListener(DiscountEvent.START, onDiscount);
			DiscountManager.addEventListener(DiscountEvent.END, onDiscount);
		}

		static public function show(id:int):void
		{
			if (_instance == null)
				_instance = new DialogDepletionEnergy();
			locationId = id;
			_instance.show();
		}

		override public function show():void
		{
			this.textField.text = gls("Для начала игры на локации «{0}» нужно хотя бы {1} энергии\nТы можешь пополнить запас энергии, купив:", Locations.getLocation(locationId).name, Locations.getLocation(locationId).cost);

			this.spriteEnergy.visible = true;

			Logger.add("show");
			super.show();
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 15;
			this.rightOffset = -5;
			this.topOffset = 10;
			this.bottomOffset = 0;
		}

		private function initSpriteVIP():void
		{
			this.spriteVIP = new Sprite();
			this.spriteVIP.y = 30;
			addChild(this.spriteVIP);

			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(650, 240, Math.PI / 2, 0, 0);

			this.spriteVIP.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			this.spriteVIP.graphics.drawRect(-10, 0, 650, 240);

			this.spriteVIP.graphics.beginFill(0xF7F4EC);
			this.spriteVIP.graphics.lineStyle(2, 0xF4E3CA);
			this.spriteVIP.graphics.drawRoundRect(0, 30, 145, 135,3);

			var image:DisplayObject = new VIPShopSmallImage();
			image.scaleX = image.scaleY = 1.5;
			image.x = 8;
			image.y = 33;
			this.spriteVIP.addChild(image);

			this.spriteVIP.addChild(new GameField(gls("VIP статус"), 150, 0, Dialog.FORMAT_CAPTION_16)).filters = Dialog.FILTERS_CAPTION;

			var names:Array = [gls("Макс. энергия 300\nВосполнение 2 эн./мин."), gls("Восстановление энергии\nдо максимума"), gls("+100 маны ежедневно"),
				gls("Одно бесплатное воскрешение на раунде"), gls("х2 скорость получения опыта белкой и шаманом"), gls("И многое другое!")];

			var classes:Array = [ImageGetEnergy300Max, ImageGetEnergyRefill, ImageGetMana100Regen,
				ImageGetReborn, ImageGetDoubleExp, ImageGetVipTotal];
			for (var i:int = 0; i < names.length; i++)
			{
				var sprite:Sprite = new Sprite();
				image = new classes[i];
				sprite.addChild(image);

				var field:GameField = new GameField(names[i], image.width + 10, 0, FORMAT);
				field.wordWrap = true;
				field.width = 140;
				field.y = (image.height - field.textHeight) * 0.5 - 2;
				sprite.addChild(field);

				sprite.x = 150 + (i % 2) * 240;
				sprite.y = 25 + int(i / 2) * 60;
				this.spriteVIP.addChild(sprite);
			}

			for (i = 0; i < 3; i++)
			{
				var button:ButtonBase = new ButtonBase(NAMES[i] + "  -   " + GameConfig.getVIPCoinsPrice(i), 200);
				button.x = 5 + i * 210;
				button.y = 200;
				button.name = i.toString();
				button.addEventListener(MouseEvent.CLICK, buyVIP);
				this.spriteVIP.addChild(button);
				FieldUtils.replaceSign(button.field, "-", ImageIconCoins, 0.7, 0.7, -button.field.x + 5, -3, false, false);

				this.buttonsVIP.push(button);
			}
		}

		private function initSpriteEnergy():void
		{
			var item:Object = DrinkItemsData.DATA[DrinkItemsData.ENERGY_BIG_ID];

			this.spriteEnergy = new Sprite();
			this.spriteEnergy.y = 270;
			addChild(this.spriteEnergy);

			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(650, 240, Math.PI / 2, 0, 0);

			this.spriteEnergy.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			this.spriteEnergy.graphics.drawRect(-10, 0, 650, 240);

			this.spriteEnergy.graphics.beginFill(0xF7F4EC);
			this.spriteEnergy.graphics.lineStyle(2, 0xF4E3CA);
			this.spriteEnergy.graphics.drawRoundRect(0, 30, 145, 135,3);

			var image:EnergyGlassBigImage = new EnergyGlassBigImage();
			image.x = 22;
			image.y = 31;
			this.spriteEnergy.addChild(image);

			this.spriteEnergy.addChild(new GameField(item['title'], 150, 0, Dialog.FORMAT_CAPTION_16)).filters = Dialog.FILTERS_CAPTION;

			var field:GameField = new GameField(DrinkItemsData.getDescription(DrinkItemsData.ENERGY_BIG_ID), 150, 25, FORMAT);
			field.wordWrap = true;
			field.width = 460;
			this.spriteEnergy.addChild(field);

			var button:ButtonBase = new ButtonBase(gls("Купить за") + "   -   " + GameConfig.getEnergyCoinsPrice(), 200);
			button.x = 215;
			button.y = 200;
			button.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				if (Game.buyWithoutPay(PacketClient.BUY_ENERGY_BIG, GameConfig.getEnergyCoinsPrice(), 0, Game.selfId))
					hide();
			});
			this.spriteEnergy.addChild(button);
			FieldUtils.replaceSign(button.field, "-", ImageIconCoins, 0.7, 0.7, -button.field.x + 5, -3, false, false);
		}

		private function buyVIP(e:MouseEvent):void
		{
			if (VIPManager.buy(int(e.currentTarget.name)))
				hide();
		}

		private function onDiscount(e:DiscountEvent):void
		{
			for (var i:int = 0 ; i < this.buttonsVIP.length; i++)
			{
				this.buttonsVIP[i].clear();

				this.buttonsVIP[i].field.text = NAMES[i] + "  -   " + GameConfig.getVIPCoinsPrice(i);
				FieldUtils.replaceSign(this.buttonsVIP[i].field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonsVIP[i].field.x + 5, -3, false, false);
			}
		}
	}
}