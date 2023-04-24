package
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;

	public class AnimationDataCollector
	{
		static private var bitmapStorage:Object = new Object();

		static public function addBitmapData(clip:MovieClip):Array
		{
			var nameClass:String = getQualifiedClassName(clip);

			if (nameClass in bitmapStorage && bitmapStorage[nameClass]['scale'] == clip.scaleX)
			{
				return bitmapStorage[nameClass]['dataArray'];
			}

			var bitmapDataArray:Array = [];
			var frames:Array = [];

			var r:Rectangle = clip.getRect(clip);

			var m:Matrix = new Matrix();
			m.translate(-r.x, -r.y);
			m.scale(Math.abs(clip.scaleX), Math.abs(clip.scaleY));

			for (var i:int = 0; i < clip.totalFrames; i++)
			{
				clip.gotoAndStop(i);

				var bitmapData:BitmapData = new BitmapData(r.width * Math.abs(clip.scaleX), r.height * Math.abs(clip.scaleY), true, 0x00000000);
				bitmapDataArray.push();

				bitmapData.draw(clip, m);
				frames.push(bitmapData);
			}

			bitmapStorage[nameClass] = new Object();
			bitmapStorage[nameClass]['dataArray'] = frames;
			bitmapStorage[nameClass]['scale'] = clip.scaleX;

			return frames;
		}

		static public function removeBitmapData(clip:MovieClip):void
		{
			var nameClass:String = getQualifiedClassName(clip);

			if (nameClass in bitmapStorage && bitmapStorage[nameClass]['scale'] == clip.scaleX)
			{
				bitmapStorage[nameClass]['dataArray'] = null;
				bitmapStorage[nameClass] = null;

				delete(bitmapStorage[nameClass]);
			}
		}
	}
}