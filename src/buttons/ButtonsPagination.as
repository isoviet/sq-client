package buttons
{
	import flash.display.Sprite;

	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import events.ButtonTabEvent;
	import events.PaginationEvent;

	public class ButtonsPagination extends Sprite
	{
		private var tabButtons:Vector.<ButtonTab> = null;

		private var tabGroup:ButtonTabGroup = null;

		public function ButtonsPagination(button:Class, count:int, buttonWidth:int):void
		{
			init(button, count, buttonWidth);
		}

		public function setSelected(index:int):void
		{
			if (index < 0 || index >= this.tabButtons.length)
				return;

			this.tabGroup.setSelected(this.tabButtons[index]);
		}

		public function addButton(button:ButtonTab):void
		{
			this.tabButtons.push(button);
			this.tabGroup.insert(button);
		}

		private function init(button:Class, count:int, buttonWidth:int):void
		{
			this.tabGroup = new ButtonTabGroup();
			addChild(this.tabGroup);

			this.tabButtons = new Vector.<ButtonTab>();

			for (var i:int = 0; i < count; i++)
			{
				var tabButton:ButtonTab = new ButtonTab(new button());
				tabButton.x = i * buttonWidth;
				tabButton.name = i.toString();
				this.tabButtons.push(tabButton);

				this.tabGroup.insert(tabButton);
			}

			this.tabGroup.addEventListener(ButtonTabEvent.SELECT, onSelect);
		}

		private function onSelect(e:ButtonTabEvent):void
		{
			dispatchEvent(new PaginationEvent(int(e.button.name)));
		}
	}
}