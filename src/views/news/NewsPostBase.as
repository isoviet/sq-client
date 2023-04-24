package views.news
{
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class NewsPostBase extends MovieClip
	{
		protected var background:Sprite = null;

		public function NewsPostBase()
		{
			if (!this.background)
				this.background = new Sprite();
			addChild(this.background);
		}
	}
}