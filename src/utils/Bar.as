package utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import com.greensock.TweenLite;

	public class Bar extends Sprite
	{
		protected var backBar:DisplayObject = null;
		protected var activeBar:DisplayObject = null;
		protected var maskBar:DisplayObject = null;

		private var maxValue:int;
		private var currentValue:int;
		private var activeX:int;
		private var barWidth:int;

		public var reverse:Boolean = false;
		public var min:int = 0;

		public function Bar(images:Array, width:int, swapChild:Boolean = false):void
		{
			super();
			init(images, width, swapChild);
		}

		public function changeActive(image:DisplayObject, imageX:int, imageY:int):void
		{
			if (this.activeBar != null && contains(this.activeBar))
				removeChild(this.activeBar);

			this.activeBar = image;
			this.activeBar.x = imageX;
			this.activeBar.y = imageY;
			addChild(this.activeBar);

			if (this.maskBar != null)
				this.activeBar.mask = this.maskBar;
		}

		public function init(images:Array, width:int, swapChild:Boolean):void
		{
			this.barWidth = width;

			initBack(images[0]['image'], images[0]['X'], images[0]['Y']);
			initActive(images[1]['image'], images[1]['X'], images[1]['Y']);
			if (!(2 in images) || images[2] == null)
			{
				var sprite:Sprite = new Sprite();
				sprite.graphics.beginFill(0x000000, 1);
				sprite.graphics.drawRect(0, 0, this.activeBar.width, this.activeBar.height);
				initMask(sprite, images[1]['X'], images[1]['Y']);
			}
			else
				initMask(images[2]['image'], images[2]['X'], images[2]['Y']);

			setValues(0, 1, 0);
			this.activeX = images[1]['X'];

			if (swapChild)
				swapChildren(backBar, activeBar);
		}

		public function setValues(current:int, ...args):void
		{
			var speed:Number = 0.5;

			this.currentValue = current;

			if (args.length >= 1)
				this.maxValue = args[0];

			if (args.length >= 2)
				speed = args[1];

			if (this.maxValue == 0)
				this.maxValue = 1;

			if (this.maxValue < this.currentValue)
				this.currentValue = this.maxValue;

			var barX:Number = this.activeX + this.barWidth * (1 - (this.currentValue / this.maxValue));

			if (this.reverse)
				TweenLite.to(this.maskBar, speed, {'x':barX, 'scaleX': (this.currentValue / this.maxValue)});
			if (!this.reverse)
				TweenLite.to(this.maskBar, speed, {'scaleX': getScale()});
		}

		public function get widthBar():int
		{
			return this.maskBar.width * getScale();
		}

		private function getScale():Number
		{
			var value:Number = (this.currentValue / this.maxValue + this.min / this.maxValue);
			if (value > 1)
				value = 1;
			return value;
		}

		private function initBack(image:DisplayObject, imageX:int, imageY:int):void
		{
			this.backBar = image;
			this.backBar.x = imageX;
			this.backBar.y = imageY;
			addChild(this.backBar);
		}

		private function initActive(image:DisplayObject, imageX:int, imageY:int):void
		{
			this.activeBar = image;
			this.activeBar.x = imageX;
			this.activeBar.y = imageY;
			addChild(this.activeBar);
		}

		private function initMask(image:DisplayObject, imageX:int, imageY:int):void
		{
			this.maskBar = image;
			this.maskBar.x = imageX;
			this.maskBar.y = imageY;
			addChild(this.maskBar);

			this.activeBar.mask = this.maskBar;
		}
	}
}