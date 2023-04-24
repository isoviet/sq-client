package game
{
	import flash.display.Sprite;

	import com.greensock.TweenMax;

	import starling.core.Starling;

	public class NewYearFreezeAnimation extends Sprite
	{
		private var view:NewYearFreezeView;
		private var active:Boolean = false;
		private var tween:TweenMax = null;

		public function NewYearFreezeAnimation():void
		{
			this.view = new NewYearFreezeView();
			this.view.height = Starling.current.stage.stageHeight;
			this.view.width = Starling.current.stage.stageWidth;
			addChild(this.view);

			this.mouseEnabled = false;
			this.mouseChildren = false;
		}

		public function dispose():void
		{
			if (this.tween)
				this.tween.kill();
			onEnd();
		}

		public function start():void
		{
			if (this.active)
				return;
			this.active = true;

			if (!Game.gameSprite.contains(this))
				Game.gameSprite.addChild(this);
			this.alpha = 0;
			if (this.tween)
				this.tween.kill();
			this.tween = TweenMax.to(this, 1.0, {'alpha': 0.7});
		}

		public function stop():void
		{
			if (!this.active)
				return;
			this.active = false;
			if (this.tween)
				this.tween.kill();
			this.tween = TweenMax.to(this, 1.0, {'alpha': 0.0, 'onComplete': onEnd});
		}

		private function onEnd():void
		{
			if (Game.gameSprite.contains(this))
				Game.gameSprite.removeChild(this);
		}
	}
}