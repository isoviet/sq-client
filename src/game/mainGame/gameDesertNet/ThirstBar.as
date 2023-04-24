package game.mainGame.gameDesertNet
{
	import flash.display.DisplayObject;

	import com.greensock.TweenMax;

	import utils.starling.StarlingAdapterSprite;

	public class ThirstBar extends StarlingAdapterSprite
	{
		static private const DROPS_COUNT:int = 5;

		private var currentState:int = 0;

		private var redSprite:StarlingAdapterSprite = null;

		public function ThirstBar():void
		{
			super();

			this.redSprite = new StarlingAdapterSprite();
		}

		public function update(value:int, maxValue:int):void
		{
			var stepsCount:int = maxValue / (DROPS_COUNT * 2);
			var dropsCount:int = value / stepsCount;

			if (this.currentState == dropsCount)
				return;

			this.currentState = dropsCount;

			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			while (this.redSprite.numChildren > 0)
				this.redSprite.removeChildStarlingAt(0);

			addChildStarling(this.redSprite);

			for (var i:int = 0; i < int((this.currentState + 1) / 2); i++)
			{
				var image:DisplayObject;

				if ((this.currentState - i * 2) == 1)
				{
					image = new StarlingAdapterSprite(new DropSmall());
					addChildStarling(image);
					image.y = 3;
				}
				else
				{
					image = new StarlingAdapterSprite(new DropBig());
					this.redSprite.addChildStarling(image);
				}

				image.x = 12 * i;
			}

			if ((this.currentState % 2) == 0 || this.currentState == 1)
				return;

			TweenMax.to(this.redSprite, 0.3, {'colorMatrixFilter': {'hue': 145, 'contrast': 1.4, 'saturation': 2}, 'onComplete': onCompleteTween});
		}

		private function onCompleteTween():void
		{
			TweenMax.to(this.redSprite, 0.3, {'delay': 0.3, 'colorMatrixFilter': {'hue': 0, 'contrast': 1, 'saturation': 1}});
		}
	}
}