package utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class HScrollBar extends Sprite
	{
		static public const ON_SCROLL:String = "HScrollBar.ON_SCROLL";

		private var line:ScrollerLine = null;
		private var thumb:ScrollerThumb = null;

		public function HScrollBar(height:int = 380):void
		{
			this.line = new ScrollerLine();
			this.line.height = height;
			this.line.filters = [new DropShadowFilter(4.0, 114, 0xAA9681, 1, 4, 4, 1, 1, true)];
			this.line.addEventListener(MouseEvent.MOUSE_DOWN, onDownLine);
			addChild(this.line);

			this.thumb = new ScrollerThumb();
			this.thumb.x = int((this.line.width - this.thumb.width) * 0.5);
			this.thumb.addEventListener(MouseEvent.MOUSE_DOWN, dragStart);
			addChild(this.thumb);

			onThumbMoved();
		}

		private function onDownLine(e:MouseEvent):void
		{
			this.thumb.y = this.globalToLocal(new Point(e.stageX, e.stageY)).y;

			onThumbMoved();
			dragStart();
		}

		private function dragStart(e:MouseEvent = null):void
		{
			this.thumb.startDrag(false, new Rectangle(this.thumb.x, 0, 0, this.line.height - this.thumb.height));
			this.thumb.stage.addEventListener(MouseEvent.MOUSE_UP, dragStop);
			this.thumb.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function dragStop(e:MouseEvent):void
		{
			this.thumb.stopDrag();
			this.thumb.stage.removeEventListener(MouseEvent.MOUSE_UP, dragStop);
			this.thumb.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onThumbMoved():void
		{
			this.thumb.y = Math.max(Math.min(this.thumb.y, this.line.height - this.thumb.height), 0);
			updateValue();
		}

		private function onEnterFrame(e:Event):void
		{
			updateValue();
		}

		private function updateValue():void
		{
			dispatchEvent(new Event(ON_SCROLL));
		}

		public function get value():Number
		{
			return Math.min(Math.max(this.thumb.y / (this.line.height - thumb.height), 0), 1);
		}

		public function set value(value:Number):void
		{
			setWithoutEvent(value);

			updateValue();
		}

		public function setWithoutEvent(value:Number):void
		{
			value = Math.min(Math.max(value, 0), 1);
			this.thumb.y = value * (this.line.height - thumb.height);
		}
	}
}