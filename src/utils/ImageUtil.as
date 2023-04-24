package utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;

	public class ImageUtil
	{
		static public function init(bm:DisplayObject, x:Number, y:Number, width:Number = 0, height:Number = 0):void
		{
			bm.x = x;
			bm.y = y;

			if (width != 0)
				bm.width = width;
			if (height != 0)
				bm.height = height;
		}

		static public function scale(bm:Bitmap, width:Number, height:Number):Bitmap
		{
			var cloned:Bitmap = copy(bm);

			ImageUtil.resize(cloned, width, height);

			return cloned;
		}

		static public function copy(bm:Bitmap):Bitmap
		{
			var clone:BitmapData = bm.bitmapData.clone();

			var cloned:Bitmap = new Bitmap(clone);
			cloned.smoothing = true;
			cloned.pixelSnapping = PixelSnapping.NEVER;

			return cloned;
		}

		static public function center(image:Bitmap, width:Number, height:Number, x:Number, y:Number):void
		{
			image.x = x + int((width - image.width) / 2);
			image.y = y + int((height - image.height) / 2);
		}

		static public function load(url:String, params:Object, onComplete:Function, data:* = null, async:Boolean = false):void
		{
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;
			context.imageDecodingPolicy = async ? ImageDecodingPolicy.ON_LOAD : ImageDecodingPolicy.ON_DEMAND;

			var complete:Function = function(onComplete:Function, data:*):Function
			{
				return function(e:Event):void
				{
					try
					{
						var photo:Bitmap = e.currentTarget.content;
						photo.smoothing = true;
						photo.pixelSnapping = PixelSnapping.NEVER;
						onComplete(photo, data);
					}
					catch (e:Error)
					{
						Logger.add("Failed to load photo1", e);
						onComplete(null, data);
					}
				};
			}(onComplete, data);

			var fail:Function = function(onComplete:Function, data:*):Function
			{
				return function(e:Event):void
				{
					Logger.add("Failed to load photo2", e);
					onComplete(null, data);
				};
			}(onComplete, data);

			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, fail);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fail);

			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.GET;

			if (params != null)
			{
				var variables:URLVariables = new URLVariables();
				for (var key:String in params)
					variables[key] = params[key];
				request.data = variables;
			}

			for (var tries:int = 3; tries != 0; tries--)
			{
				try
				{
					loader.load(request, context);
					return;
				}
				catch (e:Error)
				{
					Logger.add("Failed to load photo3", e);
				}
			}

			onComplete(null, data);
		}

		static public function getNewSize(sprite:DisplayObject, maxWidth:Number, maxHeight:Number):Object
		{
			if (sprite.width <= maxWidth && sprite.height <= maxHeight)
				return {'width': sprite.width, 'height': sprite.height};

			var xRatio:Number = maxWidth / sprite.width;
			var yRatio:Number = maxHeight / sprite.height;

			var ratio:Number = (xRatio < yRatio) ? xRatio : yRatio;

			var useXRatio:Boolean = (xRatio == ratio);
			var newWidth:Number = useXRatio ? maxWidth : (sprite.width * ratio);
			var newHeight:Number = !useXRatio ? maxHeight : (sprite.height * ratio);

			return {'width': int(newWidth), 'height': int(newHeight), 'ratio': ratio};
		}

		static public function convertToRastrImage(image:DisplayObject, width:int, height:int):Bitmap
		{
			var sprite:Sprite = new Sprite();
			var bitmapData:BitmapData;

			var convertedImage:DisplayObject = image;
			convertedImage.width = width;
			convertedImage.height = height;
			sprite.addChild(convertedImage);

			bitmapData = new BitmapData(sprite.width, sprite.height, true, 0x00000000);
			bitmapData.draw(sprite);

			return (new Bitmap(bitmapData));
		}

		static public function getBitmapData(image:DisplayObject, size:Point = null):BitmapData
		{
			var sprite:Sprite = new Sprite();
			sprite.addChild(image);

			var bitmapData:BitmapData = new BitmapData(size ? size.x : image.width, size ? size.y : image.height, true, 0x00000000);
			bitmapData.draw(sprite);
			return bitmapData;
		}

		static private function resize(image:DisplayObject, maxWidth:Number, maxHeight:Number):void
		{
			var newSize:Object = getNewSize(image, maxWidth, maxHeight);

			image.scaleX = newSize['ratio'];
			image.scaleY = newSize['ratio'];
		}
	}
}