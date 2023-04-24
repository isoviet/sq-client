package game.mainGame.entity.editor.inspector
{
	import flash.display.Sprite;

	import events.EditNewElementEvent;
	import game.mainGame.entity.editor.inspector.widgets.InspectorWidget;

	public class Inspector extends Sprite
	{
		static private const OFFSET:int = 10;

		private var _inspectObject:*;

		private var widgets:Vector.<InspectorWidget> = new Vector.<InspectorWidget>;

		public function set inspectObject(value:*):void
		{
			this._inspectObject = value;

			for each (var widget:InspectorWidget in widgets)
				widget.inspectObject = value;
		}

		public function get inspectObject():*
		{
			return this._inspectObject;
		}

		public function get widgetsHeight():Number
		{
			var result:Number = 0;
			for each (var widget:InspectorWidget in widgets)
				result += widget.widgetHeight + OFFSET;
			return result;
		}

		public function addWidget(widget:InspectorWidget):void
		{
			widget.y = this.widgetsHeight;
			widgets.push(widget);
			widget.addEventListener(EditNewElementEvent.CHANGE, dispatch);
			addChild(widget);
		}

		protected function dispatch(e:EditNewElementEvent):void
		{
			dispatchEvent(new EditNewElementEvent(EditNewElementEvent(e).className, e.type));
		}
	}
}