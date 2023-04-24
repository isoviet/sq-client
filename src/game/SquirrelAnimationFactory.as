package game
{
	import flash.display.Sprite;
	import flash.geom.Point;

	import utils.Animation;

	public class SquirrelAnimationFactory extends Sprite
	{
		static private const RUN_OFFSET_X:int = -75;
		static private const RUN_OFFSET_Y:int = -80;

		static private const DEATH_OFFSET_X:int = -30;
		static private const DEATH_OFFSET_Y:int = -256;

		static private const FIRE_OFFSET_X:int = -108;
		static private const FIRE_OFFSET_Y:int = -105;

		static protected const STAND_OFFSET_X:int = -60;
		static protected const STAND_OFFSET_Y:int = -80;

		static protected const HARE_OFFSET_X:int = -85;
		static protected const HARE_OFFSET_Y:int = -90;

		static public const TYPE_STAND:int = 0;
		static public const TYPE_RUN:int = 1;
		static public const TYPE_DEATH:int = 1;
		static public const TYPE_HARE:int = 2;
		static public const TYPE_FIRE:int = 3;

		protected var anime:Animation = null;

		public function SquirrelAnimationFactory(clip:*, type:int = TYPE_STAND, rasterAll:Boolean = true, preraster:Boolean = false):void
		{
			super();

			if (clip == null || clip == "")
				return;

			this.anime = new Animation();
			this.anime.buildCacheFromClip(clip, rasterAll, preraster);

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
				case TYPE_HARE:
					this.anime.x = HARE_OFFSET_X;
					this.anime.y = HARE_OFFSET_Y;
					break;
				case TYPE_FIRE:
					this.anime.x = FIRE_OFFSET_X;
					this.anime.y = FIRE_OFFSET_Y;
					break;
			}

			addChild(this.anime);
		}

		public function remove():void
		{
			if (this.anime == null)
				return;
			this.anime.remove();
			this.anime = null;
		}

		public function get animation():Animation
		{
			return this.anime;
		}

		public function hitTest(point:Point):Boolean
		{
			return this.anime.hitTest(point);
		}

		public function play():void
		{
			if (this.anime == null)
				return;

			this.anime.play();
		}

		public function stop():void
		{
			if (this.anime == null)
				return;

			this.anime.stop();
		}

		public function gotoAndStop(frame:Number):void
		{
			if (this.anime == null)
				return;

			this.anime.gotoAndStop(frame);
		}

		public function gotoAndPlay(frame:Number):void
		{
			if (this.anime == null)
				return;

			this.anime.gotoAndPlay(frame);
		}
	}
}