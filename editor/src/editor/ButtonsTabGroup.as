package editor
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	import fl.controls.Button;

	public class ButtonsTabGroup extends Sprite
	{
		static private const BLACK_FORMAT:TextFormat = new TextFormat("Arial", 12, 0x000000);
		static private const RED_FORMAT:TextFormat = new TextFormat("Arial", 12, 0xFF0000);

		protected var items:Dictionary = new Dictionary();

		public var selected:Button = null;
		public var count:int = 0;

		public function insert(button:Button, elements:* = null):void
		{
			if (elements != null)
			{
				if (!(elements is Array))
					elements = [elements];
				for (var i:int = 0; i < (elements as Array).length; i++)
					(elements[i] as DisplayObject).visible = false;
			}

			this.items[button] = elements;

			button.setStyle("textFormat", BLACK_FORMAT);
			button.addEventListener(MouseEvent.CLICK, select);

			add(button);

			if (this.selected == null)
			{
				this.count++;

				setSelected(button);
				return;
			}

			this.count++;
		}

		public function setSelected(button:*):void
		{
			if (this.selected == button)
				return;

			if (this.selected != null)
				stick(this.selected, false);

			for (var button2:* in this.items)
			{
				var elements:Array = this.items[button2];
				if (elements == null)
					continue;

				for (var i:int = 0; i < elements.length; i++)
					(elements[i] as DisplayObject).visible = (button2 == button);
			}

			if (button != null)
			{
				stick(button, true);

				if (this.selected != null && this.selected.parent && (button as DisplayObject).parent)
					swapChildren(this.selected, button);
			}

			this.selected = button;
		}

		private function add(button:*):void
		{
			var selectedIndex:int = -1;
			if (this.selected !== null)
				selectedIndex = getChildIndex(this.selected);

			if (selectedIndex == -1)
				addChild(button);
			else
				addChildAt(button, selectedIndex);
		}

		private function select(e:MouseEvent):void
		{
			setSelected(e.currentTarget);
		}

		private function stick(button:Button, value:Boolean):void
		{
			button.setStyle("textFormat", value ? RED_FORMAT : BLACK_FORMAT);
		}
	}
}