package game.mainGame.entity.editor.inspector.widgets
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;

	public class TextEditor extends InspectorWidget
	{
		private var textField:TextField = new TextField();
		private var labelField:TextField = new TextField();

		private var property:String;

		public function TextEditor(label:String, property:String, width:Number, height:Number, multiline:Boolean = true):void
		{
			this.property = property;

			this.labelField.text = label;
			this.labelField.autoSize = TextFieldAutoSize.LEFT;
			addChild(this.labelField);

			this.textField.y = this.labelField.textHeight + 10;
			this.textField.width = width;
			this.textField.height = height;
			this.textField.background = true;
			this.textField.multiline = multiline;
			this.textField.wordWrap = true;
			this.textField.type = TextFieldType.INPUT;
			this.textField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true, 10, true);
			this.textField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.textField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			addChild(this.textField);
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
			e.stopImmediatePropagation();
			e.stopPropagation();
			e.preventDefault();
			if (e.keyCode != Keyboard.ENTER)
				return;
			set();
		}

		private function get():void
		{
			this.textField.text = this.inspectObject[this.property];
		}

		private function set():void
		{
			this.inspectObject[this.property] = this.textField.text;
			dispatch();
		}
	}
}