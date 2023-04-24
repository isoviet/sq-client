package buttons
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import sounds.GameSounds;
	import sounds.SoundConstants;

	public class ButtonDouble extends Sprite
	{
		protected var active:DisplayObject;
		protected var notActive:DisplayObject;

		public var state:Boolean;

		public function ButtonDouble(active:DisplayObject, notActive:DisplayObject, useBoth:Boolean = false):void
		{
			this.active = active;
			this.notActive = notActive;
			addChild(this.active);
			addChild(this.notActive);

			this.active.addEventListener(MouseEvent.CLICK, _onSound);
			this.notActive.addEventListener(MouseEvent.CLICK, _onSound);

			if (!useBoth)
			{
				if (this.notActive is InteractiveObject)
					(this.notActive as InteractiveObject).mouseEnabled = false;
				if (this.notActive is SimpleButton)
					(this.notActive as SimpleButton).useHandCursor = false;
			}
		}

		private function _onSound(event:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK);
		}

		public function setState(state:Boolean):void
		{
			this.state = state;
			this.active.visible = state;
			this.notActive.visible = !state;
		}
	}
}