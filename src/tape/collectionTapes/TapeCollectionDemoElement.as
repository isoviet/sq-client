package tape.collectionTapes
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import game.gameData.CollectionsData;
	import tape.TapeObject;

	import utils.FiltersUtil;

	public class TapeCollectionDemoElement extends TapeObject
	{
		static private const BUTTON_WIDTH:int = 47;
		static private const BUTTON_HEIGHT:int = 45;

		private var count:int = 0;

		private var countField:GameField = null;

		private var icon:DisplayObject = null;
		private var background:DisplayObject = null;

		public var elementId:int = -1;

		public function TapeCollectionDemoElement():void
		{
			super();

			this.background = new ElementSlotBack();
			background.width = background.height = 45;
			addChild(this.background);

			var countFormat:TextFormat = new TextFormat(null, 13, 0x513B18, true);
			countFormat.align = TextFormatAlign.RIGHT;

			this.countField = new GameField("0", 0, 28, countFormat, 45);
			this.countField.autoSize = TextFieldAutoSize.NONE;
			this.countField.width = 43;
			this.countField.mouseEnabled = false;
			this.countField.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 3)];
			addChildAt(this.countField, 1);

			updateState(false);
		}

		public function setData(elementId:int, count:int, canExchange:Boolean = true):void
		{
			if (this.icon != null && contains(this.icon))
				removeChild(this.icon);

			this.elementId = elementId;

			if (this.elementId != -1)
			{
				var iconClass:Class = CollectionsData.getIconClass(elementId);
				this.icon = new iconClass();
				this.icon.scaleX = this.icon.scaleY = 0.56;
				this.icon.x = int((BUTTON_WIDTH - this.icon.width) / 2);
				this.icon.y = int((BUTTON_HEIGHT - this.icon.height) / 2);
				addChildAt(this.icon, 1);
			}

			this.count = count;

			updateState(this.count == 0 || !canExchange);
		}

		private function updateState(locked:Boolean):void
		{
			dispatchEvent(new Event(Event.CHANGE));

			this.background.filters = locked ? FiltersUtil.GREY_FILTER : [];

			if (this.icon != null)
				this.icon.filters = locked ? FiltersUtil.GREY_FILTER : [];

			this.countField.text = (this.count == 0) ? "" : this.count.toString();
		}
	}
}