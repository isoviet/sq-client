package views
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	public class PlayerPlaceSocial extends PlayerPlace
	{
		public function PlayerPlaceSocial(placeButton:DisplayObject):void
		{
			super(placeButton);
		}

		public function setButton(_button:DisplayObject):void
		{
			if (this.button.parent != null)
			{
				this.button.removeEventListener(MouseEvent.MOUSE_UP, onClick);
				removeChild(this.button);
			}

			_button['name'] = this.button['name'];
			this.button = _button;
			addChildAt(this.button, 1);
			this.button.addEventListener(MouseEvent.MOUSE_UP, onClick);
		}
	}
}