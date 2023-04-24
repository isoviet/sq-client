package views
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	import buttons.ButtonBase;
	import dialogs.DialogHolidayBooster;
	import events.GameEvent;
	import game.gameData.BundleManager;
	import game.gameData.ProduceManager;
	import statuses.Status;

	import utils.FiltersUtil;

	public class HolidayBoosterView extends Sprite
	{
		static protected const FORMAT_TEXT:TextFormat =  new TextFormat(GameField.PLAKAT_FONT, 17, 0xFFFFFF, null, null, null, null, null, "center");

		static protected const FORMAT_INFO:TextFormat =  new TextFormat(GameField.PLAKAT_FONT, 14, 0x748E16, null, null, null, null, null, "center");
		static public const FORMAT_BIG:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0xF2FFC4, null, null, null, null, null, "center");
		static public const FORMAT_BIG_NUMBER:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 32, 0xF2FFC4);

		private var imageCupFull:MovieClip = null;
		private var imageCupEmpty:MovieClip = null;
		private var buttonGet:ButtonBase = null;
		private var buttonInfo:ButtonBase = null;
		private var spriteInfo:Sprite = null;

		private var status:Status = null;

		public function HolidayBoosterView():void
		{
			super();

			init();

			this.x = 25;
			this.y = 370;

			ProduceManager.addEventListener(GameEvent.PRODUCE_BONUS_START, onChange);
			ProduceManager.addEventListener(GameEvent.PRODUCE_BONUS_END, onBonusTake);
			ProduceManager.addEventListener(GameEvent.PRODUCE_START, onChange);
			ProduceManager.addEventListener(GameEvent.PRODUCE_END, onChange);
			ProduceManager.addEventListener(GameEvent.PRODUCE_UPDATE, update);
			ProduceManager.addEventListener(GameEvent.PRODUCE_BONUS, onBonus);

			onChange();
			update(null);
		}

		private function onBonus(e:GameEvent):void
		{
			if (e.data['type'] != ProduceManager.HOLIDAY)
				return;
			var valueView:GameBonusValueView = new GameBonusValueView(ProduceManager.COUNT_HOLIDAY_IN_TIME, this.x + 70, this.y + 70, null, 1.5);
			Game.gameSprite.addChild(valueView);

			var imageView:GameBonusImageView = new GameBonusImageView(new ImageIconHoliday, valueView.x + int(valueView.width)+ 1, valueView.y - 2, -1, -1, 1.5);
			Game.gameSprite.addChild(imageView);
		}

		private function update(event:GameEvent):void
		{
			this.visible = (Game.unix_time + getTimer() / 1000 < BundleManager.HOLIDAY_BOOSTER_TIME) || ProduceManager.haveProducer(ProduceManager.HOLIDAY);

			var string:String = ProduceManager.timeString(ProduceManager.HOLIDAY);
			this.status.setStatus("<body><b>" + gls("Горшочек плодородия") + (string != "" ? "</b>\n" + string : "</b>") + "</body>");
		}

		private function onChange(event:GameEvent = null):void
		{
			if (event != null && event.data['type'] != ProduceManager.HOLIDAY)
				return;
			this.imageCupEmpty.visible = ProduceManager.haveProducer(ProduceManager.HOLIDAY) && !ProduceManager.haveBonus(ProduceManager.HOLIDAY);
			this.imageCupFull.visible = !this.imageCupEmpty.visible;
			this.imageCupFull.alpha = ProduceManager.haveProducer(ProduceManager.HOLIDAY) ? 1 : 0.3;
			this.buttonGet.visible = ProduceManager.haveProducer(ProduceManager.HOLIDAY);
			this.buttonGet.enabled = ProduceManager.haveBonus(ProduceManager.HOLIDAY);
			this.buttonGet.filters = ProduceManager.haveBonus(ProduceManager.HOLIDAY) ? [] : FiltersUtil.GREY_FILTER;
			this.spriteInfo.visible = this.buttonInfo.visible = !ProduceManager.haveProducer(ProduceManager.HOLIDAY);

			this.buttonMode = true;
		}

		private function onBonusTake(event:GameEvent):void
		{
			Logger.add("onBonusTake");
			if (event.data['type'] != ProduceManager.HOLIDAY)
				return;
			onChange(null);
		}

		private function init():void
		{
			this.graphics.beginFill(0xFFFFFF, 0.8);
			this.graphics.drawRoundRect(0, 0, 140, 140, 5);

			this.imageCupFull = new HolidayBoosterFull();
			this.imageCupFull.scaleX = this.imageCupFull.scaleY = 0.5;
			this.imageCupFull.addEventListener(MouseEvent.CLICK, onClick);
			this.imageCupFull.x = this.imageCupFull.y = 70;
			addChild(this.imageCupFull);

			this.imageCupEmpty = new HolidayBoosterEmpty();
			this.imageCupEmpty.scaleX = this.imageCupEmpty.scaleY = 0.5;
			this.imageCupEmpty.x = this.imageCupEmpty.y = 70;
			addChild(this.imageCupEmpty);

			this.buttonGet = new ButtonBase(gls("Забрать"));
			this.buttonGet.x = 70 - this.buttonGet.width * 0.5;
			this.buttonGet.y = 120;
			this.buttonGet.addEventListener(MouseEvent.CLICK, onClick);
			addChild(this.buttonGet);

			this.buttonInfo = new ButtonBase(gls("Подробнее"));
			this.buttonInfo.x = 70 - this.buttonInfo.width * 0.5;
			this.buttonInfo.y = 120;
			this.buttonInfo.setBlue();
			this.buttonInfo.addEventListener(MouseEvent.CLICK, onInfo);
			addChild(this.buttonInfo);

			this.spriteInfo = new Sprite();
			var field:GameField = new GameField(gls("Горшочек\nплодородия"), 0, 0, FORMAT_INFO);
			field.filters = [new GlowFilter(0xFFFF66, 1, 4, 4, 8), new GlowFilter(0x000033, 1, 4, 4, 0.5)];
			this.spriteInfo.addChild(field);

			field = new GameField("10", 0, 40, FORMAT_BIG_NUMBER);
			field.x = this.spriteInfo.width * 0.5 - field.textWidth - 3;
			field.filters = [new GlowFilter(0x660000, 1, 4, 4, 8)];
			this.spriteInfo.addChild(field);

			var icon:DisplayObject = new ImageIconHoliday();
			icon.x = this.spriteInfo.width * 0.5 + 3;
			icon.y = 43;
			icon.scaleX = icon.scaleY = 1.3;
			this.spriteInfo.addChild(icon);

			field = new GameField(gls("в день"), 0, 75, FORMAT_BIG);
			field.filters = [new GlowFilter(0x660000, 1, 4, 4, 8)];
			field.x = int((this.spriteInfo.width - field.width) * 0.5);
			this.spriteInfo.addChild(field);
			addChild(this.spriteInfo);

			this.spriteInfo.x = 70 - this.spriteInfo.width * 0.5;
			this.spriteInfo.y = 15;

			this.status = new Status(this, gls("Горшочек плодородия"), false, true);
		}

		private function onInfo(e:MouseEvent):void
		{
			DialogHolidayBooster.show();
		}

		private function onClick(event:MouseEvent):void
		{
			if (ProduceManager.haveBonus(ProduceManager.HOLIDAY))
				ProduceManager.getBonus(ProduceManager.HOLIDAY);
		}
	}
}