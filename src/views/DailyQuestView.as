package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.DialogDepletionEnergy;
	import game.gameData.FlagsManager;
	import game.gameData.PowerManager;
	import loaders.RuntimeLoader;
	import screens.ScreenGame;
	import statuses.Status;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketClient;

	import utils.Bar;
	import utils.FieldUtils;
	import utils.FiltersUtil;

	public class DailyQuestView extends Sprite
	{
		static public const REPLACES:Array = [
			{'replaceString': "#Ac", 'imageClass': ImageIconNut, 'scaleX': 1, 'scaleY': 1, 'shiftX': 4, 'shiftY': 2},
			{'replaceString': "#Ex", 'imageClass': ImageIconExp, 'scaleX': 1, 'scaleY': 1, 'shiftX': 4, 'shiftY': 2},
			{'replaceString': "#Mn", 'imageClass': ImageIconMana, 'scaleX': 1, 'scaleY': 1, 'shiftX': 4, 'shiftY': 2},
			{'replaceString': "#Co", 'imageClass': ImageIconCoins, 'scaleX': 1, 'scaleY': 1, 'shiftX': 4, 'shiftY': 2}
		];

		static private const FORMAT:TextFormat = new TextFormat(null, 13, 0x8E7A67, true);
		static private const FORMAT_TEXT:TextFormat = new TextFormat(null, 12, 0xFFFFFF, true);
		static private const FORMAT_AWARD:TextFormat = new TextFormat(null, 16, 0x6E5A47, true);
		static private const FORMAT_AWARD_CAPTION:TextFormat = new TextFormat(null, 13, 0xFFFFFF, true);

		static private const FILTER_AWARD:GlowFilter = new GlowFilter(0xE1C8A3, 1, 6, 6, 8);
		static private const FILTER_TEXT:GlowFilter = new GlowFilter(0x000000, 1, 2, 2, 1);

		static private const REJECT_PRICE:Array = [50, 100];

		private var dailyQuest:DailyQuest;
		private var callback:Function;

		private var fieldTime:GameField;
		private var fieldValue:GameField;
		private var bar:Bar;

		private var buttonBuy:ButtonBase;
		private var buttonStart:ButtonBase;
		private var buttonComplete:ButtonBase;
		private var buttonMore:ButtonBase;

		public function DailyQuestView(quest:DailyQuest, callback:Function):void
		{
			this.dailyQuest = quest;
			this.callback = callback;

			init();
		}

		private function init():void
		{
			addChild(new DailyQuestBack);

			var icon:DisplayObject = this.dailyQuest.icon;
			icon.x = 5;
			icon.y = 12;
			addChild(icon);

			addChild(new GameField(this.dailyQuest.name, 40, 10, FORMAT));
			addChild(getAwardSprite());

			var field:GameField = new GameField(gls("Награда"), 0, 3, FORMAT_AWARD_CAPTION);
			field.x = 295 + int((168 - field.textWidth) * 0.5);
			field.filters = [FILTER_AWARD];
			addChild(field);

			this.buttonMore = new ButtonBase(gls("Подробно"), 95);
			this.buttonMore.x = 475;
			this.buttonMore.y = 15;
			this.buttonMore.addEventListener(MouseEvent.CLICK, onMore);
			this.buttonMore.visible = !this.dailyQuest.isComplete;
			this.buttonMore.setBlue();
			addChild(this.buttonMore);

			this.buttonComplete = new ButtonBase(gls("Завершить"), 95);
			this.buttonComplete.x = 475;
			this.buttonComplete.y = 15;
			this.buttonComplete.addEventListener(MouseEvent.CLICK, onComplete);
			this.buttonComplete.visible = this.dailyQuest.isComplete;
			addChild(this.buttonComplete);

			this.bar = new Bar([
				{'image': new BarQuestBack(), 'X': 0, 'Y': 0},
				{'image': new BarQuestActive(), 'X': 0, 'Y': 0},
				{'image': new BarQuestActive(), 'X': 0, 'Y': 0}
			], 230);
			this.bar.x = 43;
			this.bar.y = 28;
			addChild(this.bar);

			this.fieldValue = new GameField("", 0, 0, FORMAT_TEXT);
			this.fieldValue.filters = [FILTER_TEXT];
			this.bar.addChild(this.fieldValue);

			this.fieldTime = new GameField("", 195, 65, FORMAT);
			addChild(this.fieldTime);

			this.buttonStart = new ButtonBase(gls("Выполнять"));
			this.buttonStart.x = 565 - this.buttonStart.width;
			this.buttonStart.y = 62;
			this.buttonStart.addEventListener(MouseEvent.CLICK, onStart);
			this.buttonStart.visible = !this.dailyQuest.isComplete;
			addChild(this.buttonStart);

			this.buttonBuy = new ButtonBase(gls("Сменить за {0} -  ", REJECT_PRICE[this.dailyQuest.difficulty]));
			this.buttonBuy.x = 15;
			this.buttonBuy.y = 62;
			this.buttonBuy.addEventListener(MouseEvent.CLICK, onBuy);
			this.buttonBuy.visible = !this.dailyQuest.isComplete;
			this.buttonBuy.setRed();
			addChild(this.buttonBuy);

			FieldUtils.replaceSign(buttonBuy.field, "-", ImageIconNut, 0.7, 0.7, -buttonBuy.field.x - 2, -3, true);

			update();
		}

		public function updateTime():void
		{
			this.fieldTime.text = gls("Задание сменится через: {0}", this.dailyQuest.leftTime);
		}

		public function update():void
		{
			this.fieldValue.text = this.dailyQuest.short + " " + this.dailyQuest.value + "/" + this.dailyQuest.maxValue;
			this.fieldValue.x = 115 - int(this.fieldValue.textWidth * 0.5);

			this.bar.setValues(this.dailyQuest.value, this.dailyQuest.maxValue);

			this.buttonMore.visible = !this.dailyQuest.isComplete;
			this.buttonComplete.visible = this.dailyQuest.isComplete;

			this.buttonBuy.enabled = !this.dailyQuest.isComplete;
			this.buttonBuy.filters = !this.dailyQuest.isComplete ? [] : FiltersUtil.GREY_FILTER;
			this.buttonStart.enabled = !this.dailyQuest.isComplete;
			this.buttonStart.filters = !this.dailyQuest.isComplete ? [] : FiltersUtil.GREY_FILTER;
		}

		private function onMore(e:MouseEvent):void
		{
			this.callback(this.dailyQuest);
		}

		private function onComplete(e:MouseEvent):void
		{
			Connection.sendData(PacketClient.DAILY_QUEST_COMPLETE, this.dailyQuest.difficulty);
		}

		private function onBuy(e:MouseEvent):void
		{
			Game.buy(PacketClient.BUY_DAILY_REJECT, 0, REJECT_PRICE[this.dailyQuest.difficulty], Game.selfId, this.dailyQuest.difficulty);
		}

		private function onStart(e:MouseEvent):void
		{
			if (!PowerManager.isEnoughEnergy(this.dailyQuest.location))
			{
				DialogDepletionEnergy.show(this.dailyQuest.location);
				return;
			}
			LoadGameAnimation.instance.close(false);

			var location:int = this.dailyQuest.location;
			var quest:int = this.dailyQuest.type;
			var questDifficulty:int = this.dailyQuest.difficulty;

			Analytics.dailyQuest();

			RuntimeLoader.load(function():void
			{
				FlagsManager.set(Flag.NOT_BE_SHAMAN);
				ScreenGame.start(location);
				DailyQuestManager.currentQuest = quest;
				DailyQuestManager.currentDifficulty = questDifficulty;
			}, true);
		}

		private function getAwardSprite():DisplayObject
		{
			var sprite:Sprite = new Sprite();
			var field:GameField = new GameField(this.dailyQuest.award, 0, 0, FORMAT_AWARD);
			sprite.addChild(field);

			FieldUtils.multiReplaceSign(field, REPLACES);
			for (var i:int = 0; i < sprite.numChildren; i++)
			{
				var object:DisplayObject = sprite.getChildAt(i);
				if (object is ImageIconNut)
					new Status(object, gls("Орехи"));
				if (object is ImageIconExp)
					new Status(object, gls("Опыт"));
				if (object is ImageIconMana)
					new Status(object, gls("Мана"));
			}

			sprite.x = 300 + int((168 - sprite.width) * 0.5);
			sprite.y = 22;
			return sprite;
		}
	}
}