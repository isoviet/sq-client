package game.mainGame.perks.clothes
{
	import flash.events.Event;

	import game.mainGame.perks.clothes.base.PerkClothesExplode;

	import utils.starling.StarlingAdapterMovie;

	public class PerkClothesTor extends PerkClothesExplode

	{
		public function PerkClothesTor(hero:Hero):void
		{
			super(hero);

			this.activateSound = "grom";
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function get power():Number
		{
			return 50;
		}

		override protected function get radius():Number
		{
			return 15;
		}

		override protected function createView():void
		{
			this.view = new StarlingAdapterMovie(new TorPerkView);
			this.view.addEventListener(Event.ENTER_FRAME, onFrame);
			this.view.play();
			this.view.x = this.hero.x;
			this.view.y = this.hero.y + 20;
			this.hero.game.map._foregroundObjects.addChildStarling(this.view);
		}

		override public function dispose():void
		{
			if (this.view)
			{
				this.view.removeFromParent();
				this.view.removeEventListener(Event.ENTER_FRAME, onFrame);
				this.view = null;
			}

			super.dispose();
		}

		private function onFrame(e:Event):void
		{
			if (!this.hero || !this.hero.game || !this.hero.game.map)
				return;
			if (!this.view)
				return;
			if (this.view.currentFrame >= 13)
				explode();
			if (this.view.currentFrame < 43)
				return;
			this.view.stop();
			this.hero.game.map._foregroundObjects.removeChildStarling(this.view);
		}
	}
}