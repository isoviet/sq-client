package game.mainGame.entity.editor.inspector.widgets
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
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
		private var minValue:Number;

		public function VectorEditor(label:String, property:String, valueScale:Number = 1, minValue:Number = NaN):void
		{
			this.property = property;
			this.valueScale = valueScale;
			this.minValue = minValue;

			this.labelField.text = label;
			this.labelField.autoSize = TextFieldAutoSize.LEFT;
			this.labelField.restrict = "\-[0-9]\.";
			this.labelField.maxChars = 7;
			this.labelField.height = this.labelField.textHeight;
			addChild(this.labelField);

			this.xField.name = "x";
			this.xField.y = this.labelField.textHeight + 5;
			this.xField.width = 50;
			this.xField.height = 20;
			this.xField.background = true;
			this.xField.restrict = "\-[0-9]\.";
			this.xField.maxChars = 7;
			this.xField.type = TextFieldType.INPUT;
			this.xField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.xField.selectable = true;
			this.xField.mouseEnabled = true;
			addChild(this.xField);

			this.yField.name = "y";
			this.yField.x = 75;
			this.yField.y = this.labelField.textHeight + 5;
			this.yField.width = 50;
			this.yField.height = 20;
			this.yField.background = true;
			this.yField.restrict = "\-[0-9]\.";
			this.yField.maxChars = 7;
			this.yField.type = TextFieldType.INPUT;
			this.yField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.yField.selectable = true;
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

			if (!isNaN(this.minValue))
			{
				this.xField.text = Math.max(this.minValue * this.valueScale, Number(this.xField.text)).toString();
				this.yField.text = Math.max(this.minValue * this.valueScale, Number(this.yField.text)).toString();
			}

			this.inspectObject[this.property] = this.inspectObject[this.property] is b2Vec2 ? new b2Vec2(Number(this.xField.text) / this.valueScale, Number(this.yField.text) / this.valueScale) : new Point(Number(this.xField.text) / this.valueScale, Number(this.yField.text) / this.valueScale);
			dispatch();
		}

	}
}