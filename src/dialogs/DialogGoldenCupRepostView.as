package dialogs
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import buttons.ButtonBase;
	import views.GoldenCupBundle;
	import views.reposts.goldenCup.RepostGoldenCupBuy;

	import utils.WallTool;

	public class DialogGoldenCupRepostView extends Dialog
	{
		protected var buttonAction: ButtonBase = null;
		protected var imageCap: Sprite = null;
		protected var imageGoldenCup: Sprite = null;

		public function DialogGoldenCupRepostView():void
		{
			super(gls("Золото Лепрекона теперь твоё!"), false, true);

			init();
		}

		protected function init():void
		{
			var view:DialogGoldenCup = new DialogGoldenCup();
			addChild(view);

			this.imageCap = new LeprechaunCap();
			this.imageCap.x = 180;
			this.imageCap.y = 120;
			addChild(imageCap);

			this.imageGoldenCup = new GoldenCupBundle();
			this.imageGoldenCup.scaleX = imageGoldenCup.scaleY = 1.3;
			this.imageGoldenCup.x = 40;
			this.imageGoldenCup.y = 150;
			addChild(imageGoldenCup);

			place();
			this.height = 450;

			this.buttonAction = new ButtonBase(gls("Рассказать друзьям"), 170, 14, onRepost);
			this.buttonAction.x = int((this.width - buttonAction.width) * 0.5);
			this.buttonAction.y = this.height - buttonAction.height - 10;
			addChild(this.buttonAction);

			this.fieldCaption.y = 10;
			this.fieldCaption.setTextFormat(FORMAT_CAPTION_29_CENTER);
			this.fieldCaption.width -= this.buttonClose.width * 2;

			this.buttonClose.x = this.width - this.buttonClose.width * 1.5;
			this.buttonClose.y = this.buttonClose.height * 0.5;
			this.fieldCaption.x += 20;
		}

		override public function placeInCenter(sceneWidth:Number = Config.GAME_WIDTH, sceneHeight:Number = Config.GAME_HEIGHT):void
		{
			super.placeInCenter(sceneWidth, sceneHeight);
			this.y = int((sceneHeight - this.height) / 2);
		}

		private function onRepost(e:MouseEvent):void
		{
			var repost:RepostGoldenCupBuy = new RepostGoldenCupBuy();

			NewsImageGenerator.save(repost.bitmapData, "golden_cup", false);

			WallTool.place(Game.self, WallTool.WALL_GOLDEN_CUP, repost.id, new Bitmap(repost.bitmapData), repost.caption);
			hide();
		}

		override public function get captured():Boolean
		{
			return true;
		}
	}
}