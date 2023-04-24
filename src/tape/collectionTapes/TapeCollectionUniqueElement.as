package tape.collectionTapes
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import game.gameData.CollectionManager;
	import game.gameData.CollectionsData;
	import statuses.Status;
	import statuses.StatusCollectionItem;
	import tape.TapeObject;

	import utils.Counter;
	import utils.FiltersUtil;

	public class TapeCollectionUniqueElement extends TapeObject
	{
		private var status:Status = null;

		private var _counter:Counter = null;

		protected var countField:GameField = null;

		protected var icon:DisplayObject = null;
		protected var background:MovieClip = null;

		public var elementId:int;

		public function TapeCollectionUniqueElement(id:int):void
		{
			super();

			this.elementId = id;

			init();

			this.status = new StatusCollectionItem(this, CollectionsData.TYPE_UNIQUE, id);

			updateState();
		}

		public function onExchange():void
		{
			CollectionManager.decItem(CollectionsData.TYPE_UNIQUE, this.elementId);
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

		protected function init():void
		{
			this.background = new CollectionElementBackgroundImage();
			this.background.width = this.background.height = 33;
			addChild(this.background);

			var iconClass:Class = CollectionsData.getUniqueClass(this.elementId);
			this.icon = new iconClass();
			this.icon.scaleX = this.icon.scaleY = 0.4;
			this.icon.x += int((this.background.width - this.icon.width) / 2);
			this.icon.y += int((this.background.height - this.icon.height) / 2);
			addChild(this.icon);

			var format:TextFormat = new TextFormat(null, 12, 0x513B18, true);
			format.align = TextFormatAlign.RIGHT;

			this.countField = new GameField("0", 0, 16, format);
			this.countField.width = 31;
			this.countField.autoSize = TextFieldAutoSize.RIGHT;
			this.countField.mouseEnabled = false;
			this.countField.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 3)];
			addChild(this.countField);
		}

		protected function setCount(count:int):void
		{
			this.countField.text = count.toString();
		}

		protected function updateState(e:Event = null):void
		{
			dispatchEvent(new Event(Event.CHANGE));

			if (this.counter == null || this.counter.count == 0)
			{
				this.background.filters = FiltersUtil.GREY_FILTER;
				this.icon.filters = FiltersUtil.GREY_FILTER;
				setCount(0);
				return;
			}

			this.background.filters = [];
			this.icon.filters = [];
			setCount(this.counter.count);
		}
	}
}