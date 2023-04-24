package views.storage
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	import buttons.ButtonToggle;
	import game.gameData.CollectionsData;
	import statuses.Status;

	import utils.FiltersUtil;

	public class CollectionExchangeElement extends Sprite
	{
		static private const ELEMENT_WIDTH:int = 45;
		static private const ELEMENT_HEIGHT:int = 45;

		private var icon:DisplayObject = null;
		private var button:ButtonToggle = null;

		private var status:Status;

		public var elementId:int = -2;
		public var level:int = -1;

		public function CollectionExchangeElement():void
		{
			this.buttonMode = true;
			this.elementId = -1;

			this.graphics.beginFill(0xF0DAB9);
			this.graphics.drawRoundRect(0, 0, ELEMENT_WIDTH, ELEMENT_HEIGHT, 5, 5);

			this.button = new ButtonToggle(new ButtonExchangeElment(), new ButtonExhangeSticked(), false);
			addChild(this.button);

			this.mouseEnabled = false;
			this.mouseChildren = false;
		}

		public function set id(value:int):void
		{
			if (this.button)
				this.button.visible = (value != -1);
			if (this.status)
				this.status.remove();

			this.sticked = false;

			if (this.icon && contains(this.icon))
				removeChild(this.icon);

			this.elementId = value;

			this.mouseEnabled = this.available && this.elementId != -1;
			this.mouseChildren = this.mouseEnabled;
			this.filters = this.available ? [] : FiltersUtil.GREY_FILTER;

			if (value == -1)
				return;

			var iconClass:Class = CollectionsData.getIconClass(this.elementId);
			this.icon = new iconClass();
			this.icon.scaleX = this.icon.scaleY = 0.6;
			this.icon.x = int((ELEMENT_WIDTH - this.icon.width) * 0.5);
			this.icon.y = int((ELEMENT_HEIGHT - this.icon.height) * 0.5);
			(this.icon as DisplayObjectContainer).mouseEnabled = false;
			addChild(this.icon);

			this.status = new Status(this, CollectionsData.regularData[this.elementId]['tittle']);
		}

		public function set sticked(value:Boolean):void
		{
			if (!this.icon)
				return;

			value ? this.button.on() : this.button.off();
		}

		private function get available():Boolean
		{
			if (this.elementId == -1 || this.level == -1)
				return true;

			var collectionId:int = CollectionsData.regularData[this.elementId]['collection'];
			for (var setId:int = 0; setId < CollectionsData.locationsSets.length; setId++)
			{
				if ((CollectionsData.locationsSets[setId]['set'] as Array).indexOf(collectionId) == -1)
					continue;
				return Locations.getLocation(CollectionsData.locationsSets[setId]['location']).level <= this.level;
			}
			return true;
		}
	}
}