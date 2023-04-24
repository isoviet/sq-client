package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class PerkClothesTranfsform extends PerkClothes implements ITransformation
	{
		private var isTransform:Boolean = false;

		protected var transformIn:MovieClip = null;
		protected var transformOut:MovieClip = null;
		protected var transformView:MovieClip = null;

		public function PerkClothesTranfsform(hero:Hero):void
		{
			super(hero);

			this.isTransform = false;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		protected function initMovies():void
		{}

		override protected function activate():void
		{
			super.activate();

			initMovies();

			if (this.isTransform || !this.hero)
				return;

			this.isTransform = true;

			this.hero.changeView(this.transformIn, true);
			this.transformIn.addEventListener(Event.CHANGE, onTransformIn);
			this.transformIn.gotoAndPlay(0);

			this.hero.jumpVelocity -= 9;
			this.hero.runSpeed *= 2.5;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;

			this.isTransform = false;

			this.hero.changeView(this.transformOut, true);
			this.transformOut.addEventListener(Event.CHANGE, onTransformOut);
			this.transformOut.gotoAndPlay(0);

			this.hero.jumpVelocity += 9;
			this.hero.runSpeed /= 2.5;
		}

		protected function onTransformIn(e:Event):void
		{
			this.transformIn.removeEventListener(Event.CHANGE, onTransformIn);
			this.transformIn.gotoAndStop(0);

			if (!this.hero)
				return;
			this.hero.changeView(this.transformView, true);
		}

		protected function onTransformOut(e:Event):void
		{
			this.transformOut.removeEventListener(Event.CHANGE, onTransformOut);
			this.transformOut.gotoAndStop(0);

			if (!this.hero)
				return;
			this.hero.changeView();
		}
	}
}