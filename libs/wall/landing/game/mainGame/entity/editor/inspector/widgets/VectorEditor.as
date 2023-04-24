package landing.game.mainGame.entity.editor.inspector.widgets
{
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;

	import Box2D.Common.Math.b2Vec2;

	public class VectorEditor extends InspectorWidget
	{
		private var xField:TextField = new TextField();
		private var yField:TextField = new TextField();
		private var labelField:TextField = new TextField();

		private var property:String;
		private var valueScale:Number;

		public function VectorEditor(label:String, property:String, valueScale:Number = 1):void
		{
			this.property = property;
			this.valueScale = valueScale;

			this.labelField.text = label;
			this.labelField.autoSize = TextFieldAutoSize.LEFT;
			this.labelField.height = this.labelField.textHeight;
			addChild(this.labelField);

			this.xField.name = "x";
			this.xField.y = this.labelField.textHeight + 5;
			this.xField.width = 50;
			this.xField.height = 20;
			this.xField.background = true;
			this.xField.type = TextFieldType.INPUT;
			this.xField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addChild(this.xField);

			this.yField.name = "y";
			this.yField.x = 75;
			this.yField.y = this.labelField.textHeight + 5;
			this.yField.width = 50;
			this.yField.height = 20;
			this.yField.background = true;
			this.yField.type = TextFieldType.INPUT;
			this.yField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addChild(this.yField);
		}

		override public function get inspectObject():*
		{
			return super.inspectObject;
		}

		override public function set inspectObject(value:*):void
		{
			super.inspectObject = value;

			this.xField.text = String(value[this.property].x * this.valueScale);
			this.yField.text = String(value[this.property].y * this.valueScale);
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;

			this.inspectObject[this.property] = new b2Vec2(Number(this.xField.text) / this.valueScale, Number(this.yField.text) / this.valueScale);
		}
	}
}