package views.news
{
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;

	import views.GoldenCupBundle;
	import views.widgets.DiscountWidget;

	import utils.ColorMatrix;

	public class GoldenCupNewsView extends NewsPostBase
	{
		private var imageCap:Sprite = null;
		private var imageGoldenCup:Sprite = null;

		public function GoldenCupNewsView()
		{
			var view:Sprite = new Sprite();

			this.background = new GoldenCupNews();

			super();

			this.imageCap = new LeprechaunCap();
			this.imageGoldenCup = new GoldenCupBundle();
			this.imageCap.x = 250;
			this.imageCap.y = 20;
			this.imageGoldenCup.scaleX = this.imageGoldenCup.scaleY = 1.5;
			this.imageGoldenCup.x = 50;
			this.imageGoldenCup.y = 50;

			var matrix:ColorMatrix = new ColorMatrix();
			matrix.adjustColor(0, 0, 0, -20);

			var discountWidget:DiscountWidget = new DiscountWidget("", [new ColorMatrixFilter(matrix)]);
			discountWidget.scaleX = discountWidget.scaleY = 1.3;
			discountWidget.discount = 300;
			addChild(discountWidget);

			view.addChild(this.imageCap);
			view.addChild(this.imageGoldenCup);
			view.addChild(discountWidget);
			view.scaleX = view.scaleY = 1.1;
			view.x = 60;
			view.y = 70;

			addChild(view);
		}
	}
}