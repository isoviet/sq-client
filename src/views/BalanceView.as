package views
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.DailyBonusManager;
	import game.gameData.EducationQuestManager;
	import loaders.RuntimeLoader;
	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.Screens;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import statuses.StatusCurrency;

	import com.api.Services;

	import utils.StringUtil;

	public class BalanceView extends Sprite
	{
		private var countNuts:GameField;
		private var countCoins:GameField;

		private var buttonBalance:SimpleButton;

		private var statusNuts:StatusCurrency = null;
		private var statusCoins:StatusCurrency = null;

		public var notify:HintPopup = null;

		public function BalanceView():void
		{
			this.visible = false;

			init();

			TagManager.onShow();
		}

		public function init():void
		{
			this.buttonMode = true;

			var frame:HeaderBalanceFrame = new HeaderBalanceFrame();
			addChild(frame);

			var image:DisplayObject = new ImageIconNut();
			image.scaleX = image.scaleY = 0.7;
			image.x = 5;
			image.y = 5;
			image.cacheAsBitmap = true;
			frame.addChild(image);

			this.countNuts = new GameField("", 30, 5, new TextFormat(null, 12, 0xFFFFFF, true));
			this.countNuts.mouseEnabled = false;
			frame.addChild(this.countNuts);
			this.statusNuts = new StatusCurrency(frame, gls("Орехи"), gls("За них можно покупать разные товары"));

			frame = new HeaderBalanceFrame();
			frame.x = 70;
			addChild(frame);

			image = new ImageIconCoins();
			image.scaleX = image.scaleY = 0.7;
			image.x = 6;
			image.y = 5;
			image.cacheAsBitmap = true;
			frame.addChild(image);

			this.countCoins = new GameField("", 30, 5, new TextFormat(null, 12, 0xFFFFFF, true));
			this.countCoins.mouseEnabled = false;
			frame.addChild(this.countCoins);
			frame.addEventListener(MouseEvent.CLICK, showBank);
			this.statusCoins = new StatusCurrency(frame, gls("Монетки"), gls("За них можно покупать уникальные товары и энергетики"), 145);

			this.buttonBalance = new ButtonBalance();
			this.buttonBalance.x = 135;
			this.buttonBalance.upState.cacheAsBitmap = true;
			this.buttonBalance.addEventListener(MouseEvent.CLICK, showBank);
			addChild(this.buttonBalance);
			new Status(buttonBalance, gls("Пополнение баланса"));

			this.notify = new HintPopup(16);
			this.notify.scaleX = this.notify.scaleY = 0.7;
			this.notify.inverted = HintPopup.INVERTED_Y;
			this.notify.text = gls("Забери свой бонус!");
			this.notify.x = this.buttonBalance.x - 60;
			this.notify.y = this.buttonBalance.y + 55;
			this.notify.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 1), new GlowFilter(0x003366, 1, 4, 4, 0.5)];
			this.notify.addEventListener(MouseEvent.CLICK, showBank);
			addChild(this.notify);

			Game.event(GameEvent.BALANCE_CHANGED, update);
			DailyBonusManager.addEventListener(GameEvent.DAILY_BONUS_UPDATE, function(e:GameEvent):void
			{
				notify.visible = DailyBonusManager.haveBonus && EducationQuestManager.allowDailyBonus;
			});
			EducationQuestManager.addEventListener(GameEvent.EDUCATION_QUEST_CHANGED, function(e:GameEvent):void
			{
				if (e.data['onComplete'])
					notify.visible = DailyBonusManager.haveBonus;
				else
					notify.visible = DailyBonusManager.haveBonus && EducationQuestManager.allowDailyBonus;
			});
			update();
		}

		override public function get width():Number
		{
			return this.buttonBalance.x + this.buttonBalance.width;
		}

		public function setCoins(value:int):void
		{
			if (value > 9999)
			{
				this.countCoins.text = (String(int(value / 1000)) + "к");
				this.statusCoins.setStatusCurrency("", gls("У тебя <b>{0}</b> {1}", String(value), StringUtil.word("монет", value)) + "\n" + gls("Перейди в банк чтобы пополнить счёт."));
			}
			else
			{
				this.countCoins.text = String(value);
				this.statusCoins.setStatusCurrency(gls("Монеты"), gls("Перейди в банк, чтобы пополнить счёт."));
			}
		}

		public function setNuts(value:int):void
		{
			if (value > 9999)
			{
				this.countNuts.text = (String(int(value / 1000)) + "к");
				this.statusNuts.setStatusCurrency("", gls("У тебя <b>{0}</b> {1}", String(value), StringUtil.word("орехов", value) + "\n" + gls("Белки очень запасливы. Собери как можно больше орехов.")));
			}
			else
			{
				this.countNuts.text = String(value);
				this.statusNuts.setStatusCurrency(gls("Орехи"), gls("Белки очень запасливы. Собери как можно больше орехов."));
			}
		}

		private function update(e:GameEvent = null):void
		{
			if ("nuts" in Game.self)
				setNuts(Game.self.nuts);
			if ("coins" in Game.self)
				setCoins(Game.self.coins);
		}

		private function showBank(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);

			TagManager.onUse();

			if (this.notify && this.notify.parent)
				this.notify.parent.removeChild(this.notify);

			RuntimeLoader.load(function():void
			{
				Services.bank.open();
			});
		}
	}
}