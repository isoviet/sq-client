package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.NotificationManager;
	import game.gameData.PowerManager;
	import screens.Screens;
	import views.DailyQuestView;
	import views.GameBonusImageView;
	import views.GameBonusValueView;

	import protocol.Connection;
	import protocol.PacketServer;
	import protocol.packages.server.PacketBalance;

	public class DialogDailyQuests extends Dialog
	{
		static private const FORMAT_TITLE:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF);
		static private const FORMAT_AWARD_MOVIE:TextFormat = new TextFormat(null, 16, 0x673401, true);
		static private const FILTER_AWARD:GlowFilter = new GlowFilter(0xE1C8A3, 1, 6, 6, 8);

		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #6D4D37;
			}
			]]>).toString();

		static private var _instance:DialogDailyQuests = null;

		private var currentAcorns:uint;

		private var currentType:int = -1;
		private var currentDifficulty:int = -1;

		private var currentImage:Sprite = null;
		private var mainImage:Sprite = null;

		private var dailyQuests:Array = [];
		private var fieldTitle:GameField = null;
		private var fieldText:GameField = null;

		private var spriteQuests:Sprite = null;

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogDailyQuests();
			_instance.show();
		}

		public function DialogDailyQuests():void
		{
			super(gls("Задания"), true, true, null, false);

			init();

			DailyQuestManager.addEventListener(GameEvent.DAILY_QUEST_CHANGED, update);
			DailyQuestManager.addEventListener(GameEvent.DAILY_QUEST_PROGRESS, updateValues);
			DailyQuestManager.addEventListener(GameEvent.DAILY_QUEST_COMPLETE, onGameComplete);
		}

		override public function show():void
		{
			super.show();

			this.currentAcorns = Game.self.nuts;

			Experience.addEventListener(GameEvent.EXPERIENCE_CHANGED, onExperience);
			PowerManager.addEventListener(GameEvent.MANA_CHANGED, onMana);
			Connection.listen(onPacket, PacketBalance.PACKET_ID);
			EnterFrameManager.addPerSecondTimer(updateTime);

			NotificationDispatcher.hide(NotificationManager.DAILY_QUEST);
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			Experience.removeEventListener(GameEvent.EXPERIENCE_CHANGED, onExperience);
			PowerManager.removeEventListener(GameEvent.MANA_CHANGED, onMana);
			Connection.forget(onPacket, PacketBalance.PACKET_ID);
			EnterFrameManager.removePerSecondTimer(updateTime);
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, 29, 0xFFCC00, null, null, null, null, null, "center");
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.mainImage = new EducationQuestGeneraImage();
			this.currentImage = Config.isRus ? new EducationQuestImageShowMoreRu() : new EducationQuestImageShowMoreEn();
			this.currentImage.x = this.mainImage.x + (this.mainImage.width - this.currentImage.width);
			addChild(this.currentImage);
			addChild(this.mainImage);

			this.fieldTitle = new GameField("", 38, 235, FORMAT_TITLE);
			this.fieldTitle.filters = [FILTER_AWARD];
			this.mainImage.addChild(this.fieldTitle);

			var text:String = gls("Задания - это дополнительные задачи во время игры с другими белочками. Выполни необходимые требования и возвращайся за наградой.\nНажми кнопку <b>«Подробно»</b>, чтобы узнать побольше о задании.");
			this.fieldText = new GameField("<body>" + text + "</body>", 28, 255, style, 560);
			this.mainImage.addChild(this.fieldText);

			this.spriteQuests = new Sprite();
			this.spriteQuests.x = 10;
			this.spriteQuests.y = 320;
			this.spriteQuests.graphics.beginFill(0xFFFFFF, 0.6);
			this.spriteQuests.graphics.drawRect(0, 0, 590, 215);
			addChild(this.spriteQuests);

			update();

			place();

			this.width = 640;
			this.height = 590;
		}

		private function update(e:GameEvent = null):void
		{
			if (e && 'onComplete' in e && e.data['onComplete'])
			{
				if (this.currentImage)
					removeChild(this.currentImage);
				this.currentImage = Config.isRus ? new EducationQuestImageShowMoreRu() : new EducationQuestImageShowMoreEn();
				this.currentImage.x = this.mainImage.x + (this.mainImage.width - this.currentImage.width);
				addChild(this.currentImage);

				(this.mainImage as EducationQuestGeneraImage).imageShaman.visible = true;
				addChild(this.mainImage);

				this.fieldTitle.text = "";
				this.fieldText.text = "<body>" + gls("Отлично, ещё одно задание завершено! Посмотри, что ещё шаман подготовил для тебя - выполняй больше, получай больше наград.\nНажми кнопку <b>«Подробно»</b>, чтобы узнать побольше о задании.") + "</body>";
			}

			while (this.spriteQuests.numChildren > 0)
				this.spriteQuests.removeChildAt(0);
			this.dailyQuests = [];

			var needRefresh:Boolean = true;
			for (var i:int = 0; i < DailyQuestManager.quests.length; i++)
			{
				var view:DailyQuestView = new DailyQuestView(DailyQuestManager.quests[i], onMore);
				view.x = 5;
				view.y = 10 + i * 105;
				this.spriteQuests.addChild(view);

				this.dailyQuests.push(view);

				needRefresh = needRefresh && !(DailyQuestManager.quests[i].type == this.currentType && DailyQuestManager.quests[i].difficulty == this.currentDifficulty);
			}

			if (needRefresh)
			{
				if (this.currentImage)
					removeChild(this.currentImage);
				this.currentImage = Config.isRus ? new EducationQuestImageShowMoreRu() : new EducationQuestImageShowMoreEn();
				this.currentImage.x = this.mainImage.x + (this.mainImage.width - this.currentImage.width);
				addChild(this.currentImage);

				(this.mainImage as EducationQuestGeneraImage).imageShaman.visible = true;
				addChild(this.mainImage);

				this.fieldTitle.text = "";
				this.fieldText.text = "<body>" + gls("Задания - это дополнительные задачи во время игры с другими белочками. Выполни необходимые требования и возвращайся за наградой.\nНажми кнопку <b>«Подробно»</b>, чтобы узнать побольше о задании.") + "</body>";
			}
		}

		private function updateTime():void
		{
			for (var i:int = 0; i < this.dailyQuests.length; i++)
			{
				if (DailyQuestManager.quests.length <= i)
					continue;
				(this.dailyQuests[i] as DailyQuestView).updateTime();
			}
		}

		private function onGameComplete(e:GameEvent):void
		{
			Screens.addCallback(show);
		}

		private function updateValues(e:GameEvent):void
		{
			for (var i:int = 0; i < this.dailyQuests.length; i++)
			{
				if (DailyQuestManager.quests.length <= i)
					continue;
				(this.dailyQuests[i] as DailyQuestView).update();
			}
		}

		private function onMore(quest:DailyQuest):void
		{
			this.currentType = quest.type;
			this.currentDifficulty = quest.difficulty;

			if (this.currentImage)
				removeChild(this.currentImage);
			this.currentImage = quest.image;
			this.currentImage.x = this.mainImage.x + int((this.mainImage.width - this.currentImage.width) * 0.5);
			addChild(this.currentImage);

			(this.mainImage as EducationQuestGeneraImage).imageShaman.visible = false;
			addChild(this.mainImage);

			this.fieldTitle.text = quest.name;
			this.fieldText.text = "<body>" + quest.text + "</body>";
		}

		private function onPacket(packet: PacketBalance):void
		{
			if (packet.reason == PacketServer.REASON_QUEST)
				showAward(packet.nuts - this.currentAcorns, ImageIconNut);

			this.currentAcorns = packet.nuts;
		}

		private function onExperience(e:GameEvent):void
		{
			if (!e.data || e.data['reason'] != PacketServer.REASON_QUEST)
				return;
			showAward(e.data['delta'], ImageIconExp, 100);
		}

		private function onMana(e:GameEvent):void
		{
			if (!e.data || e.data['reason'] != PacketServer.REASON_QUEST)
				return;
			showAward(e.data['delta'], ImageIconMana, 50);
		}

		private function showAward(value:int, imageClass:Class, offsetX:int = 0):void
		{
			if (value == 0)
				return;
			var image:DisplayObject = new imageClass();
			image.scaleX = image.scaleY = 1.2;

			var awardsValueView:GameBonusValueView = new GameBonusValueView(value, this.x + 290 + offsetX, this.y + 420, FORMAT_AWARD_MOVIE);
			Game.gameSprite.addChild(awardsValueView);

			var awardImageView:GameBonusImageView = new GameBonusImageView(image, awardsValueView.x + int(awardsValueView.width) + 3, awardsValueView.y, 165, 7);
			Game.gameSprite.addChild(awardImageView);
		}
	}
}