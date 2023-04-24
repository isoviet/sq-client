package game.mainGame.gameBattleNet
{
	import flash.display.Sprite;
	import flash.events.Event;

	import utils.Animation;

	public class DamageView extends Sprite
	{
		private var movie:Animation = new Animation(new DamageMovie());

		public function DamageView():void
		{
			this.movie.loop = false;
			addChild(this.movie);
			this.visible = false;
		}

		public function play():void
		{
			this.visible = true;
			if (!this.movie.isPlaying)
				this.movie.addEventListener("Complete", dispose);
			this.movie.gotoAndPlay(0);
		}

		private function dispose(e:Event):void
		{
			this.movie.removeEventListener("Complete", dispose);
			this.visible = false;
		}
	}
}