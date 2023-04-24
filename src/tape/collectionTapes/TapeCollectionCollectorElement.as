package tape.collectionTapes
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import game.gameData.CollectionsData;
	import statuses.StatusCollection;
	import statuses.StatusCollectionCollector;
	import tape.TapeObject;
	import views.storage.CollectionAssembleHideEffect;

	import utils.Counter;
	import utils.FiltersUtil;

	public class TapeCollectionCollectorElement extends TapeObject
	{
		static private const BUTTON_WIDTH:int = 185;
		static private const BUTTON_HEIGHT:int = 185;

		static public const EVENT_EXCHANGE:String = "EXCHANGE";

		private var status:StatusCollectionCollector = null;

		private var _collected:Boolean = false;

		private var icon:DisplayObject = null;

		private var exchangeButton:CollectionExchangeButton = null;

		private var _counter:Counter = null;

		private var countField:GameField = null;

		public var elementId:int;

		public function TapeCollectionCollectorElement(id:int):void
		{
			super();

			this.elementId = id;

			this.graphics.beginFill(0xF7F4EC);
			this.graphics.lineStyle(2, 0xF4E3CA);
			this.graphics.drawRoundRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT, 4, 4);

			var caption:GameField = new GameField(CollectionsData.uniqueData[id]['collectionName'], 21, 5, new TextFormat(null, 15, 0x663300, true, null, null, null, null, "center"));
			caption.wordWrap = true;
			caption.width = 141;
			addChild(caption);

			var iconClass:Class = CollectionsData.getUniqueClass(id);
			this.icon = new iconClass();
			this.icon.scaleX = this.icon.scaleY = 2;
			this.icon.x += int((BUTTON_WIDTH - this.icon.width) * 0.5);
			this.icon.y += 30 + int((BUTTON_HEIGHT - this.icon.height - 30) * 0.5);
			(this.icon as MovieClip).mouseEnabled = false;
			addChild(this.icon);

			var countFormat:TextFormat = new TextFormat(null, 16, 0x663300, true);
			countFormat.align = TextFormatAlign.RIGHT;

			this.countField = new GameField("0", 135, 155, countFormat);
			this.countField.width = 40;
			this.countField.autoSize = TextFieldAutoSize.RIGHT;
			this.countField.mouseEnabled = false;
			addChild(this.countField);

			this.exchangeButton = new CollectionExchangeButton();
			this.exchangeButton.scaleX = this.exchangeButton.scaleY = 0.65;
			this.exchangeButton.x = 162;
			this.exchangeButton.y = 3;
			this.exchangeButton.addEventListener(MouseEvent.CLICK, onExchange);
			addChild(this.exchangeButton);

			new StatusCollection(this.exchangeButton, gls("Собрать предмет"));

			this._collected = true;
			this.collected = false;

			var awardString:String = "";
			if ('exp' in CollectionsData.uniqueData[id])
				awardString = CollectionsData.uniqueData[id]['exp'] + "  ^";

			this.status = new StatusCollectionCollector(this, CollectionsData.uniqueData[id]['tittle'], CollectionsData.uniqueData[id]['collectorDescription'], awardString);
		}

		public function get collected():Boolean
		{
			return this._collected;
		}

		public function set collected(value:Boolean):void
		{
			if (this._collected == value)
				return;

			this._collected = value;

			this.exchangeButton.visible = value;
			this.icon.filters = (value || this.counter && this.counter.count > 0) ? [] : FiltersUtil.GREY_FILTER;
		}

		public function get counter():Counter
		{
			return this._counter;
		}

		public function set counter(value:Counter):void
		{
			if (this._counter == value)
				return;

			if (this._counter != null)
				this._counter.removeEventListener(Event.CHANGE, updateState);

			this._counter = value;
			this._counter.addEventListener(Event.CHANGE, updateState);

			updateState();
		}

		public function onAssembleComplete():void
		{
			var effect:CollectionAssembleHideEffect = new CollectionAssembleHideEffect(this.elementId);
			effect.x = this.icon.x;
			effect.y = this.icon.y;
			addChild(effect);
		}

		private function updateState(e:Event = null):void
		{
			this.icon.filters = (this.collected || this.counter && this.counter.count > 0) ? [] : FiltersUtil.GREY_FILTER;

			this.countField.text = (this.counter && this.counter.count > 0) ? this.counter.count.toString() : "";
		}

		private function onExchange(e:MouseEvent):void
		{
			dispatchEvent(new Event(EVENT_EXCHANGE));
		}
	}
}