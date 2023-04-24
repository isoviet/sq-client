package views
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import com.greensock.TweenMax;

	public class GameBonusImageView extends Sprite
	{
		private var bitmapData:BitmapData;

		public function GameBonusImageView(image:DisplayObject, fromX:int, fromY:int, toX:int = -1, toY:int = -1, time:Number = 0.7):void
		{
			super();

			var sprite:Sprite = new Sprite();
			image.x = 3;
			image.y = 3;
			sprite.addChild(image);

			this.bitmapData = new BitmapData(sprite.width + 8, sprite.height + 6, true, 0x00000000);
			this.bitmapData.draw(sprite);

			var imageBitmap:Bitmap = new Bitmap(bitmapData);
			addChild(imageBitmap);

			this.x = fromX;
			this.y = fromY;

			var self:GameBonusImageView = this;

			TweenMax.to(self, time, {'y': self.y - 100, 'onComplete': function():void
			{
				if (toX < 0)
					TweenMax.to(self, 1, {'alpha': 0, 'onComplete': dispose});
				else
					TweenMax.to(self, 0.6, {'onComplete': function():void
					{
						TweenMax.to(self, 0.8, {'x': toX, 'y': toY, 'onComplete': dispose});
					}});
			}});
		}

		private function dispose():void
		{
			if (this.bitmapData != null)
			{
				this.bitmapData.dispose();
				this.bitmapData = null;
			}

			if (this.parent == null)
				return;
			if (!this.parent.contains(this))
				return;
			this.parent.removeChild(this);
		}
	}
}