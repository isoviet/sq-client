package utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import com.greensock.TweenLite;

	public class BarScale extends Sprite
	{
		private var backBar:DisplayObject = null;
		private var activeBar:DisplayObject = null;
		private var superBar:DisplayObject = null;

		private var activeX:int;

		private var activeWidth:int;
		private var superWidth:int;

		private var isSuper:Boolean = false;

		private var currentValue:int = 0;
		private var maxValue:int = 0;

		public function BarScale(images:Array, swapChild:Boolean = false):void
		{
			super();
			init(images, swapChild);
		}

		public function changeSuper(value:Boolean):void
		{
			if (!this.superBar)
				return;

			this.isSuper = value;

			if (this.isSuper)
				this.superBar.width = this.activeBar.width;
			else
				this.activeBar.width = this.superBar.width;

			this.superBar.visible = this.isSuper;
			this.activeBar.visible = !this.isSuper;

			setValues(this.currentValue, this.maxValue);
		}

		public function getWidth():int
		{
			return (this.isSuper ? this.superBar.width : this.activeBar.width);
		}

		public function setValues(current:int, max:int, speed:Number = 0.5):void
		{
			this.currentValue = current;
			this.maxValue = max;

			if (this.maxValue < this.currentValue)
				this.currentValue = this.maxValue;

			var width:int = (this.isSuper ? this.superWidth : this.activeWidth);
			var currentBar:DisplayObject = (this.isSuper ? this.superBar : this.activeBar);

			var barWidth:Number = width * (this.currentValue / this.maxValue);

			TweenLite.to(currentBar, speed, {'width': barWidth});
		}

		private function init(images:Array, swapChild:Boolean):void
		{
			initBack(images[0]['image'], images[0]['X'], images[0]['Y']);
			initActive(images[1]['image'], images[1]['X'], images[1]['Y']);

			this.activeWidth = images[1]['width'];

			if (images.length > 2)
			{
				initSuper(images[2]['image'], images[2]['X'], images[2]['Y']);
				this.superWidth = images[2]['width'];
			}

			setValues(0, 1, 0);
			this.activeX = images[1]['X'];

			if (swapChild)
				addChild(this.backBar);
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

		private function initSuper(image:DisplayObject, imageX:int, imageY:int):void
		{
			this.superBar = image;
			this.superBar.x = imageX;
			this.superBar.y = imageY;
			this.superBar.visible = false;
			addChild(this.superBar);
		}
	}
}