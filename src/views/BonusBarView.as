package views
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import dialogs.DialogHotWeekend;
	import dialogs.DialogShop;
	import events.GameEvent;
	import game.gameData.HotWeekendManager;
	import game.gameData.VIPManager;
	import loaders.RuntimeLoader;
	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.Screens;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;

	import utils.FiltersUtil;
	import utils.HtmlTool;

	public class BonusBarView extends Sprite
	{
		static private const VIP_TEXT:String = gls("\n\n     макс. 300 энергии\n     100 маны ежедневно\n     Доступ к VIP-чату\n     Золотые крылья рядом с именем\n     х2 опыта белкой и шаманом\n     Одно бесплатное воскрешение");

		private var buttonVIP:SimpleButton = null;
		private var buttonHotWeekend:SimpleButton = null;
		private var buttonDiscount:SimpleButton = null;
		private var ratingView:Sprite = null;

		private var statusVIP:Status = null;
		private var statusHotWeekend:Status = null;
		private var statusDiscount:Status = null;

		public function BonusBarView():void
		{
			this.buttonVIP = new ButtonIconVIP();
			this.buttonVIP.filters = VIPManager.haveVIP ? [] : FiltersUtil.GREY_FILTER;
			this.buttonVIP.addEventListener(MouseEvent.CLICK, onVIP);
			addChild(this.buttonVIP);

			this.buttonHotWeekend = new ButtonIconHotWeekend();
			this.buttonHotWeekend.filters = HotWeekendManager.isActive ? [] : FiltersUtil.GREY_FILTER;
			this.buttonHotWeekend.addEventListener(MouseEvent.CLICK, onHotWeekend);
			this.buttonHotWeekend.visible = HotWeekendManager.isWeekend;
			this.buttonHotWeekend.x = 30;
			addChild(this.buttonHotWeekend);

			this.buttonDiscount = new ButtonIconDiscount();
			this.buttonDiscount.x = 30;
			addChild(this.buttonDiscount);

			this.ratingView = new RatingScoreView();
			this.ratingView.x = 60;
			this.ratingView.y = 5;
			addChild(this.ratingView);

			this.statusVIP = new Status(this.buttonVIP, "", false, true);
			this.statusVIP.maxWidth = Config.isRus ? 225 : 250;

			this.statusHotWeekend = new Status(this.buttonHotWeekend, "", false, true);

			this.statusDiscount = new Status(this.buttonDiscount, "", false, true);
			this.statusDiscount.maxWidth = 240;

			VIPManager.addEventListener(GameEvent.VIP_START, onChangeState);
			VIPManager.addEventListener(GameEvent.VIP_END, onChangeState);

			HotWeekendManager.addEventListener(GameEvent.HOT_WEEKEND_CHANGED, onChangeHotWeekend);

			DiscountManager.addEventListener(Event.CHANGE, onDiscountChange);

			if (VIPManager.haveVIP)
				EnterFrameManager.addPerSecondTimer(onChangeVip);

			onChangeVip();
			onChangeHotWeekend();
			onDiscountChange();

			initIcons();
		}

		private function onChangeHotWeekend(e:GameEvent = null):void
		{
			this.buttonHotWeekend.filters = HotWeekendManager.isActive ? [] : FiltersUtil.GREY_FILTER;
			this.buttonHotWeekend.visible = HotWeekendManager.isWeekend;

			if (HotWeekendManager.isActive)
				this.statusHotWeekend.setStatus("<body><b>" + HotWeekendManager.caption + "</b>\n" + HtmlTool.span(gls("Активно"), "green") + gls(" - бесконечная энергия на все выходные!") + "</body>");
			else
				this.statusHotWeekend.setStatus("<body><b>" + HotWeekendManager.caption + "</b>\n" + HtmlTool.span(gls("Неактивно"), "red") + gls(" - бесконечная энергия на все выходные!") + "</body>");

			sort();
		}

		private function onChangeState(e:GameEvent):void
		{
			this.buttonVIP.filters = VIPManager.haveVIP ? [] : FiltersUtil.GREY_FILTER;

			if (VIPManager.haveVIP)
				EnterFrameManager.addPerSecondTimer(onChangeVip);
			else
				EnterFrameManager.removePerSecondTimer(onChangeVip);
		}

		private function onChangeVip():void
		{
			if (VIPManager.haveVIP)
				this.statusVIP.setStatus("<body><b>" + gls("VIP статус") + "</b>\n" + HtmlTool.span(gls("Активен"), "green") + ": " + VIPManager.durationString + VIP_TEXT + "</body>");
			else
				this.statusVIP.setStatus("<body><b>" + gls("VIP статус") + "</b>\n" + HtmlTool.span(gls("Неактивен"), "red") + VIP_TEXT + "</body>");
		}

		private function onDiscountChange(e:Event = null):void
		{
			var text:String = DiscountManager.textBonuses;
			this.buttonDiscount.visible = text != "";
			if (text != "")
				this.statusDiscount.setStatus("<body>" + text + "</body>");

			sort();
		}

		private function onVIP(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK);

			RuntimeLoader.load(function():void
			{
				DialogShop.selectTape(DialogShop.VIP);
			});
		}

		private function onHotWeekend(e:MouseEvent):void
		{
			if (HotWeekendManager.isActive)
				return;

			DialogHotWeekend.show();
		}

		private function sort():void
		{
			this.buttonHotWeekend.x = this.buttonDiscount.x + (this.buttonDiscount.visible ? 35 : 0);
			this.ratingView.x = this.buttonHotWeekend.x + (this.buttonHotWeekend.visible ? 35 : 0) + 20;
		}

		private function initIcons():void
		{
			var image:DisplayObject = new ImageIconEnergy();
			image.scaleX = image.scaleY = 0.5;
			image.x = 10;
			image.y = 46;
			this.statusVIP.addChild(image);

			image = new ImageIconMana();
			image.scaleX = image.scaleY = 0.5;
			image.x = 8;
			image.y = 60;
			this.statusVIP.addChild(image);

			image = new ImageIconChat();
			image.scaleX = image.scaleY = 0.5;
			image.x = 10;
			image.y = 75;
			this.statusVIP.addChild(image);

			image = new ImageIconGoldWing();
			image.x = 10;
			image.y = 87;
			this.statusVIP.addChild(image);

			image = new ImageIconExp();
			image.scaleX = image.scaleY = 0.5;
			image.x = 10;
			image.y = 101;
			this.statusVIP.addChild(image);

			image = new ImageIconRespawn();
			image.scaleX = image.scaleY = 0.5;
			image.x = 9;
			image.y = 115;
			this.statusVIP.addChild(image);
		}
	}
}