package buttons
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class ButtonToggle extends Sprite
	{
		public var buttonOff:SimpleButton;
		public var buttonOn:SimpleButton;

		public function ButtonToggle(buttonOff:SimpleButton, buttonOn:SimpleButton, value:Boolean):void
		{
			this.buttonOff = buttonOff;
			this.buttonOn = buttonOn;

			init(value);
		}

		override public function get width():Number
		{
			return buttonOff.width;
		}

		public function on(e:MouseEvent = null):void
		{
			toggle(true);
		}

		public function off(e:MouseEvent = null):void
		{
			toggle(false);
		}

		private function init(value:Boolean):void
		{
			toggle(value);

			addChild(this.buttonOff);
			addChild(this.buttonOn);

			this.buttonOff.addEventListener(MouseEvent.CLICK, on);
			this.buttonOn.addEventListener(MouseEvent.CLICK, off);
		}

		private function toggle(value:Boolean):void
		{
			this.buttonOff.visible = !value;
			this.buttonOn.visible = value;
		}
	}
}