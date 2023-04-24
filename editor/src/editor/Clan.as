package editor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import utils.ImageUtil;

	dynamic public class Clan
	{
		public var photo:Bitmap = null;
		public var emblem:Bitmap = null;
		public var id:int = 0;

		public var name:String = "";
		public var photoURL:String = "";
		public var emblemURL:String = "";

		public function setData(data:ByteArray, successImage:Function, successEmblem:Function):void
		{
			this.name = data.readUTF();
			data.readByte();

			this.photoURL = data.readUTF();
			this.photo = null;
			data.readByte();

			this.emblemURL = data.readUTF();
			this.emblem = null;
			data.readByte();

			if (this.photoURL == "")
				successImage();
			else
				ImageUtil.load(this.photoURL, null, photoLoaded, successImage);

			if (this.emblemURL == "")
				successEmblem();
			else
				ImageUtil.load(this.emblemURL, null, emblemLoaded, successEmblem);
		}

		public function getImage(width:int, height:int, x:int, y:int):Bitmap
		{
			var img:Bitmap;

			if (this.photo == null)
				img = new Bitmap(new BitmapData(50, 50, false, 0x00AAAAAA));
			else
				img = this.photo;

			var bmp:Bitmap = ImageUtil.scale(img, width, height);
			bmp.x = x;
			bmp.y = y;

			return bmp;
		}

		public function getEmblem(width:int, height:int, x:int, y:int):Bitmap
		{
			var img:Bitmap;

			if (this.emblem == null)
				img = new Bitmap(new BitmapData(50, 50, false, 0x00AAAAAA));
			else
				img = this.emblem;

			var bmp:Bitmap = ImageUtil.scale(img, width, height);
			bmp.x = x;
			bmp.y = y;

			return bmp;
		}

		private function photoLoaded(photo:Bitmap, success:Function):void
		{
			this.photo = photo;
			success();
		}

		private function emblemLoaded(photo:Bitmap, success:Function):void
		{
			this.emblem = photo;
			success();
		}
	}
}