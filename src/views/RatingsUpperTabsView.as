package views
{
	import flash.display.Sprite;

	import buttons.ButtonRatingTabsTape;

	public class RatingsUpperTabsView extends Sprite
	{
		public var ratingsButtons:ButtonRatingTabsTape = null;

		private var leftMargin:int;
		private var topMargin:int;
		private var offsetX:int;

		public function RatingsUpperTabsView(_leftMargin:int, _topMargin:int, _offsetX:int):void
		{
			super();

			this.leftMargin = _leftMargin;
			this.topMargin = _topMargin;
			this.offsetX = _offsetX;

			init();
		}

		public function setButton(_buttons:Array):void
		{
			this.ratingsButtons = new ButtonRatingTabsTape(_buttons.length, this.leftMargin, this.topMargin, this.offsetX);
			this.ratingsButtons.setData(_buttons);
			addChild(this.ratingsButtons);
		}

		private function init():void
		{
			addChild(new BottomRatingsLine);
		}
	}
}