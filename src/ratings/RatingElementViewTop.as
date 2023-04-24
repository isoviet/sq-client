package ratings
{
	import flash.display.DisplayObject;

	import game.gameData.RatingManager;

	public class RatingElementViewTop extends RatingElementView
	{
		static private const IMAGES:Array = [RatingGoldPlace, RatingSilverPlace, RatingBronzePlace];
		static private const TIME_UPDATE:int = 30;

		private var imagePlace:DisplayObject = null;

		public function RatingElementViewTop(type:int, id:int)
		{
			super(type, id);
		}

		override public function set place(value:int):void
		{
			super.place = value;

			RatingManager.setPlayerTopPlace(this.id, value + 1);

			if (this.imagePlace)
				removeChild(this.imagePlace);
			this.imagePlace = null;
			if (value >= IMAGES.length)
				return;
			this.imagePlace = new IMAGES[value]();
			this.imagePlace.x = 2;
			addChildAt(this.imagePlace, 1);
		}

		override protected function get timeUpdate():int
		{
			return TIME_UPDATE;
		}

		override protected function eventDelta(value:int):void
		{}
	}
}