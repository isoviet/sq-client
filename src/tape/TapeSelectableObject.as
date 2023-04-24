package tape
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	import tape.events.TapeElementEvent;

	public class TapeSelectableObject extends TapeObject
	{
		protected var _id:int;

		protected var buttonState:Boolean = false;

		protected var back:MovieClip = null;
		protected var backSelected:MovieClip = null;

		public function TapeSelectableObject(itemId:int)
		{
			super();

			this._id = itemId;
			this.buttonMode = true;

			init();
		}

		public function get id():int
		{
			return this._id;
		}

		public function set selected(select:Boolean):void
		{
			this.buttonState = select;

			this.backSelected.visible = this.buttonState;
			this.back.visible = !this.buttonState;
		}

		public function get selected():Boolean
		{
			return this.buttonState;
		}

		protected function init():void
		{
			addEventListener(MouseEvent.MOUSE_DOWN, stick);
		}

		protected function stick(e:MouseEvent):void
		{
			dispatchEvent(new TapeElementEvent(this, TapeElementEvent.STICKED));
		}
	}
}