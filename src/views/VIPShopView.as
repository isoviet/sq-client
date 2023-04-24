package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import events.GameEvent;
	import game.gameData.GameConfig;
	import game.gameData.VIPManager;

	import utils.FieldUtils;

	public class VIPShopView extends Sprite
	{
		static protected const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFCC00);
		static protected const FORMAT_TEXT:TextFormat = new TextFormat(null, 12, 0x673401, true);

		private var imageInfo:ElementShopInfoDesk = null;
		private var buttonDay:ButtonBase = null;
		private var buttonWeek:ButtonBase = null;

		public function VIPShopView():void
		{
			init();

			this.y = 165;
		}

		private function init():void
		{
			addChild(new ImageShopPotionBack()).y = -60;
			addChild(new VIPShopImage).x = 240;

			addChild(new GameField(gls("VIP-статус"), 410, 10, new TextFormat(null, 16, 0x663300, true)));

			this.imageInfo = new ElementShopInfoDesk();
			this.imageInfo.x = 370;
			this.imageInfo.y = 215;
			this.imageInfo.text = gls("Активен");
			addChild(this.imageInfo);

			this.buttonDay = new ButtonBase(GameConfig.getVIPCoinsPrice(VIPManager.VIP_DAY) + " -", 80);
			this.buttonDay.x = 360;
			this.buttonDay.y = 265;
			this.buttonDay.addEventListener(MouseEvent.CLICK, buyDay);
			addChild(this.buttonDay);
			FieldUtils.replaceSign(this.buttonDay.field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonDay.field.x, -3, false, false);

			this.buttonWeek = new ButtonBase(GameConfig.getVIPCoinsPrice(VIPManager.VIP_WEEK) + " -", 80);
			this.buttonWeek.x = 470;
			this.buttonWeek.y = 265;
			this.buttonWeek.addEventListener(MouseEvent.CLICK, buyWeek);
			addChild(this.buttonWeek);
			FieldUtils.replaceSign(this.buttonWeek.field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonWeek.field.x, -3, false, false);

			var field:GameField = new GameField(gls("На день"), 0, 245, FORMAT_TEXT);
			field.x = 397 - int(field.textWidth * 0.5);
			addChild(field);

			field = new GameField(gls("На неделю"), 0, 245, FORMAT_TEXT);
			field.x = 507 - int(field.textWidth * 0.5);
			addChild(field);

			var names:Array = [gls("Восстановление энергии\nдо максимума"), gls("+100 маны ежедневно"),
				gls("Макс. энергия 300\nВосполнение 2 эн./мин."), gls("Доступ к чату VIP игроков"), gls("Золотые крылья рядом с именем"),
				gls("Одно бесплатное воскрешение на раунде"), gls("х2 скорость получения опыта белкой и шаманом")];

			var classes:Array = [ImageGetEnergyRefill, ImageGetMana100Regen, ImageGetEnergy300Max, ImageGetChat, ImageGetVipView,
						ImageGetReborn, ImageGetDoubleExp];

			for (var i:int = 0; i < names.length; i++)
			{
				var sprite:Sprite = new Sprite();
				sprite.x = 10 + (i % 4) * 220;
				sprite.y = 340 + int(i / 4) * 60;
				addChild(sprite);

				var image:DisplayObject = new classes[i];
				sprite.addChild(image);

				field = new GameField(names[i], image.width + 5, 0, FORMAT_TEXT);
				field.wordWrap = true;
				field.width = 170;
				field.y = (image.height - field.textHeight) * 0.5 - 2;
				sprite.addChild(field);
			}

			VIPManager.addEventListener(GameEvent.VIP_START, onChangeState);
			VIPManager.addEventListener(GameEvent.VIP_END, onChangeState);

			onChangeState(null);
		}

		private function buyDay(e:MouseEvent):void
		{
			VIPManager.buy(VIPManager.VIP_DAY);
		}

		private function buyWeek(e:MouseEvent):void
		{
			VIPManager.buy(VIPManager.VIP_WEEK);
		}

		private function onChangeState(e:GameEvent):void
		{
			onChange();

			if (VIPManager.haveVIP)
				EnterFrameManager.addPerSecondTimer(onChange);
			else
				EnterFrameManager.removePerSecondTimer(onChange);
		}

		private function onChange():void
		{
			this.imageInfo.visible = VIPManager.haveVIP;
			this.imageInfo.value = VIPManager.durationString;
		}
	}
}