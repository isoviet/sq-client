package views
{
	import flash.events.Event;

	import utils.starling.StarlingAdapterSprite;

	public class SnowFlake extends StarlingAdapterSprite
	{
		private var dX:Number;
		private var dY:Number;

		private var windX:Number;
		private var deltaWindX:Number;
		private var deltaWindY:Number;

		private var snow:SnowView = null;

		public function SnowFlake(snow:SnowView, flake:StarlingAdapterSprite):void
		{
			super();

			this.snow = snow;

			init(flake);
		}

		private function init(flake:StarlingAdapterSprite):void
		{
			var snow:StarlingAdapterSprite = flake;
			snow.scaleX = snow.scaleY = 0.4 + Math.random() * 0.75;
			addChildStarling(snow);

			this.dX = Math.random() * 2 - Math.random() * 2;
			this.dY = 0.5 + snow.scaleX;

			this.deltaWindY = this.dY + this.scaleX * this.snow.windY;

			addEventListener(Event.ENTER_FRAME, move);
		}

		private function move(e:Event):void
		{
			if (this.windX != this.snow.windX)
			{
				this.windX = this.snow.windX;
				this.deltaWindX = this.dX + this.snow.windX * this.scaleX;
			}

			this.x += this.deltaWindX;
			this.y += this.deltaWindY;

			if (this.y < Config.GAME_HEIGHT)
				return;

			if (this.snow && this.snow.containsStarling(this))
				this.removeFromParent();

			this.snow = null;
			removeEventListener(Event.ENTER_FRAME, move);
		}
	}
}