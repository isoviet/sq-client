package tape.collectionTapes
{
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import game.gameData.CollectionManager;
	import game.gameData.CollectionsData;

	import utils.FiltersUtil;

	public class TapeCollectionUniqueExchangeElement extends TapeCollectionUniqueElement
	{
		static public const ELEMENT_WIDTH:int = 45;
		static public const ELEMENT_HEIGHT:int = 45;

		private var exchangeCount:int;

		public function TapeCollectionUniqueExchangeElement(id:int, exchangeCount:int = 1):void
		{
			super(id);

			this.exchangeCount = exchangeCount;

			setCount(this.exchangeCount);
		}

		override public function onExchange():void
		{
			CollectionManager.decItem(CollectionsData.TYPE_UNIQUE, this.elementId, this.exchangeCount);
		}

		public function get isCollected():Boolean
		{
			if (this.counter == null)
				return false;

			return (this.counter.count >= this.exchangeCount);
		}

		override protected function init():void
		{
			this.graphics.beginFill(0xF0DAB9);
			this.graphics.drawRoundRect(0, 0, ELEMENT_WIDTH, ELEMENT_HEIGHT, 5, 5);

			this.background = new ElementSlotBack();
			this.background.width = ELEMENT_WIDTH;
			this.background.height = ELEMENT_HEIGHT;
			addChild(this.background);

			var iconClass:Class = CollectionsData.getUniqueClass(this.elementId);
			this.icon = new iconClass();
			this.icon.scaleX = this.icon.scaleY = 0.5;
			this.icon.x += int((this.background.width - this.icon.width) / 2);
			this.icon.y += int((this.background.height - this.icon.height) / 2);
			addChild(this.icon);

			var format:TextFormat = new TextFormat(null, 13, 0x513B18, true);
			format.align = TextFormatAlign.RIGHT;

			this.countField = new GameField("0", 0, 25, format);
			this.countField.width = 41;
			this.countField.autoSize = TextFieldAutoSize.RIGHT;
			this.countField.mouseEnabled = false;
			this.countField.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 3)];
			addChild(this.countField);
		}

		override protected function updateState(e:Event = null):void
		{
			dispatchEvent(new Event(Event.CHANGE));

			this.background.filters = (this.counter == null || !this.isCollected) ? FiltersUtil.GREY_FILTER : [];
			this.icon.filters = (this.counter == null || !this.isCollected) ? FiltersUtil.GREY_FILTER : [];
		}
	}
}