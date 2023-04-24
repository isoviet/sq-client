package landing.game
{
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import utils.Animation;

	public class SquirrelAnimationFactory extends Sprite
	{
		static private const RUN_OFFSET_X:int = -100;
		static private const RUN_OFFSET_Y:int = -80;

		static private const DEATH_OFFSET_X:int = -30;
		static private const DEATH_OFFSET_Y:int = -256;

		static protected const STAND_OFFSET_X:int = -85;
		static protected const STAND_OFFSET_Y:int = -80;

		static public const TYPE_STAND:int = 0;
		static public const TYPE_RUN:int = 1;
		static public const TYPE_DEATH:int = 1;

		protected var anime:Animation;

		public function SquirrelAnimationFactory(clip:MovieClip, type:int = TYPE_STAND):void
		{
			super();

			this.anime = new Animation();
			this.anime.buildCacheFromClip(clip);

			switch (type)
			{
				case TYPE_STAND:
					this.anime.x = STAND_OFFSET_X;
					this.anime.y = STAND_OFFSET_Y;
					break;
				case TYPE_RUN:
					this.anime.x = RUN_OFFSET_X;
					this.anime.y = RUN_OFFSET_Y;
					break;
				case TYPE_DEATH:
					this.anime.x = DEATH_OFFSET_X;
					this.anime.y = DEATH_OFFSET_Y;
					break;
			}

			addChild(this.anime);
		}

		public function get animation():Animation
		{
			return this.anime;
		}

		public function play():void
		{
			this.anime.play();
		}

		public function stop():void
		{
			this.anime.stop();
		}

		public function gotoAndStop(frame:Number):void
		{
			this.anime.gotoAndStop(frame);
		}

		public function gotoAndPlay(frame:Number):void
		{
			this.anime.gotoAndPlay(frame);
		}
	}
}