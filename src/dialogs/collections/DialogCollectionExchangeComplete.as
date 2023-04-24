package dialogs.collections
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import game.gameData.CollectionsData;

	import com.adobe.images.PNGEncoder;
	import com.inspirit.MultipartURLLoader;

	import utils.LoaderUtil;
	import utils.StageQualityUtil;
	import utils.WallTool;

	public class DialogCollectionExchangeComplete extends Dialog
	{
		static private const SLOT_WIDTH:int = 102;
		static private const SMALL_SLOT_WIDTH:int = 68;
		static private const OFFSET_X:int = 15;

		private var itemId1:int = -1;
		private var itemId2:int = -1;

		private var bitmapData:BitmapData;

		public function DialogCollectionExchangeComplete(itemId1:int, itemId2:int, success:Boolean):void
		{
			super(success ? gls("Обмен совершён успешно") : gls("При обмене возникла ошибка"));

			this.itemId1 = itemId1;
			this.itemId2 = itemId2;

			init(success);
		}

		private function init(success:Boolean):void
		{
			var slot:ElementSlotBack = new ElementSlotBack();
			slot.x = OFFSET_X;
			slot.y = 17;
			slot.width = slot.height = 102;
			addChild(slot);

			slot = new ElementSlotBack();
			slot.x = OFFSET_X + 166;
			slot.y = 17;
			slot.width = slot.height = 102;
			addChild(slot);

			var iconClass:Class = CollectionsData.getIconClass(this.itemId1);
			var icon:DisplayObject = new iconClass();
			icon.x = OFFSET_X + int((SLOT_WIDTH - icon.width) * 0.5);
			icon.y = 17 + int((SLOT_WIDTH - icon.height) * 0.5);
			addChild(icon);

			iconClass = CollectionsData.getIconClass(this.itemId2);
			icon = new iconClass();
			icon.x = OFFSET_X + 166 + int((SLOT_WIDTH - icon.width) * 0.5);
			icon.y = 17 + int((SLOT_WIDTH - icon.height) * 0.5);
			addChild(icon);

			if (success)
			{
				var successView:ExchangeSuccessView = new ExchangeSuccessView();
				successView.x = OFFSET_X + 116;
				successView.y = 44;
				addChild(successView);

				if (Game.self.type != Config.API_SA_ID)
				{
					var buttonShare:ButtonBase = new ButtonBase(gls("Поделиться"));
					buttonShare.x = successView.x + int((successView.width - buttonShare.width) * 0.5);
					buttonShare.y = 130;
					buttonShare.addEventListener(MouseEvent.CLICK, onPost);
					addChild(buttonShare);
				}
			}
			else
			{
				var failView:ExchangeFailImage = new ExchangeFailImage();
				failView.x = OFFSET_X + 116;
				failView.y = 44;
				addChild(failView);
			}

			place();

			this.width = 335;
			this.height = ((success && (Game.self.type != Config.API_SA_ID)) ? 210 : 200);
		}

		private function onPost(e:MouseEvent):void
		{
			var postImage:ExchangePostView = new ExchangePostView();

			var field:GameField = new GameField(gls("Я обменялся!"), 0, 20, new TextFormat(GameField.PLAKAT_FONT, 20, 0x503816));
			field.x = int((postImage.width - field.textWidth) * 0.5);
			field.filters = [new DropShadowFilter(1, 45, 0xFFFFFF, 1, 2, 2, 8)];
			postImage.addChild(field);

			var iconClass:Class = CollectionsData.getIconClass(this.itemId1);
			var icon1:DisplayObject = new iconClass();
			icon1.scaleX = icon1.scaleY = 0.75;
			icon1.x = 31 + int((SMALL_SLOT_WIDTH - icon1.width) / 2);
			icon1.y = 105 + int((SMALL_SLOT_WIDTH - icon1.height) / 2);
			postImage.addChild(icon1);

			iconClass = CollectionsData.getIconClass(this.itemId2);
			var icon2:DisplayObject = new iconClass();
			icon2.scaleX = icon2.scaleY = 0.75;
			icon2.x = 172 + int((SMALL_SLOT_WIDTH - icon2.width) / 2);
			icon2.y = 105 + int((SMALL_SLOT_WIDTH - icon2.height) / 2);
			postImage.addChild(icon2);

			var quality:String = Game.stage.quality;
			StageQualityUtil.toggleQuality(StageQuality.HIGH);

			if (this.bitmapData != null)
				this.bitmapData.dispose();
			this.bitmapData = new BitmapData(postImage.width, postImage.height);
			this.bitmapData.draw(postImage);

			if (Game.self.type == Config.API_VK_ID)
				WallTool.place(Game.self, WallTool.WALL_COLLECTION_EXCHANGE, 0, new Bitmap(this.bitmapData), gls("Я обменялся в игре Трагедия Белок"));
			else
				LoaderUtil.uploadFile(Config.SCREENSHOT_UPLOAD_URL, PNGEncoder.encode(this.bitmapData), {}, onUploadResultsComplete, onUploadError);

			StageQualityUtil.toggleQuality(quality);

			hide();
		}

		private function onUploadResultsComplete(e:Event):void
		{
			var newResultsURL:String = (e.currentTarget as MultipartURLLoader).loader.data;

			WallTool.place(Game.self, WallTool.WALL_COLLECTION_EXCHANGE, 10, new Bitmap(this.bitmapData), gls("Я обменялся в игре Трагедия Белок"), newResultsURL);
		}

		private function onUploadError(e:Event):void
		{
			Logger.add("Error on upload game results!");
		}
	}
}