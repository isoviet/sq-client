package dialogs
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	import fl.controls.CheckBox;

	import buttons.ButtonBase;
	import chat.ChatDeadServiceMessage;
	import screens.ScreenGame;
	import screens.Screens;

	import by.blooddy.crypto.image.PNGEncoder;

	import com.api.Services;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.TextFieldUtil;
	import utils.starling.utils.StarlingConverter;

	public class DialogScreenshot extends Dialog
	{
		static private const IMAGERECT:Rectangle = new Rectangle(6, 6, 900, 620);
		static private const MATRIX:Matrix = new Matrix(1, 0, 0, 1, 6, 6);
		static private const MATRIX_LOGO:Matrix = new Matrix(0.7, 0, 0, 0.7, 725, 13);
		static private const FRAME:DisplayObject = new DialogScreenshotFrame();
		static private var LOGO:DisplayObject = null;

		static private var _instance:DialogScreenshot = null;

		private var checkBox:CheckBox = new CheckBox();
		private var image:Bitmap = new Bitmap();
		private var bitmapData:BitmapData = new BitmapData(912, 632, false);
		private var fileReference:FileReference = new FileReference();

		private var buttonPost:ButtonBase = null;
		private var buttonSave:ButtonBase = null;

		public function DialogScreenshot():void
		{
			super(gls("Опубликовать снимок"));

			this.image.x = 35;
			this.image.y = 10;
			this.image.scaleX = 0.5;
			this.image.scaleY = 0.5;
			addChild(this.image);

			TextFieldUtil.setStyleCheckBox(this.checkBox);
			this.checkBox.selected = false;
			this.checkBox.x = 35;
			this.checkBox.y = 335;
			this.checkBox.label = gls("Публиковать без подтверждения");
			this.checkBox.width = 400;
			addChild(this.checkBox);

			this.buttonPost = new ButtonBase(gls("Опубликовать"));
			this.buttonPost.x = 25;
			this.buttonPost.y = 360;
			this.buttonPost.addEventListener(MouseEvent.CLICK, savePhoto);
			addChild(this.buttonPost);

			this.buttonSave = new ButtonBase(gls("Сохранить на компьютере"));
			this.buttonSave.x = 505 - this.buttonSave.width;
			this.buttonSave.y = 360;
			this.buttonSave.addEventListener(MouseEvent.CLICK, saveLocal);
			addChild(this.buttonSave);

			place();

			this.sound = "camera";
		}

		static public function show():void
		{
			if (_instance == null)
				_instance = new DialogScreenshot();

			_instance.show();
		}

		override public function show():void
		{
			if (this.visible)
				return;

			createImage();

			if (Game.quickPhoto)
			{
				savePhoto();
				return;
			}

			this.width = 555;
			this.height = 450;

			super.show();

			if (Services.photos != null)
				return;

			this.buttonPost.visible = false;
			this.buttonSave.x = int((this.width - this.leftOffset - this.rightOffset - this.buttonSave.width) * 0.5);
			this.checkBox.visible = false;
		}

		override public function hide(e:MouseEvent = null):void
		{
			Game.quickPhoto = this.checkBox.selected;
			super.hide();
		}

		private function createImage():void
		{
			if(!Game.gameSprite || !this.bitmapData || !this.image)
				return;

			var mask:* = Game.gameSprite.mask;
			Game.gameSprite.mask = null;

			this.bitmapData.draw(StarlingConverter.getScreenShot(), MATRIX, null, null, IMAGERECT);
			this.bitmapData.draw(Game.gameSprite, MATRIX, null, null, IMAGERECT);

			Game.gameSprite.mask = mask;

			this.bitmapData.draw(FRAME);
			if (LOGO == null)
				LOGO = PreLoader.getLogo();
			this.bitmapData.draw(LOGO, MATRIX_LOGO);

			this.image.bitmapData = bitmapData;
		}

		private function savePhoto(e:MouseEvent = null):void
		{
			if (Services.photos == null)
			{
				hide();
				return;
			}

			Services.photos.savePhoto(this.bitmapData);
			Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.SCREEN_POST, 1);

			if (Screens.active is ScreenGame)
				ScreenGame.sendMessage(Game.selfId, "", ChatDeadServiceMessage.SNAPSHOT);

			hide();
		}

		private function saveLocal(e:MouseEvent):void
		{
			FullScreenManager.instance().fullScreen = false;

			var data:ByteArray = PNGEncoder.encode(this.bitmapData);
			var date:Date = new Date();
			var name:String = "Screenshot" + " " + date.hours + "-" + date.minutes + "-" + date.seconds + " " + date.date + "-" + (date.month + 1) + "-" + date.fullYear + ".png";

			this.fileReference.save(data, name);
			Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.SCREEN_POST, 1);
			hide();
		}
	}
}