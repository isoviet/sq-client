package buttons
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;

	import utils.FiltersUtil;

	public class ButtonLockable extends Sprite
	{
		private var buttonEnabled:Boolean = true;

		private var sprite:Sprite = null;
		private var button:SimpleButton = null;

		public function ButtonLockable(button:SimpleButton):void
		{
			super();

			this.button = button;
			this.button.upState.cacheAsBitmap = true;
			this.sprite = new Sprite();
			addChild(this.sprite);

			this.sprite.addChild(this.button);
		}

		override public function get mouseEnabled():Boolean
		{
			return this.buttonEnabled;
		}

		override public function set mouseEnabled(enabled:Boolean):void
		{
			if (this.buttonEnabled == enabled)
				return;

			this.buttonEnabled = enabled;
			this.button.enabled = enabled;
			this.button.mouseEnabled = enabled;

			this.filters = enabled ? [] : FiltersUtil.GREY_FILTER;
		}
	}
}