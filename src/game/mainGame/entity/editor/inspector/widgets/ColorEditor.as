package game.mainGame.entity.editor.inspector.widgets
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	import fl.controls.ColorPicker;
	import fl.events.ColorPickerEvent;

	public class ColorEditor extends InspectorWidget
	{
		private var labelField:TextField = new TextField();

		private var property:String;
		private var picker:ColorPicker = new ColorPicker();

		public function ColorEditor(label:String, property:String):void
		{
			this.property = property;

			this.labelField.text = label;
			this.labelField.autoSize = TextFieldAutoSize.LEFT;
			this.labelField.restrict = "\-[0-9]\.";
			this.labelField.maxChars = 7;
			this.labelField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.labelField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			addChild(this.labelField);

			this.picker.x = this.labelField.textWidth + 10;
			this.picker.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.picker.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);

			this.picker.addEventListener(ColorPickerEvent.CHANGE, onChange, false, 0, true);
			this.picker.addEventListener(ColorPickerEvent.ITEM_ROLL_OVER, onChange, false, 0, true);
			addChild(this.picker);
		}

		private function onChange(event:ColorPickerEvent):void
		{
			set();
		}

		private function onFocusIn(e:FocusEvent):void
		{
			get();
		}

		private function onFocusOut(e:Event):void
		{
			set();
		}

		override public function get inspectObject():*
		{
			return super.inspectObject;
		}

		override public function set inspectObject(value:*):void
		{
			super.inspectObject = value;
			get();
		}

		private function get():void
		{
			this.picker.selectedColor = this.inspectObject[this.property];
		}

		private function set():void
		{
			this.inspectObject[this.property] = this.picker.selectedColor;
			dispatch();
		}
	}
}