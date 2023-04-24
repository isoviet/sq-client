package editor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import utils.ImageUtil;

	dynamic public class Player
	{
		public var photo:Bitmap = null;
		public var uid:int = 0;
		public var nid:String = "";

		public var playerName:String = "";
		public var photoURL:String = "";
		public var profileURL:String = "";

		public function setData(data:ByteArray, success:Function):void
		{
			this.playerName = data.readUTF();
			data.readByte();

			this.photoURL = data.readUTF();
			this.photo = null;
			data.readByte();

			this.profileURL = data.readUTF();
			data.readByte();

			if (this.photoURL == "")
			{
				success();
				return;
			}

			ImageUtil.load(this.photoURL, null, photoLoaded, success);
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

		private function photoLoaded(photo:Bitmap, success:Function):void
		{
			this.photo = photo;
			success();
		}
	}
}