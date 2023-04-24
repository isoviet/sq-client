package views.storage
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	import game.gameData.CollectionsData;

	import com.greensock.TweenMax;

	public class CollectionAssembleHideEffect extends Sprite
	{
		public function CollectionAssembleHideEffect(id:int):void
		{
			var iconClass:Class = CollectionsData.getUniqueClass(id);
			var icon:DisplayObject = new iconClass();
			icon.scaleX = icon.scaleY = 0.51;
			addChild(icon);

			TweenMax.to(icon, 1, {'alpha': 0});

			var movie:CollectionAssembleHideMovie = new CollectionAssembleHideMovie();
			movie.scaleX = movie.scaleY = 1.4;
			movie.x = icon.width / 2;
			movie.y = icon.height / 2;
			movie.addEventListener(Event.COMPLETE, onComplete);
			addChild(movie);
		}

		private function onComplete(e:Event):void
		{
			if (!this.parent)
				return;

			this.parent.removeChild(this);
		}
	}
}