package dialogs.collections
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import game.gameData.CollectionsData;
	import views.CollectionPostView;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.StageQualityUtil;
	import utils.WallTool;

	public class DialogCollectionSelfPost extends Dialog
	{
		static private const FRAME_WIDTH:int = 111;

		private var elementId:int = -1;

		private var icon:DisplayObject = null;
		private var tittleField:GameField = null;

		public function DialogCollectionSelfPost():void
		{
			super(gls("Я готов обменять"));

			init();
		}

		override public function show():void
		{
			super.show();

			Connection.sendData(PacketClient.COUNT, PacketClient.CAN_REPOST, Game.self['type']);
		}

		public function set iconId(elementId:int):void
		{
			this.elementId = elementId;

			if (this.icon != null)
				removeChild(this.icon);

			this.tittleField.wordWrap = false;
			this.tittleField.text = CollectionsData.regularData[this.elementId]['tittle'];
			this.tittleField.y = 13;

			if (this.tittleField.textWidth > 220)
			{
				this.tittleField.wordWrap = true;
				this.tittleField.y = -4;
			}

			var iconClass:Class = CollectionsData.getIconClass(this.elementId);
			this.icon = new iconClass();
			this.icon.scaleX = icon.scaleY = 1.3;
			this.icon.x = 49 + 24 + int((FRAME_WIDTH - icon.width) / 2);
			this.icon.y = 43 + 23 + int((FRAME_WIDTH - icon.height) / 2);
			addChild(this.icon);
		}

		private function init():void
		{
			var format:TextFormat = new TextFormat(null, 18, 0x5E9A2C, true);
			format.align = TextFormatAlign.CENTER;

			this.tittleField = new GameField("", 20, 13, format);
			this.tittleField.width = 220;
			this.tittleField.multiline = true;
			this.tittleField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.tittleField);

			var background:CollectionFrameImage = new CollectionFrameImage();
			background.x = 49;
			background.y = 43;
			addChild(background);

			var button:ButtonBase = new ButtonBase(gls("Поделиться"));
			button.x = 70;
			button.y = 230;
			button.addEventListener(MouseEvent.CLICK, onPost);

			place(button);

			this.width = 290;
			this.height = 290;
		}

		private function onPost(e:MouseEvent):void
		{
			if (!WallTool.canPost)
				return;

			var postImage:CollectionPostView = new CollectionPostView(CollectionsData.TYPE_REGULAR, this.elementId);

			var quality:String = Game.stage.quality;
			StageQualityUtil.toggleQuality(StageQuality.HIGH);

			var newBitmapData:BitmapData = new BitmapData(postImage.width, postImage.height);
			newBitmapData.draw(postImage);

			var iconBitmap:Bitmap = new Bitmap(newBitmapData);

			WallTool.place(Game.self, WallTool.WALL_COLLECTION_REGULAR, this.elementId, iconBitmap, gls("Я готов обменять «{0}» в игре Трагедия Белок", CollectionsData.regularData[this.elementId]['tittle']));

			StageQualityUtil.toggleQuality(quality);

			close();
		}
	}
}