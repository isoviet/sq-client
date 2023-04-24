package landing.game.mainGame.entity.editor.inspector.widgets
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

		public function NumberEditor(label:String ,property:String, valueScale:Number = 1):void
		{
			this.valueScale = valueScale;
			this.property = property;

			this.labelField.text = label;
			this.labelField.autoSize = TextFieldAutoSize.LEFT;
			addChild(this.labelField);

			this.numberField.x = this.labelField.textWidth + 10
			this.numberField.width = 100;
			this.numberField.height = 20;
			this.numberField.background = true;
			this.numberField.type = TextFieldType.INPUT;
			this.numberField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.numberField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.numberField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			addChild(this.numberField);
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
			this.inspectObject[this.property] = Number(this.numberField.text) / this.valueScale;
		}
	}
}