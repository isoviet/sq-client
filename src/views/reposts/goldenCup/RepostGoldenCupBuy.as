package views.reposts.goldenCup
{
	import flash.display.Sprite;

	import views.GoldenCupBundle;
	import views.reposts.RepostView;

	public class RepostGoldenCupBuy extends RepostView
	{
		private var imageGoldenCup:GoldenCupBundle = null;
		private var imageCap:Sprite = null;

		public function RepostGoldenCupBuy()
		{
			super();
		}

		override protected function configurateView():void
		{
			this.background = new GoldenCupDailyRepost();

			this.imageGoldenCup = new GoldenCupBundle();
			this.imageGoldenCup.removeFlagView();
			this.imageGoldenCup.x = this.background.width / 2 - this.imageGoldenCup.width / 2 - 40;
			this.imageGoldenCup.y = this.background.height / 2 - this.imageGoldenCup.height / 2;

			this.imageCap = new LeprechaunCap();
			this.imageCap.x = this.background.width / 2 - this.imageCap.width / 2 + 70;
			this.imageCap.y = this.imageGoldenCup.y - 20;
			this.imageCap.scaleX = this.imageCap.scaleY = 0.8;

			this.caption = gls("Богатства Лепрекона стали моими!");

			super.configurateView();
			addChild(this.imageCap);
			addChild(this.imageGoldenCup);
		}

		override public function get id():int
		{
			return 1;
		}
	}
}