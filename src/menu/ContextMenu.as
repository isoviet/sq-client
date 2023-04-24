package menu
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class ContextMenu extends Sprite
	{
		private var items:Array = [];
		private var _width:int;

		protected var displayedCount:int;

		public function ContextMenu(width:int):void
		{
			super();

			this.visible = false;
			this._width = width;

			init();
		}

		public function add(value:Object):ContextMenuItem
		{
			var item:ContextMenuItem = new ContextMenuItem(value['name'], this._width - 2, value['active'], value['passive']);
			item.x = 2;
			item.addEventListener(ContextMenuItemEvent.NAME, selectItem);
			item.addEventListener(ContextMenuItemEvent.NAME, value['handler']);
			addChild(item);
			this.items.push(item);

			return item;
		}

		public function update(shift:int = 42):void
		{
			this.displayedCount = 0;

			for (var i:int = 0; i < this.items.length; i++)
			{
				var item:ContextMenuItem = this.items[i];
				item.y = 0;

				if (!item.visible)
					continue;

				item.y = shift;

				shift += item.height;
				this.displayedCount++;
			}
		}

		protected function show(e:MouseEvent):void
		{
			Game.gameSprite.addChild(this);

			this.visible = true;

			var gamePoint:Point = Game.gameSprite.globalToLocal(new Point(Game.stage.mouseX, Game.stage.mouseY));

			this.x = gamePoint.x;
			this.y = gamePoint.y + 20;

			if (this.x + this.width > Config.GAME_WIDTH)
				this.x = gamePoint.x - this.width;

			if (this.y + this.height > Config.GAME_HEIGHT)
				this.y = gamePoint.y - this.height;
		}

		private function init():void
		{
			Game.stage.addEventListener(MouseEvent.MOUSE_DOWN, click);
		}

		private function click(e:MouseEvent):void
		{
			var gamePoint:Point = Game.gameSprite.globalToLocal(new Point(e.stageX, e.stageY));

			if (gamePoint.x >= this.x && gamePoint.x <= (this.x + this.width) && (gamePoint.y + 20) >= this.y && gamePoint.y <= (this.y + this.height))
				return;

			this.visible = false;
		}

		private function selectItem(e:ContextMenuItemEvent):void
		{
			this.visible = false;
		}
	}
}