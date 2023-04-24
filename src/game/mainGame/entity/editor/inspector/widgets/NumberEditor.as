package game.mainGame.entity.editor.inspector.widgets
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;

	public class NumberEditor extends InspectorWidget
	{
		private var numberField:TextField = new TextField();
		private var labelField:TextField = new TextField();

		private var property:String;
		private var valueScale:Number;

		private var minValue:Number;
		private var maxValue:Number;

		public function NumberEditor(label:String, property:String, valueScale:Number = 1, minValue:Number = -1000000000, maxValue:Number = Number.MAX_VALUE):void
		{
			this.valueScale = valueScale;
			this.property = property;

			this.labelField.text = label;
			this.labelField.autoSize = TextFieldAutoSize.LEFT;
			this.labelField.restrict = "\-[0-9]\.";
			this.labelField.maxChars = 7;
			this.labelField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.labelField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			addChild(this.labelField);

			this.numberField.x = this.labelField.textWidth + 10;
			this.numberField.width = 100;
			this.numberField.height = 20;
			this.numberField.background = true;
			this.numberField.type = TextFieldType.INPUT;
			this.numberField.restrict = "\-[0-9]\.";
			this.numberField.maxChars = 7;
			this.numberField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.numberField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.numberField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			addChild(this.numberField);

			this.minValue = minValue;
			this.maxValue = maxValue;
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

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;
			set();
		}

		private function get():void
		{
			this.numberField.text = String(this.inspectObject[this.property] * this.valueScale);
		}

		private function set():void
		{
			var textValue:Number = Number(this.numberField.text) / this.valueScale;

			var value:Number;
			if (textValue < this.minValue)
				value = this.minValue;
			else if (textValue > this.maxValue)
				value = this.maxValue;
			else
				value = textValue;

			this.inspectObject[this.property] = value;
			dispatch();
		}
	}
}