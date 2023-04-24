package dialogs.education
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import events.GameEvent;
	import game.gameData.EducationQuestManager;
	import statuses.Status;

	import com.greensock.TweenMax;

	import utils.FieldUtils;
	import utils.FiltersUtil;

	public class DialogEducationQuest extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #6D4D37;
			}
			]]>).toString();

		static public const REPLACES:Array = [
			{'replaceString': "#Ac", 'imageClass': ImageIconNut, 'scaleX': 1, 'scaleY': 1, 'shiftX': 2, 'shiftY': 2},
			{'replaceString': "#Ex", 'imageClass': ImageIconExp, 'scaleX': 1, 'scaleY': 1, 'shiftX': 2, 'shiftY': 2},
			{'replaceString': "#Mn", 'imageClass': ImageIconMana, 'scaleX': 1, 'scaleY': 1, 'shiftX': 2, 'shiftY': 2},
			{'replaceString': "#Co", 'imageClass': ImageIconCoins, 'scaleX': 1, 'scaleY': 1, 'shiftX': 2, 'shiftY': 2}
		];

		static private const FORMAT:TextFormat = new TextFormat(null, 13, 0x8E7A67, true);
		static private const FORMAT_TITLE:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF);
		static private const FORMAT_TEXT:TextFormat = new TextFormat(null, 12, 0x8E7A67);
		static private const FORMAT_AWARD:TextFormat = new TextFormat(null, 16, 0x6E5A47, true);
		static private const FORMAT_AWARD_CAPTION:TextFormat = new TextFormat(null, 13, 0xFFFFFF, true);

		static private const FILTER_TITLE:GlowFilter = new GlowFilter(0xB39780, 1, 6, 6, 8);
		static private const FILTER_BLOCK:GlowFilter = new GlowFilter(0x000000, 1, 4, 4, 1);

		static private var _instance:DialogEducationQuest = null;

		static public var showed:Boolean = false;

		private var currentImage:Sprite = null;
		private var mainImage:Sprite = null;

		private var educationQuests:Array = [];
		private var fieldTitle:GameField = null;
		private var fieldText:GameField = null;

		private var spriteQuests:Sprite = null;

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogEducationQuest();
			_instance.show();

			showed = true;
			EducationQuestManager.updateText();
		}

		public function DialogEducationQuest():void
		{
			super(gls("Задания"), true, true, null, false);

			init();

			EducationQuestManager.addEventListener(GameEvent.EDUCATION_QUEST_PROGRESS, updateValues);
			EducationQuestManager.addEventListener(GameEvent.EDUCATION_QUEST_CHANGED, update);
			Experience.addEventListener(GameEvent.LEVEL_CHANGED, onLevel);
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
			addChild(this.mainImage);

			this.fieldTitle = new GameField("", 38, 235, FORMAT_TITLE);
			this.fieldTitle.filters = [FILTER_TITLE];
			this.mainImage.addChild(this.fieldTitle);

			var text:String = gls("Ты прекрасно справляешься, но нет времени отдыхать - пора двигаться дальше.\nНажми кнопку <b>«Подробно»</b>, чтобы узнать побольше о твоём следующем задании.");
			if (EducationQuestManager.firstGame)
				text = gls("Здесь ты сможешь ознакомиться со своими текущими заданиями. То, что нужно сделать в первую очередь, чтобы освоиться в мире белок. Итак, мой друг, нажми кнопку <b>«Подробно»</b>, чтобы узнать побольше о твоём первом задании.");
			this.fieldText = new GameField("<body>" + text + "</body>", 28, 255, style, 560);
			this.mainImage.addChild(this.fieldText);

			this.currentImage = Config.isRus ? new EducationQuestImageShowMoreRu() : new EducationQuestImageShowMoreEn();
			this.currentImage.x = this.mainImage.x + (this.mainImage.width - this.currentImage.width);
			addChild(this.currentImage);
			addChild(this.mainImage);

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
			var quests:Array = EducationQuestManager.activeQuests;

			if (e && e.data['onComplete'])
			{
				if (this.currentImage)
					removeChild(this.currentImage);
				this.currentImage = Config.isRus ? new EducationQuestImageShowMoreRu() : new EducationQuestImageShowMoreEn();
				this.currentImage.x = this.mainImage.x + (this.mainImage.width - this.currentImage.width);
				addChild(this.currentImage);
				addChild(this.mainImage);

				this.fieldTitle.text = "";
				this.fieldText.text = "<body>" + gls("Ты делаешь успехи в этом нелёгком деле, мой друг! Но расслабляться не стоит, тебе ещё многое предстоит узнать! Посмотри, какие ещё поручения я для тебя подготовил. Нажми кнопку <b>«Подробно»</b>, чтобы узнать больше о задании.") + "</body>";
			}

			while (this.spriteQuests.numChildren > 0)
				this.spriteQuests.removeChildAt(0);
			this.educationQuests = [];

			var haveActive:Boolean = false;
			for (var i:int = 0; i < quests.length; i++)
			{
				var quest:Object = EducationQuestManager.getQuest(quests[i]);

				var view:Sprite = new Sprite();
				view.x = 5;
				view.y = 10 + i * 69;
				view.addChild(new EducationQuestBack);

				var icon:DisplayObject = new quest['icon'];
				icon.x = 5;
				icon.y = 12;
				view.addChild(icon);

				view.addChild(new GameField(quest['name'], 40, 10, FORMAT));
				view.addChild(new GameField(quest['short'], 40, 25, FORMAT_TEXT, 250));
				view.addChild(getAwardSprite(quest['award']));

				var field:GameField = new GameField(gls("Награда"), 0, 3, FORMAT_AWARD_CAPTION);
				field.x = 295 + int((168 - field.textWidth) * 0.5);
				field.filters = [FILTER_TITLE];
				view.addChild(field);

				var buttonMore:ButtonBase = new ButtonBase(gls("Подробно"), 95);
				buttonMore.x = 475;
				buttonMore.y = 15;
				buttonMore.name = quest['id'];
				buttonMore.addEventListener(MouseEvent.CLICK, onMore);
				buttonMore.visible = !EducationQuestManager.isDone(quest['id']);
				buttonMore.setBlue();
				view.addChild(buttonMore);

				var buttonComplete:ButtonBase = new ButtonBase(gls("Завершить"), 95);
				buttonComplete.x = 475;
				buttonComplete.y = 15;
				buttonComplete.name = quest['id'];
				buttonComplete.addEventListener(MouseEvent.CLICK, onComplete);
				buttonComplete.visible = EducationQuestManager.isDone(quest['id']);
				view.addChild(buttonComplete);

				haveActive = haveActive || EducationQuestManager.isAllow(quest['id']);

				var block:Sprite = new EducationQuestBlockView();
				block.visible = !EducationQuestManager.isAllow(quest['id']);
				block.addChild(new GameField(gls("Задание доступно с {0} уровня", quest['level']), 175, 18, FORMAT_TITLE)).filters = [FILTER_BLOCK];
				view.addChild(block);

				view.filters = !EducationQuestManager.isAllow(quest['id']) ? FiltersUtil.GREY_FILTER : [];
				this.spriteQuests.addChild(view);

				this.educationQuests.push({'id': quests[i], 'more': buttonMore, 'complete': buttonComplete, 'block': block, 'view': view});
			}

			if (!haveActive)
			{
				this.fieldText.text = "<body>" + gls("Изумительно! Ещё есть много всего, о чём я хочу тебе ещё рассказать. Но сперва тебе надо набраться опыта на Солнечной Долине. Станешь сильнее - возвращайся. Мы продолжим исследование невероятного мира Белок!") + "</body>";
				if (this.currentImage)
					removeChild(this.currentImage);
				this.currentImage = new EducationQuestImageNoActive();
				this.currentImage.x = this.mainImage.x + (this.mainImage.width - this.currentImage.width);
				addChild(this.currentImage);
				addChild(this.mainImage);
			}

			if (this.educationQuests.length == 0)
				hide();
		}

		private function updateValues(e:GameEvent = null):void
		{
			for (var i:int = 0; i < this.educationQuests.length; i++)
			{
				this.educationQuests[i]['more'].visible = !EducationQuestManager.isDone(this.educationQuests[i]['id']);
				this.educationQuests[i]['complete'].visible = EducationQuestManager.isDone(this.educationQuests[i]['id']);
			}
		}

		private function onLevel(e:GameEvent = null):void
		{
			var haveNew:Boolean = false;
			for (var i:int = 0; i < this.educationQuests.length; i++)
			{
				haveNew = haveNew || (this.educationQuests[i]['block'].visible != !EducationQuestManager.isAllow(this.educationQuests[i]['id']));
				this.educationQuests[i]['block'].visible = !EducationQuestManager.isAllow(this.educationQuests[i]['id']);
				this.educationQuests[i]['view'].filters = !EducationQuestManager.isAllow(this.educationQuests[i]['id']) ? FiltersUtil.GREY_FILTER : [];
			}

			if (haveNew)
			{
				if (!this.visible)
				{
					showed = false;
					EducationQuestManager.updateText();
				}

				if (this.currentImage)
					removeChild(this.currentImage);
				this.currentImage = Config.isRus ? new EducationQuestImageShowMoreRu() : new EducationQuestImageShowMoreEn();
				this.currentImage.x = this.mainImage.x + (this.mainImage.width - this.currentImage.width);
				addChild(this.currentImage);
				addChild(this.mainImage);
				this.fieldTitle.text = "";
				this.fieldText.text = "<body>" + gls("Ты делаешь успехи в этом нелёгком деле, мой друг! Но расслабляться не стоит, тебе ещё многое предстоит узнать! Посмотри, какие ещё поручения я для тебя подготовил. Нажми кнопку <b>«Подробно»</b>, чтобы узнать больше о задании.") + "</body>";
			}
		}

		private function getAwardSprite(value:String):DisplayObject
		{
			var sprite:Sprite = new Sprite();
			var field:GameField = new GameField(value, 0, 0, FORMAT_AWARD);
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
				if (object is ImageIconCoins)
					new Status(object, gls("Монеты"));
			}

			sprite.x = 295 + int((168 - sprite.width) * 0.5);
			sprite.y = 22;
			return sprite;
		}

		private function onMore(e:MouseEvent):void
		{
			var id:int = int(e.currentTarget.name);
			var quest:Object = EducationQuestManager.getQuest(id);

			if (this.currentImage)
				removeChild(this.currentImage);
			this.currentImage = new quest['image'];
			this.currentImage.x = this.mainImage.x + (this.mainImage.width - this.currentImage.width);
			addChild(this.currentImage);
			addChild(this.mainImage);

			this.fieldTitle.text = quest['name'];
			this.fieldText.text = "<body>" + quest['text'] + "</body>";
		}

		private function onComplete(e:MouseEvent):void
		{
			var id:int = int(e.currentTarget.name);
			var quest:Object = EducationQuestManager.getQuest(id);

			var delay:Number = 0;
			for (var  i:int = 0; i < REPLACES.length; i++)
			{
				if ((quest['award'] as String).indexOf(REPLACES[i]['replaceString'])  == -1)
					continue;
				showAward(REPLACES[i]['imageClass'], e.currentTarget.localToGlobal(new Point(45, -5)), delay);
				delay += 0.1;
			}

			EducationQuestManager.complete(id);
		}

		private function showAward(imageClass:Class, point:Point, delay:Number):void
		{
			var object:DisplayObject = new imageClass as DisplayObject;
			object.x = point.x;
			object.y = point.y;
			Game.gameSprite.addChild(object);

			TweenMax.to(object, 1.0, {'bezier': [{'x': 600, 'y': 300}, {'x': 80, 'y': 80}], 'delay': delay, 'onComplete': function():void
			{
				Game.gameSprite.removeChild(object);
			}});
		}
	}
}