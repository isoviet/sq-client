package game.mainGame.gameEditor
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.ui.Keyboard;

	import game.mainGame.entity.IGameObject;
	import statuses.Status;

	public class StatusObjectName extends Status
	{
		static private const GLOW_FILTER:Array = [new GlowFilter(0xFFFFFF, 1, 10, 10, 5, 1, true)];

		private var object:Object;
		private var map:GameMapEditor;

		public function StatusObjectName(map:GameMapEditor):void
		{
			this.map = map;
			super(map.objectSprite);
			this.alpha = 0;

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Game.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			if (!this.object)
				return;

			this.object.filters = value ? GLOW_FILTER : ((this.map.selection.selection.indexOf(this.object as IGameObject) == -1) ? null : this.object.filters);
		}

		override public function remove():void
		{
			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Game.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			super.remove();
		}

		override protected function onShow(e:MouseEvent):void
		{
			var object:Object = e.target;

			while (!(object is IGameObject))
			{
				if (object.parent)
					object = object.parent;
				else
					break;
			}

			if (this.object == object || !(object is IGameObject))
				return;

			this.object = object;

			if (this.alpha == 1)
				this.object.filters = GLOW_FILTER;

			setStatus(this.object.name);
			super.onShow(e);
		}

		override protected function close(e:MouseEvent = null):void
		{
			if (this.object)
				this.object.filters = (this.map.selection.selection.indexOf(this.object as IGameObject) == -1) ? null : this.object.filters;
			this.object = null;

			super.close(e);
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.CONTROL && e.keyCode != Keyboard.SHIFT)
				return;

			this.alpha = e.shiftKey ? 0 : 1;
		}

		private function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.CONTROL || this.alpha == 0)
				return;

			this.alpha = 0;
		}
	}
}