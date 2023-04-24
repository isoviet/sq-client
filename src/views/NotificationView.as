package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class NotificationView extends Sprite
	{
		private var target:DisplayObject;

		private var view:NotificationAnimationView;

		private var _active:Boolean = true;

		public function NotificationView(target:DisplayObject, offsetX:Number = 0, offsetY:Number = 0)
		{
			super();

			this.view = new NotificationAnimationView();
			this.view.x = target.x + offsetX;
			this.view.y = target.y + offsetY;
			this.view.visible = true;
			this.view.gotoAndPlay(1);
			addChild(this.view);

			this.target = target;

			if (this.target.parent)
				this.target.parent.addChildAt(this, this.target.parent.numChildren);
			else
				this.target.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}

		public function get active():Boolean
		{
			return this._active;
		}

		public function set active(value:Boolean):void
		{
			if (this._active == value)
				return;

			this._active = value;

			this.view.visible = value;

			if (value)
				this.view.gotoAndPlay(1);
			else
				this.view.stop();
		}

		private function onAdded(e:Event):void
		{
			this.target.removeEventListener(Event.ADDED_TO_STAGE, onAdded);

			this.target.parent.addChildAt(this, this.target.parent.numChildren);
		}
	}
}