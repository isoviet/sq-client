package
{
	import flash.display.BitmapData;
	import flash.net.FileReference;

	import by.blooddy.crypto.image.JPEGEncoder;
	import by.blooddy.crypto.image.PNGEncoder;

	public class NewsImageGenerator
	{
		//Этот класс используется для генерации картинок постинга на FTP
		static public function save(image:BitmapData, name:String, jpg:Boolean = true):void
		{
			CONFIG::release {return;}
			if (jpg)
				new FileReference().save(JPEGEncoder.encode(image, 90), name + ".jpg");
			else
				new FileReference().save(PNGEncoder.encode(image), name + ".png");
		}
	}
}