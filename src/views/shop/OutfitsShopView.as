package views.shop
{
	import flash.display.Sprite;

	import views.customUI.ScrollDotted;

	public class OutfitsShopView extends Sprite
	{
		static private const MAX_COUNT:int = 4;

		protected var scrollDotted:ScrollDotted = null;
		protected var items:Vector.<OutfitElementView> = new <OutfitElementView>[];

		public function OutfitsShopView()
		{
			this.y = 95;

			for (var i:int = 0; i < this.itemsIds.length; i++)
			{
				var item:OutfitElementView = new OutfitElementView(this.itemsIds[i], false, false);
				item.x = 15 + i * 220;
				item.y = 70;
				item.visible = i < MAX_COUNT;
				addChild(item);

				if (item.visible)
					item.onShow();

				this.items.push(item);
			}

			if (this.items.length <= MAX_COUNT)
				return;
			var pages:int = (this.itemsIds.length - 1) / MAX_COUNT + 1;
			this.scrollDotted = new ScrollDotted(pages, pages * 25, 0xE0BCA0, 0xFFB33F);
			this.scrollDotted.x = int((Config.GAME_WIDTH - this.scrollDotted.width) * 0.5);
			this.scrollDotted.y = 500;
			this.scrollDotted.setOnChangeIndex(onChange);
			this.scrollDotted.setSelected(0);
			addChild(this.scrollDotted);
		}

		protected function get itemsIds():Array
		{
			return null;
		}

		private function onChange(index:int, direction:int):void
		{
			for (var i:int = 0; i < this.items.length; i++)
			{
				this.items[i].visible = (index * MAX_COUNT <= i) && (i < index * MAX_COUNT + MAX_COUNT);
				this.items[i].x = this.items[i].visible ? 15 + (i - index * MAX_COUNT) * 220 : 0;

				if (this.items[i].visible)
					this.items[i].onShow();
			}
		}
	}
}