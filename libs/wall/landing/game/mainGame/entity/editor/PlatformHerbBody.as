package landing.game.mainGame.entity.editor
{
	import flash.display.BitmapData;

	import utils.ImageUtil;

	public class PlatformHerbBody extends PlatformGroundBody
	{
		private var herb:BitmapData = null;

		public function PlatformHerbBody():void
		{
			super();
		}

		override protected function initIcon():void
		{
			this.icon = new PlatformHerbIcon();
		}

		override protected function draw():void
		{
			super.draw();

			if (this.herb == null)
				this.herb = ImageUtil.getBitmapData(new Herb());

			this.drawSprite.graphics.beginBitmapFill(this.herb, null, true);
			this.drawSprite.graphics.drawRect(0, 0, this._width, this.herb.height);
			this.drawSprite.graphics.endFill();

			if (contains(this.icon))
				removeChild(this.icon);
		}
	}
}