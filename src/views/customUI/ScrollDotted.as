package views.customUI
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	import com.greensock.TweenMax;

	import utils.ColorMatrix;

	public class ScrollDotted extends Sprite
	{
		public static const DIRECTION_LEFT: int = 0;
		public static const DIRECTION_RIGHT: int = 1;

		private static const DOT_RADIUS: int = 5;
		private static const DEFAULT_DOT_COLOR: uint = 0xA0D0E0;
		private static const DEFAULT_DOT_COLOR_ACTIVE: uint = 0x0099CC;

		public var buttonLeft:SimpleButton = new ButtonRewindLeft();
		public var buttonRight:SimpleButton = new ButtonRewindRight();
		public var countItems:int = 0;

		private var lineDots:Sprite = new Sprite();
		private var selectedIndex:int = -1;
		private var dotColor:uint = 0;
		private var activeDotColor:uint = 0;
		private var widthLine:int = 0;
		private var callback:Function = null;
		private var lastScrollDirection:int = 0;
		private var trmAutoScroll:uint = 0;

		public function ScrollDotted(countItems:int, widthLine:int = 300, dotColor:uint = DEFAULT_DOT_COLOR, activeDotColor:uint = DEFAULT_DOT_COLOR_ACTIVE)
		{
			this.dotColor = dotColor;
			this.activeDotColor = activeDotColor;
			this.countItems = countItems;
			this.widthLine = widthLine;

			this.buttonLeft.scaleX = this.buttonLeft.scaleY = 0.8;
			this.buttonRight.scaleX = this.buttonRight.scaleY = 0.8;

			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(0, 0, 0, 70);
			var filterBlue:ColorMatrixFilter = new ColorMatrixFilter(colorMatrix);

			this.buttonLeft.filters = [filterBlue];
			this.buttonRight.filters = [filterBlue];

			this.addChild(this.buttonLeft);
			this.addChild(this.buttonRight);
			this.addChild(this.lineDots);

			this.buttonLeft.addEventListener(MouseEvent.CLICK, onScroll);
			this.buttonRight.addEventListener(MouseEvent.CLICK, onScroll);

			var sprite:Sprite;
			var step:int = (widthLine - this.buttonLeft.width - this.buttonRight.width) / this.countItems - DOT_RADIUS / 2;

			for(var i: int = 0; i < this.countItems; i++)
			{
				sprite = new Sprite();
				sprite.buttonMode = true;
				sprite.useHandCursor = true;
				sprite.addEventListener(MouseEvent.CLICK, onClickDot);
				drawDot(sprite, false);
				sprite.x = step * i;

				this.lineDots.addChild(sprite);
			}

			this.lineDots.x = widthLine / 2 - this.lineDots.width / 2 + this.buttonLeft.width / 2;
			this.lineDots.y = this.buttonLeft.y + this.buttonLeft.height / 2;
			this.buttonRight.x = widthLine - this.buttonRight.width / 2;
		}

		public function setCountItems(value:int):void
		{
			this.countItems = value;

			while(this.lineDots.numChildren > 0)
				this.lineDots.removeChild(this.lineDots.getChildAt(0)).removeEventListener(MouseEvent.CLICK, onClickDot);

			var sprite:Sprite;
			var step:int = (widthLine - this.buttonLeft.width - this.buttonRight.width) / this.countItems - DOT_RADIUS / 2;

			for(var i: int = 0; i < this.countItems; i++)
			{
				sprite = new Sprite();
				sprite.buttonMode = true;
				sprite.useHandCursor = true;
				sprite.addEventListener(MouseEvent.CLICK, onClickDot);
				drawDot(sprite, false);
				sprite.x = step * i;

				this.lineDots.addChild(sprite);
			}

			this.lineDots.x = widthLine / 2 - this.lineDots.width / 2 + this.buttonLeft.width / 2;
			this.lineDots.y = this.buttonLeft.y + this.buttonLeft.height / 2;
		}

		public function startAutoScroll(delay: Number, direction:int): void
		{
			if (this.trmAutoScroll)
				clearInterval(this.trmAutoScroll);
			this.trmAutoScroll = setInterval(autoScrollCompute, delay, direction);
		}

		public function stopAutoScroll(): void
		{
			if (this.trmAutoScroll != 0)
				clearInterval(this.trmAutoScroll);
			this.trmAutoScroll = 0;
		}

		public function setOnChangeIndex(callback:Function):void
		{
			this.callback = callback;
		}

		public function setSelected(index:int): void
		{
			if (this.selectedIndex == index || index < 0 || index >= this.lineDots.numChildren)
				return;
			var sprite:Sprite;

			if (this.selectedIndex > -1)
			{
				sprite = this.lineDots.getChildAt(this.selectedIndex) as Sprite;
				drawDot(sprite, false);
			}

			this.selectedIndex = index;
			sprite = this.lineDots.getChildAt(this.selectedIndex) as Sprite;
			drawDot(sprite, true);

			if (this.callback != null)
				this.callback(this.selectedIndex, this.lastScrollDirection);
		}

		public function dispose(): void
		{
			this.buttonLeft.removeEventListener(MouseEvent.CLICK, onScroll);
			this.buttonRight.removeEventListener(MouseEvent.CLICK, onScroll);

			while(this.lineDots.numChildren > 0)
				this.lineDots.removeChild(this.lineDots.getChildAt(0)).removeEventListener(MouseEvent.CLICK, onClickDot);

			removeChild(this.lineDots);
			this.lineDots = null;
			removeChild(this.buttonRight);
			removeChild(this.buttonLeft);
			this.buttonRight = null;
			this.buttonLeft = null;
		}

		public function onScroll(e:MouseEvent):void
		{
			var index:int = this.selectedIndex + (e.currentTarget == this.buttonLeft ? -1 : 1);
			this.lastScrollDirection = e.currentTarget == this.buttonLeft ? DIRECTION_LEFT : DIRECTION_RIGHT;

			stopAutoScroll();
			setSelected(computeScrollIndex(index));
		}

		private function autoScrollCompute(direction: int): void
		{
			var index: int = this.selectedIndex + (direction == DIRECTION_LEFT ? -1 : 1);
			this.lastScrollDirection = direction == DIRECTION_LEFT ? DIRECTION_LEFT : DIRECTION_RIGHT;
			setSelected(computeScrollIndex(index));
		}

		private function drawDot(sprite:Sprite, active:Boolean): void
		{
			var color:uint = active ? this.activeDotColor : this.dotColor;
			sprite.scaleX = sprite.scaleY = active ? 0 : 1;

			sprite.graphics.clear();
			sprite.graphics.beginFill(color, 1);
			sprite.graphics.drawCircle(0, 0, DOT_RADIUS);
			sprite.graphics.endFill();
			TweenMax.to(sprite, 0.2, {'scaleX': 1, 'scaleY': 1});
		}

		private function computeScrollIndex(index:int):int
		{
			if (index >= this.countItems)
				index = 0;
			else if (index < 0)
				index = this.countItems - 1;

			return index;
		}

		private function onClickDot(e:MouseEvent):void
		{
			var index:int = this.lineDots.getChildIndex(e.currentTarget as DisplayObject);

			this.lastScrollDirection = index < this.selectedIndex ? DIRECTION_LEFT : DIRECTION_RIGHT;

			stopAutoScroll();
			setSelected(index);
		}
	}
}