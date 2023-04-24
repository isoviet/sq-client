package ratings
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextFormat;

	import fl.containers.ScrollPane;

	import buttons.ButtonBase;
	import clans.ClanManager;
	import events.GameEvent;
	import game.gameData.GameConfig;
	import game.gameData.RatingManager;

	import utils.ArrayUtil;
	import utils.FiltersUtil;

	public class RatingView extends Sprite
	{
		static private const TIME_UPDATE:int = 60;

		static protected const FILTER_CAPTION:GlowFilter = new GlowFilter(0x19545E, 1.0, 4, 4, 16);
		static protected const FILTER_NAME:GlowFilter = new GlowFilter(0x663300, 1.0, 4, 4, 8);
		static protected const FILTER_FINISH:GlowFilter = new GlowFilter(0xFFFFFF, 1.0, 4, 4, 8);
		static protected const FILTER_NAME_SHADOW:DropShadowFilter = new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25);

		static public const LOAD_MASK:Array = [PlayerInfoParser.NAME | PlayerInfoParser.RATING_INFO | PlayerInfoParser.RATING_HISTORY | PlayerInfoParser.EXPERIENCE | PlayerInfoParser.CLAN, ClanInfoParser.INFO];

		protected var type:int = 0;

		protected var elements:Vector.<RatingElementView> = new <RatingElementView>[];
		protected var leagueElements:Vector.<DisplayObject> = new <DisplayObject>[];
		protected var leagueFields:Vector.<GameField> = new <GameField>[];
		protected var leagueNames:Vector.<GameField> = new <GameField>[];

		protected var fieldInfo:GameField = null;
		protected var scrollPane:ScrollPane = null;
		protected var scrollSource:Sprite = null;

		protected var buttonShowMe:ButtonBase = null;

		protected var imageBlock:DisplayObjectContainer = null;

		private var time:int = 0;
		private var loaded:Boolean = false;

		public function RatingView(type:int):void
		{
			this.type = type;

			init();

			this.time = this.timeUpdate;

			listen();

			EnterFrameManager.addPerSecondTimer(onTimer);
		}

		protected function init():void
		{
			createList();
			createLeague();

			update();

			requestElements(this.ids);
		}

		protected function createList():void
		{
			drawBack();

			this.scrollPane = new ScrollPane();
			this.scrollPane.setStyle("thumbUpSkin", ScrollPaneButton);
			this.scrollPane.setStyle("thumbDownSkin", ScrollPaneButton);
			this.scrollPane.setStyle("thumbOverSkin", ScrollPaneButton);
			this.scrollPane.setStyle("trackUpSkin", ScrollPaneUp);
			this.scrollPane.setStyle("trackDownSkin", ScrollPaneUp);
			this.scrollPane.setStyle("trackOverSkin", ScrollPaneUp);
			this.scrollPane.setStyle("downArrowDownSkin", ScrollPaneButtonDown);
			this.scrollPane.setStyle("downArrowOverSkin", ScrollPaneButtonDown);
			this.scrollPane.setStyle("downArrowUpSkin", ScrollPaneButtonDown);
			this.scrollPane.setStyle("upArrowDownSkin", ScrollPaneButtonUp);
			this.scrollPane.setStyle("upArrowOverSkin", ScrollPaneButtonUp);
			this.scrollPane.setStyle("upArrowUpSkin", ScrollPaneButtonUp);
			this.scrollPane.setStyle("thumbIcon", ScrollPaneThumb);
			addChild(this.scrollPane);

			setScrollPane();

			this.scrollSource = new Sprite();
			this.scrollPane.source = this.scrollSource;

			this.buttonShowMe = new ButtonBase(gls("Показать себя"));
			this.buttonShowMe.x = 450 - int(this.buttonShowMe.width * 0.5);
			this.buttonShowMe.y = 500;
			this.buttonShowMe.addEventListener(MouseEvent.CLICK, onShowMe);
			addChild(this.buttonShowMe);

			this.imageBlock = new this.imageClass();
			this.imageBlock.scaleX = this.imageBlock.scaleY = 1.3;
			this.imageBlock.x = 500;
			this.imageBlock.y = 350;
			addChild(this.imageBlock);

			this.fieldInfo = new GameField("", -10, -115, new TextFormat(null, 14, 0x875A4A, true, null, null, null, null, "center"));
			this.fieldInfo.width = 216;
			this.fieldInfo.multiline = true;
			this.fieldInfo.wordWrap = true;
			this.fieldInfo.text = this.imageText;
			this.imageBlock.addChild(this.fieldInfo);
		}

		protected function get imageClass():Class
		{
			return RatingImageNoLeague;
		}

		protected function get imageText():String
		{
			return gls("Ты пока еще не попал ни\nв одну из лиг.\n\nПродолжай проходить\nуровни! Чем лучше ты их\nпроходишь, тем быстрее\nты начнешь состязаться\nс остальными за звание\nлучшей белки.");
		}

		protected function drawBack():void
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(900, 175, Math.PI / 2, 0, 0);

			this.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			this.graphics.drawRect(0, 0, 900, 175);

			matrix.createGradientBox(900, 360, Math.PI / 2, 0, 175);
			this.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			this.graphics.drawRect(0, 175, 900, 360);
		}

		protected function setScrollPane():void
		{
			this.scrollPane.x = 25;
			this.scrollPane.y = 190;
			this.scrollPane.setSize(860, 300);

			this.scrollPane.graphics.beginFill(0x000000, 0.05);
			this.scrollPane.graphics.drawRect(-2, -2, 844, 304);
		}

		protected function createLeague():void
		{
			var view:LeagueTapeView = new LeagueTapeView();
			view.x = int((Config.GAME_WIDTH - view.width) * 0.5);
			view.y = 5;
			addChild(view);

			var field:GameField = new GameField(gls("Уровни лиг"), 0, 5, new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF));
			field.x = int(0.5 * (Config.GAME_WIDTH - field.textWidth));
			field.filters = [FILTER_CAPTION];
			addChild(field);

			this.leagueElements.push(view.bronzeView, view.silverView, view.goldView, view.masterView, view.diamondView, view.championView);

			for (var i:int = 0; i < this.leagueElements.length; i++)
			{
				field = new GameField(GameConfig.getLeagueName(i + 1, this.type), 0, 0, new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF));
				field.x = this.leagueElements[i].x - int(field.textWidth * 0.5) - 3;
				field.y = this.leagueElements[i].y + int(this.leagueElements[i].height * 0.5);
				field.filters = [FILTER_NAME, FILTER_NAME_SHADOW];
				view.addChild(field);

				this.leagueNames.push(field);

				field = new GameField(GameConfig.getLeagueValue(i + 1, this.type).toString(), 0, 20, new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFF2BF));
				field.x = this.leagueElements[i].x - int(field.textWidth * 0.5) - 3;
				field.y = this.leagueElements[i].y + int(this.leagueElements[i].height  * 0.5) + 18;
				field.filters = [FILTER_NAME, FILTER_NAME_SHADOW];
				view.addChild(field);

				this.leagueFields.push(field);
			}
		}

		protected function listen():void
		{
			RatingManager.addEventListener(GameEvent.DIVISION_CHANGED, onDivisionChange);
			RatingManager.addEventListener(GameEvent.LEAGUE_CHANGED, onLeagueChange);
		}

		protected function onShowMe(e:MouseEvent = null):void
		{
			for (var i:int = 0; i < this.elements.length; i++)
			{
				if (!this.elements[i].isSelf)
					continue;
				this.scrollPane.verticalScrollPosition = this.elements[i].y - 100;
				break;
			}
		}

		protected function onLeagueChange(e:GameEvent):void
		{
			if (e.data['type'] != this.type)
				return;
			update();
		}

		protected function onDivisionChange(e:GameEvent):void
		{
			if (e == null || e.data == null || e.data['type'] != this.type)
				return;

			if (!('delta' in e.data))
			{
				update();
				requestElements(this.ids);
			}
			else if ('reason' in e.data && e.data['reason'] == RatingManager.JOIN)
				addElement(e.data['delta']);
			else
				removeElement(e.data['delta']);
		}

		protected function update():void
		{
			updateLeague();

			while (this.elements.length > 0)
			{
				var displayObject:DisplayObject = this.elements.pop();
				displayObject.removeEventListener(RatingElementView.VALUE_CHANGE, onElementChange);
				if(this.scrollSource.contains(displayObject))
					this.scrollSource.removeChild(displayObject);
			}

			var array:Vector.<int> = this.ids;
			for (var i:int = 0; i < array.length; i++)
				this.elements.push(getElement(array[i]));

			updateView();
		}

		protected function updateLeague():void
		{
			var league:int = RatingManager.getSelfLeague(this.type);
			for (var i:int = 0; i < this.leagueElements.length; i++)
			{
				this.leagueElements[i].filters = league > i ? [] : FiltersUtil.GREY_FILTER;

				this.leagueNames[i].filters = league > i ? [FILTER_FINISH, FILTER_NAME_SHADOW] : [FILTER_NAME, FILTER_NAME_SHADOW];
				this.leagueNames[i].textColor = league > i ? 0x21BF15 : 0xFFFFFF;

				this.leagueFields[i].visible = league <= i;
			}
		}

		protected function addElement(ids:Array):void
		{
			for (var i:int = 0; i < ids.length; i++)
				this.elements.push(getElement(ids[i]));

			requestElements(ArrayUtil.arrayIntToVector(ids));

			updateView();
		}

		protected function removeElement(ids:Array):void
		{
			for (var i:int = this.elements.length - 1; i >= 0; i--)
			{
				if (ids.indexOf(this.elements[i].id) == -1)
					continue;
				(this.scrollSource.removeChild(this.elements.splice(i, 1)[0])).removeEventListener(RatingElementView.VALUE_CHANGE, onElementChange);
			}
			updateView();
		}

		protected function getElement(id:int):RatingElementView
		{
			var answer:RatingElementView = new RatingElementView(this.type, id);
			answer.addEventListener(RatingElementView.VALUE_CHANGE, onElementChange);
			return answer;
		}

		protected function updateView():void
		{
			this.imageBlock.visible = this.elements.length == 0;
			this.buttonShowMe.visible = this.elements.length != 0;
			this.scrollPane.visible = this.elements.length != 0;

			if (this.elements.length == 0)
				return;
			var places:Object = {};
			for (var i:int = 0; i < this.elements.length; i++)
				places[this.elements[i].id] = i;
			this.elements.sort(sortByValue);

			for (i = 0; i < this.elements.length; i++)
			{
				this.elements[i].place = i;
				this.elements[i].delta = places[this.elements[i].id] - i;
				this.scrollSource.addChild(this.elements[i]);
			}
			this.scrollPane.update();
		}

		protected function sortByValue(a:RatingElementView, b:RatingElementView):int
		{
			if (a.value == b.value)
				return a.id < b.id ? 1 : -1;
			return a.value < b.value ? 1 : -1;
		}

		protected function requestElements(ids:Vector.<int>):void
		{
			switch (this.type)
			{
				case RatingManager.PLAYER_TYPE:
					Game.request(ArrayUtil.parseIntVector(ids), LOAD_MASK[this.type], true);
					break;
				case RatingManager.CLAN_TYPE:
					ClanManager.request(ArrayUtil.parseIntVector(ids), true, LOAD_MASK[this.type]);
					break;
			}
		}

		protected function onElementChange(e:Event):void
		{
			for (var i:int = 0; i < this.elements.length; i++)
			{
				if (this.elements[i].loaded)
					continue;
				return;
			}
			if (!this.loaded)
				onShowMe();
			this.loaded = true;

			updateView();
		}

		protected function get ids():Vector.<int>
		{
			return RatingManager.getIds(this.type);
		}

		protected function get timeUpdate():int
		{
			return TIME_UPDATE;
		}

		protected function onTimer():void
		{
			if (this.time <= 0)
				return;
			this.time--;
			if (time > 0)
				return;
			this.time = this.timeUpdate;

			var ids:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < this.elements.length; i++)
			{
				if (!this.elements[i].expired)
					continue;
				ids.push(this.elements[i].id);
			}
			if (ids.length > 0)
				requestElements(ids);
		}
	}
}