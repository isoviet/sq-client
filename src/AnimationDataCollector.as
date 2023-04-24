package
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;

	import utils.ClothesClip;
	import utils.starling.utils.StarlingConverter;

	public class AnimationDataCollector
	{
		static private const AGE:int = 2;
		static private var bitmapStorage:Object = {};

		static public function addBitmapData(clip:*, rasterAll:Boolean = true):Array
		{
			var nameClass:String = getNameClass(clip);

			if (nameClass in bitmapStorage && (!(clip is MovieClip) || bitmapStorage[nameClass]['scale'] == clip.scaleX))
			{
				if ("age" in bitmapStorage[nameClass])
					bitmapStorage[nameClass]['age'] = AnimationDataCollector.AGE;
				return bitmapStorage[nameClass]['dataArray'];
			}

			bitmapStorage[nameClass] = {};
			var totalFrames:int = clip.totalFrames;
			bitmapStorage[nameClass]['dataArray'] = (!rasterAll) ? new Array(totalFrames) : rasterizeFrames(clip, 0, totalFrames - 1);

			if (clip is MovieClip)
				bitmapStorage[nameClass]['scale'] = clip.scaleX;
			if (clip is ClothesClip)
				bitmapStorage[nameClass]['age'] = AnimationDataCollector.AGE;

			return bitmapStorage[nameClass]['dataArray'];
		}

		static public function rasterizeFrame(clip:*, frame:int):void
		{
			var nameClass:String = getNameClass(clip);

			if (bitmapStorage[nameClass] && bitmapStorage[nameClass]['dataArray'] && (!bitmapStorage[nameClass]['dataArray'][frame] || bitmapStorage[nameClass]['dataArray'][frame] == null))
				bitmapStorage[nameClass]['dataArray'][frame] = rasterizeFrames(clip, frame, frame)[0];
		}

		static public function resetAge(usingClothes:Array):void
		{
			for each (var name:String in usingClothes)
			{
				if (!(name in bitmapStorage))
					continue;
				if (!("age" in bitmapStorage[name]))
					continue;
				bitmapStorage[name]['age'] = AnimationDataCollector.AGE;
			}
		}

		static public function clearBitmapData(all:Boolean = false):void
		{
			var clearIds:Array = [];
			for (var name:String in bitmapStorage)
			{
				if (bitmapStorage[name] == null || bitmapStorage[name]['dataArray'] == null)
				{
					clearIds.push(name);
					continue;
				}
				if (!("age" in bitmapStorage[name]))
					continue;
				bitmapStorage[name]['age']--;
				if (!all && bitmapStorage[name]['age'] > 0)
					continue;

				if ("dataArray" in bitmapStorage[name])
				{
					for each (var bd:BitmapData in bitmapStorage[name]['dataArray'])
					{
						if (bd)
							bd.dispose();
					}
					bitmapStorage[name]['dataArray'] = null;
					delete bitmapStorage[name]['dataArray'];
				}

				bitmapStorage[name] = null;

				clearIds.push(name);
			}

			for each (name in clearIds)
				delete bitmapStorage[name];
		}

		static public function rasterizeFrames(clip:*, startFrame:int, endFrame:int):Array
		{
			var r:Rectangle = clip.getRect(clip);
			var frames:Array = [];

			var m:Matrix = new Matrix();
			m.translate(-r.x, -r.y);
			m.scale(Math.abs(clip.scaleX *  StarlingConverter.scaleFactor), Math.abs(clip.scaleY *  StarlingConverter.scaleFactor));

			var quality:String = "";
			if (Game.stage.quality.toLowerCase() != StageQuality.HIGH)
			{
				quality = Game.stage.quality;
				Game.stage.quality = StageQuality.HIGH;
			}

			for (var i:int = startFrame; i <= endFrame; i++)
			{
				clip.gotoAndStop(i + 1);

				var bitmapData:BitmapData = new BitmapData(r.width * Math.abs(clip.scaleX *  StarlingConverter.scaleFactor), r.height * Math.abs(clip.scaleY *  StarlingConverter.scaleFactor), true, 0x00000000);
				bitmapData.draw(clip, m);

				frames.push(bitmapData);
			}

			if (quality != "")
				Game.stage.quality = quality;

			return frames;
		}

		static private function getNameClass(clip:*):String
		{
			var nameClass:String = (clip is String) ? clip : getQualifiedClassName(clip);

			if (clip is ClothesClip)
				nameClass = clip.getName();

			return nameClass;
		}
	}
}