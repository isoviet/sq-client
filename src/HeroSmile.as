package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import views.EmotionBarView;

	import utils.Animation;

	public class HeroSmile extends Sprite
	{
		private var smiles:Object = {};
		private var currentEmotionAnimation:Animation = null;

		public function HeroSmile():void
		{
			super();
		}

		public function dispose():void
		{}

		public function set emotion(type:int):void
		{
			if (!(type in this.smiles))
			{
				if (type >= Hero.EMOTION_MAX_TYPE)
				{
					var obj:Object = EmotionBarView.emotionButtons[type - Hero.EMOTION_MAX_TYPE];
					var r:MovieClip = new obj['btn'];
					r.scaleX = r.scaleY = 1.2;

					this.smiles[type] = new Animation(r);
					this.smiles[type].x = -17;
					this.smiles[type].y = -32 + ("shift" in obj ? obj['shift'] : 0);
				}
			}

			this.currentEmotionAnimation = this.smiles[type];

			addChild(this.currentEmotionAnimation);
			this.visible = true;

			this.currentEmotionAnimation.speed = 0.5;
			this.currentEmotionAnimation.addFrameScript(this.currentEmotionAnimation.totalFrames-1, remove);
			this.currentEmotionAnimation.gotoAndPlay(0);
		}

		public function remove():void
		{
			if (!this.visible)
				return;

			this.visible = false;
			this.alpha = 1;

			if (this.currentEmotionAnimation == null)
				return;

			this.currentEmotionAnimation.stop();

			if (contains(this.currentEmotionAnimation))
				removeChild(this.currentEmotionAnimation);

			this.currentEmotionAnimation = null;
		}
	}
}