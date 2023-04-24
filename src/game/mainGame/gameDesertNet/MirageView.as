package game.mainGame.gameDesertNet
{
	import flash.events.Event;
	import flash.filters.GlowFilter;

	import game.gameData.CollectionsData;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class MirageView extends StarlingAdapterSprite
	{
		static private const DISAPPEAR_FRAME:int = 25;

		private var itemImage:StarlingAdapterSprite = null;
		private var mirage:StarlingAdapterMovie = null;
		private var onComplete:Function = null;

		public function MirageView(itemId:int, onComplete:Function = null):void
		{
			this.onComplete = onComplete;

			var iconClass:Class = CollectionsData.getIconClass(itemId);
			this.itemImage = new StarlingAdapterSprite(new iconClass());
			this.itemImage.scaleXY(0.5);
			this.itemImage.filters = [new GlowFilter(0xFFCC33, 1, 4, 4, 3.08)];
			addChildStarling(this.itemImage);

			this.mirage = new StarlingAdapterMovie(new MirageClip());
			this.mirage.x = int(this.itemImage.width / 2);
			this.mirage.y = int(this.itemImage.height / 2);
			this.mirage.addEventListener(Event.ENTER_FRAME, onFrame);
			addChildStarling(this.mirage);
			this.mirage.play();
		}

		public function dispose():void
		{
			this.mirage.removeEventListener(Event.ENTER_FRAME, onFrame);
			this.mirage.stop();

			if (this.parent)
				this.parent.removeChild(this);

			this.removeFromParent();
		}

		private function onFrame(e:Event):void
		{
			if (this.mirage.currentFrame < DISAPPEAR_FRAME)
				this.itemImage.alpha -= (1 / DISAPPEAR_FRAME);
			else if (this.mirage.currentFrame == DISAPPEAR_FRAME)
				this.itemImage.alpha = 0;

			if (this.mirage.currentFrame == (this.mirage.totalFrames - 1))
			{
				dispose();

				if (this.onComplete != null)
					this.onComplete();
			}
		}
	}
}