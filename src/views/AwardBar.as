package views
{
	import flash.display.DisplayObject;

	import utils.Bar;

	public class AwardBar extends Bar
	{
		private var backBarSelect:DisplayObject = null;

		public function AwardBar(images:Array, width:int, swapChild:Boolean = false)
		{
			super(images, width, swapChild);
		}

		public function addBackSelect(image:DisplayObject):void
		{
			if (this.backBar == null)
				return;
			this.backBarSelect = image;
			this.backBarSelect.x = this.backBar.x;
			this.backBarSelect.y = this.backBar.y;
			this.backBarSelect.visible = false;

			addChildAt(this.backBarSelect, getChildIndex(this.backBar));
		}

		public function switchBack(value:Boolean):void
		{
			if (this.backBarSelect == null)
				return;
			this.backBarSelect.visible = value;
			this.backBar.visible = !value;
		}
	}
}