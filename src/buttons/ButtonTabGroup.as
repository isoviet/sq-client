package buttons
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	import events.ButtonTabEvent;

	public class ButtonTabGroup extends Sprite
	{
		protected var items:Dictionary = new Dictionary();

		public var selectedElement:* = null;
		public var selected:ButtonTab = null;
		public var count:int = 0;
		public var tabs:Vector.<DisplayObject> = new Vector.<DisplayObject>();

		public function insert(button:ButtonTab, elements:* = null):void
		{
			if (elements != null)
			{
				if (!(elements is Array))
					elements = [elements];
				for (var i:int = 0; i < elements.length; i++)
					elements[i].visible = false;
			}

			this.items[button] = elements;

			button.addEventListener(ButtonTabEvent.SELECT, select);
			add(button);

			if (this.selected == null)
			{
				this.count++;

				setSelected(button);
				dispatchEvent(new ButtonTabEvent(ButtonTabEvent.CHANGE));
				return;
			}

			this.count++;

			dispatchEvent(new ButtonTabEvent(ButtonTabEvent.CHANGE));
		}

		public function setSelectedByIndex(index:int):void
		{
			var button:DisplayObject = this.tabs[index];
			setSelected(button ? button : this.tabs[0]);
		}

		public function setSelected(button:*):void
		{
			if (this.selected == button)
				return;

			if (this.selected != null)
				this.selected.sticked = false;

			for (var button2:* in this.items)
			{
				var elements:Array = this.items[button2];
				if (elements == null)
					continue;

				for (var i:int = 0; i < elements.length; i++)
				{
					elements[i].visible = (button2 == button);
					if (elements[i].visible)
						this.selectedElement = elements[i];
				}
			}

			if (button != null)
				button.sticked = true;

			this.selected = button;

			dispatchEvent(new ButtonTabEvent(ButtonTabEvent.SELECT, button));
		}

		private function add(button:*):void
		{
			addChild(button);
			this.tabs.push(button);
		}

		private function select(e:ButtonTabEvent):void
		{
			setSelected(e.button);
		}
	}
}