package game
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	import com.greensock.TweenMax;

	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class FlyingObjectAnimation extends StarlingAdapterSprite
	{
		static private const DELTA_Y:int = 5;
		static private const TIME:int = 1.7;

		private var tween:TweenMax = null;

		public var object: * = null;

		public function FlyingObjectAnimation(object:DisplayObject):void
		{
			super();

			if (MovieClip(object).numChildren > 1)
				this.object = new StarlingAdapterMovie(object as MovieClip);
			else
				this.object = new StarlingAdapterSprite(object);

			this.addChildStarling(this.object);
		}

		public function play():void
		{
			reset();

			this.object.y = -DELTA_Y;

			ainmationDown();
		}

		public function stop():void
		{
			reset();

			this.object.y = -DELTA_Y;
		}

		public function get isPlaying():Boolean
		{
			return (this.tween != null);
		}

		public function reset(): void
		{
			if (this.tween == null)
				return;

			this.tween.kill();
			this.tween = null;
		}

		public function dispose():void
		{
			(this.object as IStarlingAdapter).removeFromParent();
			this.removeFromParent();
		}

		private function ainmationDown():void
		{
			this.tween = TweenMax.to(this.object, TIME, {'y': DELTA_Y, 'onComplete': ainmationUp});
		}

		private function ainmationUp():void
		{
			this.tween = TweenMax.to(this.object, TIME, {'y': -DELTA_Y, 'onComplete': ainmationDown});
		}
	}
}