package landing.game
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import events.MovieClipPlayCompleteEvent;

	import utils.Animation;

	public class ShamanAnimation extends SquirrelAnimationFactory
	{
		private var repeat:int = 4;
		private var count:int = 0;

		private var isShaman:Boolean;
		private var hasAcorn:Boolean;

		private var shamanAnimation:Animation;
		private var playerAnimation:Animation;

		public function ShamanAnimation(hasAcorn:Boolean):void
		{
			var movie:MovieClip = (hasAcorn ? new HeroShamanAcorn() : new HeroShaman());

			super(movie);

			this.isShaman = true;
			this.hasAcorn = hasAcorn;

			this.shamanAnimation = this.anime;
			this.animation.stop();
		}

		private function onEnterFrame(e:Event):void
		{
			if (this.count >= repeat)
				stop();

			if (this.animation.currentFrame != 11)
				return;

			this.count++;
			this.animation.gotoAndPlay(4);
		}

		override public function play():void
		{
			this.count = 0;

			this.animation.gotoAndStop(0);
			this.animation.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.animation.play();
		}

		override public function stop():void
		{
			this.animation.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			this.animation.gotoAndPlay(13);

			var event:MovieClipPlayCompleteEvent = new MovieClipPlayCompleteEvent(MovieClipPlayCompleteEvent.SHAMAN);
			dispatchEvent(event);
		}

		public function toggleAnimationCasting(isShamanCasting:Boolean):void
		{
			if (this.isShaman == isShamanCasting)
				return;

			this.isShaman = isShamanCasting;

			removeChild(this.anime);

			if (this.isShaman)
			{
				this.anime = this.shamanAnimation;
				addChild(this.anime);
				return;
			}

			if (this.playerAnimation == null)
			{
				if (this.hasAcorn)
					this.playerAnimation = new Animation(new HeroCastAcorn());
				else
					this.playerAnimation = new Animation(new HeroCast());

				this.playerAnimation.x = STAND_OFFSET_X;
				this.playerAnimation.y = STAND_OFFSET_Y;
			}

			this.anime = this.playerAnimation;
			addChild(this.anime);
		}
	}
}