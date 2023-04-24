package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class PerkClothesArmadillo extends PerkClothes implements ITransformation
	{
		private var transformIn:MovieClip;
		private var transformOut:MovieClip;

		private var transform:Boolean = false;

		private var alternativeView:AlternativeView;

		public function PerkClothesArmadillo(hero:Hero):void
		{
			super(hero);

			this.soundOnlyHimself = true;
			this.activateSound = SOUND_ACTIVATE;

			this.transformIn = new ArmadilloTransformIn();
			this.transformIn.addFrameScript(this.transformIn.totalFrames - 1, function():void
			{
				transformIn.dispatchEvent(new Event(Event.CHANGE));
				transformIn.stop();
			});
			this.transformOut = new ArmadilloTransformOut();
			this.transformOut.addFrameScript(this.transformOut.totalFrames - 1, function():void
			{
				transformOut.dispatchEvent(new Event(Event.CHANGE));
				transformOut.stop();
			});

			this.transform = false;
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.running) && !(this.hero.heroView.fly);
		}

		override protected function activate():void
		{
			if (this.transform)
			{
				this.deactivate();
				return;
			}

			if ((this.hero.heroView.running) || (this.hero.heroView.fly))
				return;

			super.activate();
			this.alternativeView = new AlternativeView(["ArmadilloBallRunView", "ArmadilloBallStandView"]);

			this.hero.changeView(this.transformIn, true);
			this.transformIn.addEventListener(Event.CHANGE, onTransformIn);
			this.transformIn.gotoAndPlay(1);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.changeView(this.transformOut, true);
			this.transformOut.gotoAndPlay(1);
			this.transformOut.addEventListener(Event.CHANGE, onTransformOut);
		}

		private function onTransformIn(e:Event):void
		{
			this.transformIn.removeEventListener(Event.CHANGE, onTransformIn);
			this.transformIn.gotoAndStop(1);

			if (this.hero.heroView.shaman)
				return;
			this.hero.changeView(this.alternativeView);
			this.transform = true;
			this.hero.armadillo = true;
		}

		private function onTransformOut(e:Event):void
		{
			if (!this.hero)
				return;
			this.transformOut.removeEventListener(Event.CHANGE, onTransformOut);
			this.transformOut.gotoAndStop(1);

			this.hero.changeView();
			this.transform = false;
			this.hero.armadillo = false;
		}
	}
}