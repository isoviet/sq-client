package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	import com.greensock.TweenMax;

	public class HeroMessage extends Sprite
	{
		private var messageField:TextField = new TextField();
		private var triangle:DisplayObject = null;

		private var messageTimer:Timer = new Timer(5000, 1);

		private var tween:TweenMax = null;

		public var offsetY:int = HeroView.HERO_TOP;

		public function HeroMessage():void
		{
			super();

			init();
		}

		private function init():void
		{
			this.messageField.x = 0;
			this.messageField.y = 0;
			this.messageField.mouseEnabled = false;
			this.messageField.wordWrap = true;
			this.messageField.multiline = true;
			this.messageField.width = 120;
			this.messageField.embedFonts = true;
			this.messageField.defaultTextFormat = new TextFormat(GameField.DEFAULT_FONT, 11);
			addChild(this.messageField);

			this.messageTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteMessage);

			this.triangle = new MessageTriangle();
			addChild(this.triangle);

			this.visible = false;
		}

		public function setText(value:String, duration:int = 5000):void
		{
			if (this.tween != null)
			{
				this.tween.kill();
				this.tween = null;
			}

			this.messageField.htmlText = value;

			redraw();

			if (duration == 0)
				return;

			this.messageTimer.delay = duration;
			this.messageTimer.reset();
			this.messageTimer.start();
		}

		public function remove():void
		{
			this.visible = false;
			this.messageTimer.stop();
		}

		public function dispose():void
		{
			this.messageTimer.stop();
			this.messageTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onCompleteMessage);

			if (this.tween != null)
			{
				this.tween.kill();
				this.tween = null;
			}
		}

		private function redraw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF, 0.7);
			this.graphics.drawRoundRectComplex(this.messageField.x - 3, this.messageField.y, this.messageField.textWidth + 10, this.messageField.textHeight + 5, 5, 5, 5, 5);
			this.graphics.endFill();

			this.triangle.x = this.messageField.x - 3 + int((this.messageField.textWidth + 10) / 2);
			this.triangle.y = this.messageField.y + this.messageField.textHeight + 5;

			if (scaleX > 0)
				this.x = -int(this.messageField.textWidth / 2);
			else
				this.x = int((this.messageField.textWidth) / 2);

			this.y = -int(this.messageField.textHeight) + this.offsetY;

			this.visible = true;
			this.alpha = 1;
		}

		private function onCompleteMessage(e:TimerEvent):void
		{
			this.tween = TweenMax.to(this, 1, {'alpha': 0, 'onComplete': remove});
		}
	}
}