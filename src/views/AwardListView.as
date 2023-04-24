package views
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import fl.containers.ScrollPane;

	import buttons.ButtonTabAward;
	import buttons.ButtonTabGroup;
	import events.GameEvent;
	import game.gameData.AwardManager;
	import screens.ScreenAward;
	import screens.Screens;
	import statuses.Status;

	import utils.Bar;

	public class AwardListView extends Sprite
	{
		static public const WIDTH:int = 400;
		static public const HEIGHT:int = 110;

		private var category:Vector.<Vector.<Award>> = new Vector.<Vector.<Award>>();
		private var scrollPanes:Vector.<ScrollPane> = new Vector.<ScrollPane>();
		private var scrollPaneSources:Vector.<Sprite> = new Vector.<Sprite>();

		private var categoryButtons:ButtonTabGroup = new ButtonTabGroup();
		private var buttonShowComplete:SimpleButton = null;
		private var buttonHideComplete:SimpleButton = null;

		private var buttonShowLock:SimpleButton = null;
		private var buttonHideLock:SimpleButton = null;

		private var showCompleted:Boolean = true;
		private var showLocked:Boolean = true;

		private var totalBar:Bar = null;
		private var totalField:GameField = null;

		private var needUpdate:Boolean = true;

		public function AwardListView()
		{
			init();

			AwardManager.addEventListener(GameEvent.AWARD_UPDATE, update);
		}

		public function onShow():void
		{
			if (this.needUpdate)
				update();
			this.needUpdate = false;
		}

		private function init():void
		{
			this.totalBar = new Bar([
				{'image': new AwardTotalBack(), 'X': 0, 'Y': 0},
				{'image': new AwardTotalActive(), 'X': 0, 'Y': 0},
				{'image': new AwardTotalActive(), 'X': 0, 'Y': 0}
			], 580);
			this.totalBar.x = 160;
			this.totalBar.y = 50;
			addChild(this.totalBar);

			this.totalField = new GameField("0/0", 450, 50, new TextFormat(null, 16, 0xFFFFFF, true));
			addChild(this.totalField);

			for (var i:int = 0; i < AwardManager.MAX_TYPE; i++)
			{
				this.category.push(new Vector.<Award>());
				this.scrollPanes.push(new ScrollPane());
				this.scrollPanes[i].setStyle("thumbUpSkin", ScrollPaneButton);
				this.scrollPanes[i].setStyle("thumbDownSkin", ScrollPaneButton);
				this.scrollPanes[i].setStyle("thumbOverSkin", ScrollPaneButton);
				this.scrollPanes[i].setStyle("trackUpSkin", ScrollPaneUp);
				this.scrollPanes[i].setStyle("trackDownSkin", ScrollPaneUp);
				this.scrollPanes[i].setStyle("trackOverSkin", ScrollPaneUp);
				this.scrollPanes[i].setStyle("downArrowDownSkin", ScrollPaneButtonDown);
				this.scrollPanes[i].setStyle("downArrowOverSkin", ScrollPaneButtonDown);
				this.scrollPanes[i].setStyle("downArrowUpSkin", ScrollPaneButtonDown);
				this.scrollPanes[i].setStyle("upArrowDownSkin", ScrollPaneButtonUp);
				this.scrollPanes[i].setStyle("upArrowOverSkin", ScrollPaneButtonUp);
				this.scrollPanes[i].setStyle("upArrowUpSkin", ScrollPaneButtonUp);
				this.scrollPanes[i].setStyle("thumbIcon", ScrollPaneThumb);
				this.scrollPanes[i].setSize(820, 440);
				this.scrollPanes[i].verticalLineScrollSize = HEIGHT;
				this.scrollPanes[i].verticalPageScrollSize = HEIGHT;
				this.scrollPanes[i].x = 40;
				this.scrollPanes[i].y = 160;
				this.scrollPaneSources.push(new Sprite());
				this.scrollPanes[i].source = this.scrollPaneSources[i];
				addChild(this.scrollPanes[i]);
			}

			for each (var awardData:Object in Award.DATA)
			{
				var award:Award = new Award(awardData['id']);
				if (!award.avaliable)
					continue;
				this.category[award.category].push(award);
			}

			for each (var awards:Vector.<Award> in this.category)
				for (i = 0; i < awards.length; i++)
				{
					awards[i].view.x = (i % 2) * WIDTH;
					awards[i].view.y = int(i / 2) * HEIGHT;
					this.scrollPaneSources[awards[i].category].addChild(awards[i].view);
				}

			var names:Array = [gls("Базовые"), gls("Собиратель"), gls("Шаман"), gls("Эпические")];
			var texts:Array = [gls("Деяния, которые отличают настоящую белку"), gls("Награды за героическое упорство, проявленное белкой ради спасения своего народа"), gls("Награды за искусное мастерство Шамана"), gls("Здесь записаны исключительно выдающиеся деяния белок")];
			for (i = 0; i < names.length; i++)
			{
				var buttonTab:ButtonTabAward = new ButtonTabAward(names[i]);
				buttonTab.bar.switchBack(i == 0);
				buttonTab.x = i * 200;
				buttonTab.y = 80;
				new Status(buttonTab, texts[i]);
				this.categoryButtons.insert(buttonTab, this.scrollPanes[i]);
			}
			addChild(this.categoryButtons);

			this.buttonShowComplete = new ButtonShowAwardComplete();
			this.buttonHideComplete = new ButtonHideAwardComplete();
			this.buttonShowComplete.x = this.buttonHideComplete.x = 800;
			this.buttonShowComplete.y = this.buttonHideComplete.y = 85;
			this.buttonHideComplete.visible = false;
			this.buttonShowComplete.addEventListener(MouseEvent.CLICK, switchCompleteView);
			this.buttonHideComplete.addEventListener(MouseEvent.CLICK, switchCompleteView);
			addChild(this.buttonShowComplete);
			addChild(this.buttonHideComplete);
			new Status(this.buttonShowComplete, gls("Скрыть полученные"));
			new Status(this.buttonHideComplete, gls("Показать полученные"));

			this.buttonShowLock = new ButtonShowAwardLock();
			this.buttonHideLock = new ButtonHideAwardLock();
			this.buttonShowLock.x = this.buttonHideLock.x = 850;
			this.buttonShowLock.y = this.buttonHideLock.y = 85;
			this.buttonHideLock.visible = false;
			this.buttonShowLock.addEventListener(MouseEvent.CLICK, switchLockView);
			this.buttonHideLock.addEventListener(MouseEvent.CLICK, switchLockView);
			addChild(this.buttonShowLock);
			addChild(this.buttonHideLock);
			new Status(this.buttonShowLock, gls("Скрыть недоступные"));
			new Status(this.buttonHideLock, gls("Показать недоступные"));

			for each (var scrollPane:ScrollPane in this.scrollPanes)
				scrollPane.update();
		}

		private function update(e:GameEvent = null):void
		{
			if (!(Screens.active is ScreenAward))
			{
				this.needUpdate = true;
				return;
			}

			var allCurrent:int = 0;
			var allTotal:int = 0;
			var index:int = 0;
			var scores:Array = [1, 2, 2, 7];

			for each (var awards:Vector.<Award> in this.category)
			{
				var current:int = 0;
				for each (var award:Award in awards)
				{
					award.stat = AwardManager.data;
					current += award.complete ? 1 : 0;
					award.view.visible = !((!this.showCompleted && award.complete) || (!this.showLocked && award.isLock));
				}

				updateView(awards);

				(this.categoryButtons.tabs[index] as ButtonTabAward).setValues(current, awards.length);
				allCurrent += current * scores[award.category];
				allTotal += awards.length * scores[award.category];
				index++;
			}

			this.totalBar.setValues(allCurrent, allTotal);
			this.totalField.text = allCurrent + "/" + allTotal;
			this.totalField.x = this.totalBar.x + int(this.totalBar.width - this.totalField.textWidth) * 0.5;

			for each (var scrollPane:ScrollPane in this.scrollPanes)
				scrollPane.update();

			this.visible = true;
		}

		private function switchCompleteView(e:MouseEvent):void
		{
			this.showCompleted = !this.showCompleted;
			this.buttonShowComplete.visible = this.showCompleted;
			this.buttonHideComplete.visible = !this.showCompleted;

			for each (var awards:Vector.<Award> in this.category)
				updateView(awards);

			for each (var scrollPane:ScrollPane in this.scrollPanes)
				scrollPane.update();
		}

		private function switchLockView(e:MouseEvent):void
		{
			this.showLocked = !this.showLocked;
			this.buttonShowLock.visible = this.showLocked;
			this.buttonHideLock.visible = !this.showLocked;

			for each (var awards:Vector.<Award> in this.category)
				updateView(awards);

			for each (var scrollPane:ScrollPane in this.scrollPanes)
				scrollPane.update();
		}

		private function updateView(awards:Vector.<Award>):void
		{
			awards.sort(sortAward);

			var pos:int = 0;
			for each (var award:Award in awards)
			{
				award.view.visible = !((!this.showCompleted && award.complete) || (!this.showLocked && award.isLock));
				award.view.x = award.view.visible ? (pos % 2) * WIDTH : 0;
				award.view.y = award.view.visible ? int(pos / 2) * HEIGHT : 0;
				pos += award.view.visible ? 1 : 0;
			}
		}

		private function sortAward(award1:Award, award2:Award):int
		{
			if (award1.complete != award2.complete)
				return award1.complete ? -1 : 1;
			return award1.id > award2.id ? 1 : -1;
		}
	}
}