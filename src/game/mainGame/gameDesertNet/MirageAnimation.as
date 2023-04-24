package game.mainGame.gameDesertNet
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.entity.simple.CollectionElement;

	import utils.starling.StarlingAdapterSprite;

	public class MirageAnimation extends StarlingAdapterSprite
	{
		static private const DURATION:int = 1500;

		private var delayTimer:Timer = null;

		private var itemId:int = -1;
		private var hero:Hero = null;

		private var mirageView:MirageView = null;

		public function MirageAnimation():void
		{
			this.delayTimer = new Timer(DURATION, 1);
			this.delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, playAnimation);
		}

		public function startAnimation(hero:Hero, itemId:int):void
		{
			this.itemId = itemId;
			this.hero = hero;
			this.hero.heroView.showCollectionAnimation((itemId + 256) % 256, CollectionElement.KIND_COLLECTION, DURATION);

			this.delayTimer.reset();
			this.delayTimer.start();
		}

		public function dispose():void
		{
			this.hero = null;

			this.delayTimer.stop();
			this.delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, playAnimation);

			if (this.parent)
				this.parent.removeChild(this);

			this.removeFromParent();

			if (this.mirageView)
				this.mirageView.dispose();
		}

		private function playAnimation(e:TimerEvent):void
		{
			if (this.hero == null || this.hero.isDead || this.hero.inHollow || this.itemId == 0)
				return;

			this.mirageView = new MirageView(this.itemId);
			addChildStarling(this.mirageView);
		}
	}
}