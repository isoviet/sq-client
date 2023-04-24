package game.mainGame.entity.editor.inspector.widgets
{
	import flash.display.Sprite;

	import events.EditNewElementEvent;

	public class InspectorWidget extends Sprite
	{
		private var _inspectObject:*;

		public function set inspectObject(value:*):void
		{
			this._inspectObject = value;
		}

		public function get inspectObject():*
		{
			return this._inspectObject;
		}

		public function get widgetHeight():Number
		{
			return this.height;
		}

		protected function dispatch():void
		{
			dispatchEvent(new EditNewElementEvent(this._inspectObject, EditNewElementEvent.CHANGE));
		}
	}
}