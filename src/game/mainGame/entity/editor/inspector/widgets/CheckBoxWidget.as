package game.mainGame.entity.editor.inspector.widgets
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;

	import fl.controls.CheckBox;

	public class CheckBoxWidget extends InspectorWidget
	{
		private var checkBox:CheckBox = new CheckBox();
		private var property:String;

		public function CheckBoxWidget(label:String, property:String):void
		{
			this.property = property;

			this.checkBox.label = label;
			this.checkBox.textField.autoSize = TextFieldAutoSize.LEFT;
			this.checkBox.textField.height = this.checkBox.textField.textHeight + 5;
			this.checkBox.addEventListener(MouseEvent.CLICK, onClick);
			addChild(this.checkBox);
		}

		private function onClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(Event.CHANGE));

			this.inspectObject[this.property] = this.checkBox.selected;
			dispatch();
		}

		override public function get inspectObject():*
		{
			return super.inspectObject;
		}

		override public function set inspectObject(value:*):void
		{
			super.inspectObject = value;

			this.checkBox.selected = Boolean(this.inspectObject[this.property]);
		}

		override public function get widgetHeight():Number
		{
			return 25;
		}
	}
}