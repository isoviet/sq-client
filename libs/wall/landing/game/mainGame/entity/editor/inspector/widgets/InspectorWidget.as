package landing.game.mainGame.entity.editor.inspector.widgets
{
	import flash.display.Sprite;

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
	}
}