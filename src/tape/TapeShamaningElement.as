package tape
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import dialogs.DialogMapInfo;
	import game.mainGame.entity.simple.PoiseInvisible;
	import game.mainGame.entity.simple.PoiseInvisibleRight;

	import utils.ClassUtil;

	public class TapeShamaningElement extends TapeShamanElement
	{
		private var on:ShamaningOn = new ShamaningOn();
		private var off:ShamaningOff = new ShamaningOff();
		private var _state:Boolean = false;

		public var inverted:Boolean = false;

		public function TapeShamaningElement(className:Class):void
		{
			super(className, TapeShamaingButton);

			this.button.addEventListener(MouseEvent.CLICK, onClickButton);

			this.on.x = 39;
			this.on.y = 29;
			this.on.mouseEnabled = false;
			addChild(this.on);

			this.inverted = ClassUtil.isImplement(this.className, "ISaveInvert");
			this.off.x = 39;
			this.off.y = 29;
			this.off.mouseEnabled = false;
			addChild(this.off);

			this.state = this.inverted;
		}

		public function get state():Boolean
		{
			return this._state;
		}

		public function set state(value:Boolean):void
		{
			this._state = value;
			value = inverted ? !value : value;
			this.on.visible = value;
			this.off.visible = !value;
		}

		private function onClickButton(e:Event):void
		{
			if ((className == PoiseInvisible || className == PoiseInvisibleRight) && DialogMapInfo.mode != Locations.BLACK_SHAMAN_MODE)
			{
				this.state = false;
				return;
			}

			this.state = !this.state;
		}
	}
}