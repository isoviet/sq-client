package game.mainGame.entity.editor
{
	import utils.starling.StarlingAdapterSprite;

	public class PlatformBridgeBody extends PartitionsPlatform
	{
		private var middleHeightBlock: Number = 0;

		public function PlatformBridgeBody():void
		{
			super();
			leftWidthBlock = new leftClass().width - 2;
			middleHeightBlock = new middleClass().height;
			draw();
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new Resin());
		}

		override protected function draw(): void {
			while (middleSprite.numChildren > 0) {
				middleSprite.getChildStarlingAt(0).removeFromParent(true);
				middleSprite.removeChildStarlingAt(0);
			}

			while (this.placeSprite.numChildren > 0) {
				this.placeSprite.removeChildStarlingAt(0, true);
			}

			var len: int = Math.round((this._width - this.leftWidthBlock) / this.middleWidthBlock) - 2;
			for (var i:int = 0; i < len; i++)
			{
				var newMiddle: StarlingAdapterSprite = new StarlingAdapterSprite(new middleClass());
				newMiddle.x = i * newMiddle.width;
				middleSprite.addChildStarling(newMiddle);
			}

			middleSprite.x = this.leftWidthBlock;

			if (middleSprite.width && middleSprite.height)
				this.placeSprite.addChildStarling(middleSprite);

			rightClassStarling.x = middleSprite.x + middleSprite.width;

			initDoubleClick();

			middleSprite.y = middleHeightBlock + 1;
			swampSprite.y = -middleHeightBlock;
		}

		override protected function initPlatformBD():void
		{
			this.platform = new Resin();
		}

		override protected function get leftClass():Class
		{
			return BridgeLeft;
		}

		override protected function get middleClass():Class
		{
			return BridgeMiddle;
		}

		override protected function get rightClass():Class
		{
			return BridgeRight;
		}
	}
}