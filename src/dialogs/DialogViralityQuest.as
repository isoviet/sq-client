package dialogs
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	import buttons.ButtonBase;
	import buttons.ButtonBaseMultiLine;
	import game.gameData.FlagsManager;
	import screens.ScreenLocation;
	import tape.TapeViralityQuestView;
	import views.GameBonusImageView;
	import views.GameBonusValueView;

	import protocol.Flag;

	import utils.FieldUtils;
	import utils.FiltersUtil;

	public class DialogViralityQuest extends Dialog
	{
		static private var _instance:DialogViralityQuest = null;

		private var timer:Timer = new Timer(5000);

		private var socialType:String = "";

		private var button:ButtonBase;
		private var tapeViralityQuestView:TapeViralityQuestView;

		public function DialogViralityQuest():void
		{
			super(gls("Выполни задания за награду"));

			var session:Object = PreLoader.loaderInfo.parameters as Object;

			if ("useApiType" in session)
				this.socialType = session['useApiType'];
			else if ("useapitype" in session)
				this.socialType = session['useapitype'];
			else
				this.socialType = Config.DEFAULT_API;

			init();
		}

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogViralityQuest();
			_instance.show();
		}

		static public function get inited():Boolean
		{
			return _instance != null;
		}

		static public function updateStep(id:uint):void
		{
			_instance.updateStep(id);
			if (ViralityQuestManager.questCompleted)
				_instance.dispose();
		}

		override public function showDialog():void
		{
			super.showDialog();

			updateSteps();

			this.timer.reset();
			this.timer.start();
		}

		override public function hideDialog():void
		{
			super.hideDialog();

			this.timer.stop();
		}

		private function init():void
		{

			this.timer.addEventListener(TimerEvent.TIMER, onRequest);

			var viralityQuestImage:ViralityQuestImage = new ViralityQuestImage();
			viralityQuestImage.y = -37;
			viralityQuestImage.x = -15;
			addChildAt(viralityQuestImage, 0);

			var field:GameField = new GameField(gls("монеты").toUpperCase(), 154, 27, new TextFormat(GameField.PLAKAT_FONT, 20, 0x4F0309, true, null, null, null, null, TextFormatAlign.CENTER), 143);
			field.mouseEnabled = false;
			addChild(field);

			field = new GameField(gls("бесплатно").toUpperCase(), 154, field.y + field.textHeight, new TextFormat(GameField.PLAKAT_FONT, 20, 0xFF5424, true, null, null, null, null, TextFormatAlign.CENTER), 143);
			field.mouseEnabled = false;
			addChild(field);

			var fieldAward:GameField = new GameField(ViralityQuestManager.COINS.toString() + "  -  ", 135, field.y + field.textHeight-2, new TextFormat(GameField.PLAKAT_FONT, 33, 0xFEFE98, true, null, null, null, null, TextFormatAlign.CENTER), 143);
			fieldAward.filters = [new DropShadowFilter(0, 0, 0x4F0309, 1, 4, 4, 10, 1)];
			fieldAward.mouseEnabled = false;
			addChild(fieldAward);

			FieldUtils.replaceSign(fieldAward, "-", ViralityCoinsImage, 1.2, 1.2, -fieldAward.x-3, -fieldAward.y-1, true, true);

			this.tapeViralityQuestView = new TapeViralityQuestView(this.socialType);
			this.tapeViralityQuestView.x = 100;
			this.tapeViralityQuestView.y = 35;
			addChild(this.tapeViralityQuestView);

			this.button = new ButtonBaseMultiLine(gls("Получить {0} -", 20).toUpperCase(), 180, 15, null, 1.3);
			this.button.x = 418;
			this.button.y = this.tapeViralityQuestView.y + this.tapeViralityQuestView.height + 9;
			this.button.enabled = ViralityQuestManager.questCompleted;
			this.button.filters = ViralityQuestManager.questCompleted ? [] : FiltersUtil.GREY_FILTER;
			this.button.addEventListener(MouseEvent.CLICK, onClick);
			this.button.scaleX = this.button.scaleY = 1.2;
			addChild(this.button);

			CONFIG::debug
			{
				this.addEventListener(MouseEvent.CLICK, onInfo);
			}

			FieldUtils.replaceSign(this.button.field, "-", ImageIconCoins, 0.9, 0.9, -this.button.field.x - 2, -5, true);

			place();

			hide();

			this.width = 739;
			this.height = 475;
		}

		private function onInfo(event:MouseEvent):void
		{
			var quests:Array = ViralityQuestManager.ALL_FLAG;
			var s:String = "";
			for (var i:int = 0; i < quests.length; i++)
				s += quests[i].toString() + "-" + ViralityQuestManager.checkQuestCompleted(quests[i]).toString() + ", ";
			Logger.add("viral flags " + s);
		}

		private function onClick(e:MouseEvent):void
		{
			var flag:Flag = FlagsManager.find(Flag.VIRALITY_BONUS);
			flag.setValue(flag.value | ViralityQuestManager.QUEST_FINISH);

			ScreenLocation.sortMenu();
			showAnimation();

			hideDialog();
		}

		private function showAnimation():void
		{
			this.button.visible = false;

			var imageCoin:ImageIconCoins = new ImageIconCoins();

			var awardsValueView:GameBonusValueView = new GameBonusValueView(ViralityQuestManager.COINS, this.x + this.button.x, this.y + this.button.y, new TextFormat(GameField.DEFAULT_FONT, 20, 0xFFF52C, true));
			Game.gameSprite.addChild(awardsValueView);

			var awardImageView:GameBonusImageView = new GameBonusImageView(imageCoin, awardsValueView.x + int(awardsValueView.width) + 3, awardsValueView.y + int(0.5 * (awardsValueView.height - imageCoin.height)), 165, 7);
			Game.gameSprite.addChild(awardImageView);
		}

		private function updateSteps():void
		{
			var quests:Array = ViralityQuestManager.QUESTS[socialType] || ViralityQuestManager.QUESTS["default"];
			for (var i:int = 0; i < quests.length; i++)
			{
				updateStep(quests[i]);
				ViralityQuestManager.requestQuestCompleted(quests[i]);
			}
		}

		private function updateStep(id:uint):void
		{
			this.tapeViralityQuestView.updateStep(id, ViralityQuestManager.checkQuestCompleted(id));

			this.button.enabled = ViralityQuestManager.questCompletedAllStep;
			this.button.filters = ViralityQuestManager.questCompletedAllStep ? [] : FiltersUtil.GREY_FILTER;
		}

		private function onRequest(e:TimerEvent):void
		{
			var quests:Array = ViralityQuestManager.QUESTS[socialType] || ViralityQuestManager.QUESTS["default"];
			for (var i:int = 0; i < quests.length; i++)
				ViralityQuestManager.requestQuestCompleted(quests[i]);
		}

		private function dispose():void
		{
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER, onRequest);
		}
	}
}