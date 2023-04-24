package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;

	public class VIPBonusView extends Sprite
	{
		private var view:MovieClip = null;
		private var destination:Point = null;
		private var onComplete:Function = null;

		public function VIPBonusView(from:Point, to:Point, onComplete:Function):void
		{
			this.destination = to;
			this.onComplete = onComplete;

			this.view = new SubscriptionBonus();
			this.view.x = from.x;
			this.view.y = from.y;
			this.view.addEventListener(Event.CHANGE, tweenTo);
			this.view.gotoAndPlay(0);
			addChild(this.view);
		}

		private function tweenTo(e:Event):void
		{
			this.view.removeEventListener(Event.CHANGE, tweenTo);

			TweenMax.to(this.view, 0.7, {'scaleX': 0.2, 'scaleY': 0.2, 'x': this.destination.x, 'y': this.destination.y, 'ease': Expo.easeInOut, 'onComplete': function():void {
				TweenMax.to(view, 0.3, {'alpha': 0, 'scaleX': 0.3, 'scaleY': 0.3, 'onComplete': finishTween});
			}});
		}

		private function finishTween():void
		{
			if (this.parent)
				this.parent.removeChild(this);

			this.view = null;
			this.onComplete.call();
		}
	}
}