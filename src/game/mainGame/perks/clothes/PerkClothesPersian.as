package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import game.gameData.OutfitData;

	public class PerkClothesPersian extends PerkClothes implements ITransformation
	{
		private var view:MovieClip = null;
		private var changedClothes:Boolean = false;

		public function PerkClothesPersian(hero:Hero):void
		{
			super(hero);

			this.view = new PersianTransformation();
			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override public function dispose():void
		{
			super.dispose();

			stopView();
		}

		override protected function activate():void
		{
			super.activate();

			this.view.addEventListener("Transform", transformHero);
			this.view.addEventListener(Event.CHANGE, onTransformEnd);
			this.view.gotoAndPlay(0);
			this.hero.addView(this.view, true);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;

			this.hero.persian = false;
			this.hero.heroView.hidePerkAnimationPermanent();

			if (this.view.isPlaying)
				this.hero.changeView();

			stopView();

			if (this.changedClothes)
				this.hero.heroView.setClothing(this.hero.player['weared_packages'], this.hero.player['weared_accessories']);
			this.changedClothes = false;
		}

		protected function get rockClothes():Array
		{
			return [OutfitData.PERSIAN_MAN_ROCK];
		}

		private function transformHero(e:Event):void
		{
			this.view.removeEventListener("Transform", transformHero);

			this.hero.heroView.setClothing(this.rockClothes);
			this.hero.persian = true;
			this.changedClothes = true;

			this.hero.heroView.showPerkAnimationPermanent(new SpikesProofButton);
		}

		private function onTransformEnd(e:Event):void
		{
			this.view.removeEventListener(Event.CHANGE, onTransformEnd);
			this.hero.changeView();
		}

		private function stopView():void
		{
			if (!this.view.isPlaying)
				return;

			this.view.stop();
			this.view.removeEventListener("Transform", transformHero);
			this.view.removeEventListener(Event.CHANGE, onTransformEnd);
		}
	}
}