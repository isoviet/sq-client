package game.mainGame.entity.editor
{
	import flash.display.Sprite;

	import starling.display.QuadBatch;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class PlatformHerbBody extends PlatformGroundBody
	{
		private var herb: Sprite = null;
		private var quadBatchHerb: QuadBatch;

		public function PlatformHerbBody():void
		{
			super();
		}

		override public function setCover(cover:Cover):void
		{
		}

		override public function get landSound():String
		{
			return "land_grass";
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new PlatformHerb());
		}

		protected function get herbClass():Class
		{
			return Herb;
		}

		override protected function draw():void
		{
			super.draw();

			if (this.herb == null)
				this.herb = new this.herbClass();

			if (quadBatchHerb)
			{
				if (quadBatchHerb.texture)
					quadBatchHerb.texture.dispose();
				quadBatchHerb.reset();
				quadBatchHerb.dispose();
				quadBatchHerb.removeFromParent();
			}

			var img: starling.display.Sprite = StarlingConverter.imageWithTextureFill(this.herb, this._width, this.herb.height);
			this.addChildStarling(img);
		}
	}
}