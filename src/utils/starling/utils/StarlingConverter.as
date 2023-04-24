package utils.starling.utils
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import avmplus.getQualifiedClassName;

	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.textures.Texture;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.StarlingItem;
	import utils.starling.TextureEx;
	import utils.starling.collections.DisplayObjectManager;
	import utils.starling.collections.TextureCollection;
	import utils.starling.extensions.virtualAtlas.AssetManager;

	public class StarlingConverter
	{
		private static var _scaleFactor: Number = 1;

		private static const TEXTURE_MAX_SIZE:int = 2048;
		private static var _collectionTexture:TextureCollection = TextureCollection.getInstance();
		public static var count: int = 0;

		public static function set scaleFactor(value: Number): void {
			_scaleFactor = value;
		}

		public static function get scaleFactor(): Number {
			return _scaleFactor;
		}

		public static function normalizeSize(_n:Number, returnDifference:Boolean = false):Number
		{
			var subSize:int = 0;
			if (_n % 2)
				subSize = _n > 0 ? 2 : -2;

			if (returnDifference)
				return subSize;

			return int(_n / 2) * 2 + subSize;
		}

		public static function getScreenShot(): BitmapData
		{
			var stage:Stage= Starling.current.stage;
			var width:Number = stage.stageWidth;
			var height:Number = stage.stageHeight;

			var rs:RenderSupport = new RenderSupport();

			rs.clear(stage.color, 1.0);
			rs.setProjectionMatrix(0, 0, width, height);

			stage.render(rs, 1.0);
			rs.finishQuadBatch();

			var outBmp:BitmapData = new BitmapData(width, height, true);
			Starling.context.drawToBitmapData(outBmp);

			return outBmp;
		}

		public static function getPixelByCoord(displayObject:starling.display.DisplayObject, x:int, y:int):uint
		{
			if (!displayObject.width || !displayObject.height)
				return 0;

			var stageWidth:Number = Starling.current.stage.stageWidth;
			var stageHeight:Number = Starling.current.stage.stageHeight;
			var absoluteRect:Point = new Point();
			var support:RenderSupport = new RenderSupport();
			RenderSupport.clear();
			if (displayObject.parent)
			{
				absoluteRect = displayObject.parent.localToGlobal(new Point(displayObject.x, displayObject.y));
			}

			support.setProjectionMatrix(0, 0, stageWidth, stageHeight);
			support.translateMatrix(absoluteRect.x - displayObject.x, absoluteRect.y - displayObject.y);
			support.pushMatrix();

			support.transformMatrix(displayObject);

			displayObject.render(support, 1.0);
			support.popMatrix();

			var stageBitmapData:BitmapData = new BitmapData(stageWidth, stageHeight, true, 0x0);

			support.finishQuadBatch();
			try
			{
				Starling.context.drawToBitmapData(stageBitmapData);
			}
			catch(e: Error)
			{
				trace('getPixelByCoord: ' + e.message);
			}

			/*
			 var invertTransform:ColorTransform = new ColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
			 stageBitmapData.colorTransform(stageBitmapData.rect, invertTransform);

			 var cropBounds:Rectangle = new Rectangle(
			 0, 0,
			 stageWidth,
			 stageHeight
			 );

			 var resultBitmapData:BitmapData = new BitmapData(cropBounds.width, cropBounds.height, true, 0x0);

			 resultBitmapData.copyPixels(stageBitmapData, cropBounds, new Point());

			 var resultBitmap:Bitmap = new Bitmap(resultBitmapData);

			 while (ScreenStarling.debugLayer.numChildren > 0)
			 ScreenStarling.debugLayer.removeChildAt(0, true);

			 var img: Image = convertToImage(resultBitmap);

			 ScreenStarling.debugLayer.addChild(img);
			 resultBitmap.scaleX = displayObject.scaleX;
			 resultBitmap.scaleY = displayObject.scaleY;

			 resultBitmap.rotation = displayObject.rotation;
			 */

			var color:uint = stageBitmapData.getPixel32(x, y);

			if (color == 16777216 || color == 4278190080)
				color = 0;

			return color;
		}

		public static function imageWithTextureFill(displayObject: flash.display.DisplayObject, fillWidth:Number, fillHeight:Number):Sprite
		{
			var texture:Texture = null;
			var horizontalTiles: Number = 0;
			var verticalTiles: Number = 0;
			var from: String = getCallee();
			var nameClass: String = getQualifiedClassName(displayObject) + '_fill';
			var _roundedScale: int = Math.round(_scaleFactor);
			var image:Image = null;

			if (_collectionTexture.getItem(nameClass).length > 0)
			{
				texture = _collectionTexture.getItem(nameClass)[0].item;
			}
			else
			{
				texture = AssetManager.instance.getTexture(displayObject);
				if (texture == null)
				{
					var rect:Rectangle = getNormalizeRect(displayObject, 1, 1);
					var bd:BitmapData = new BitmapData(rect.width * _roundedScale, rect.height * _roundedScale, true, 0);
					var mx:Matrix = new Matrix();
					mx.scale(_roundedScale, _roundedScale);

					bd.draw(displayObject, mx);

					texture = textureFromBitmapData(bd, true);
					if (!(displayObject is Shape))
						_collectionTexture.add(nameClass, texture, false, from);

					bd.dispose();
					bd = null;
				}
			}

			var sprite: Sprite = new Sprite();
			var vec: Vector.<Image> = new Vector.<Image>();

			horizontalTiles = Math.ceil(fillWidth / (texture.width / _roundedScale));
			verticalTiles = Math.ceil(fillHeight / (texture.height / _roundedScale));

			for (var x:int = 0, lenX:int = horizontalTiles; x < lenX; x++)
			{
				for (var y:int = 0, lenY:int = verticalTiles; y < lenY; y++)
				{
					image = new Image(texture);
					vec.push(image);
					image.x = x * (image.width);
					image.y = y * (image.height);
					sprite.addChild(image);
				}
			}

			return sprite;
		}

		public static function splitMClipToSprite(displayObject:flash.display.DisplayObject):StarlingAdapterSprite
		{
			var mc:MovieClip = displayObject as MovieClip;
			var starlingSprite:StarlingAdapterSprite = new StarlingAdapterSprite();

			for (var i:int = 0; i < mc.numChildren; i++)
			{
				starlingSprite.addChildStarling(new StarlingAdapterSprite(mc.getChildAt(i)));
			}
			mc = null;
			return starlingSprite;
		}

		/*public static function convertToImage(displObj:*, z:int = 0, xScale:Number = 1, yScale:Number = 1, calledFrom: String = null, uniq: Boolean = false):Image
		{
			if (!calledFrom || (calledFrom is String && calledFrom.length == 0))
				calledFrom = getCallee();

			var rect:Rectangle = getNormalizeRect(displObj, xScale, yScale);
			var texture: Texture = AssetManager.instance.getTexture(displObj);
			var img:Image;

			if (texture != null)
			{
				img = new Image(texture);
				img.scaleX = xScale;
				img.scaleY = yScale;
			}
			else
			{
				img = new Image(getTexture(displObj, z , xScale, yScale, false, calledFrom, uniq));
			}

			DisplayObjectManager.getInstance().add(img, getQualifiedClassName(displObj) + ': ' + calledFrom);
			img.pivotX = z - rect.x * _scaleFactor;
			img.pivotY = z - rect.y * _scaleFactor;
			img.x = displObj.x;
			img.y = displObj.y;
			img.scaleX = img.scaleY = 1 / _scaleFactor;

			return img;
		}*/
		public static function convertToImage(displObj:*, z:int = 0, xScale:Number = 1, yScale:Number = 1, calledFrom: String = null, uniq: Boolean = false, noDelete: Boolean = false):Image
		{
			if (!calledFrom || (calledFrom is String && calledFrom.length == 0))
				calledFrom = getCallee();

			var rect:Rectangle = getNormalizeRect(displObj, xScale, yScale);
			var texture: Texture = AssetManager.instance.getTexture(displObj);
			var img:Image;

			if (texture != null)
			{
				img = new Image(texture);
				img.scaleX = xScale;
				img.scaleY = yScale;
			}
			else
			{
				img = new Image(getTexture(displObj, z , xScale, yScale, false, calledFrom, uniq, noDelete));
			}

			DisplayObjectManager.getInstance().add(img, getQualifiedClassName(displObj) + ': ' + calledFrom);
			img.pivotX = z - rect.x * _scaleFactor;
			img.pivotY = z - rect.y * _scaleFactor;
			img.x = displObj.x;
			img.y = displObj.y;
			img.scaleX = img.scaleY = 1 / _scaleFactor;

			return img;
		}

		public static function getNormalizeRect(displObj:flash.display.DisplayObject, xScale:Number = 1, yScale:Number = 1):Rectangle
		{
			var newWidth:int = normalizeSize(Math.abs(displObj.getBounds(displObj).width));
			var newHeight:int = normalizeSize(Math.abs(displObj.getBounds(displObj).height));
			var newX:int = normalizeSize(displObj.getBounds(displObj).x);
			var newY:int = normalizeSize(displObj.getBounds(displObj).y);

			newWidth -= normalizeSize(displObj.getBounds(displObj).x, true);
			newHeight -= normalizeSize(displObj.getBounds(displObj).y, true);

			if (xScale == 0)
				xScale = displObj.scaleX;

			if (yScale == 0)
				yScale = displObj.scaleY;

			newWidth = newWidth * Math.abs(xScale);
			newHeight = newHeight * Math.abs(yScale);
			newX = newX * Math.abs(xScale);
			newY = newY * Math.abs(yScale);

			if (newWidth <= 0)
				newWidth = 1;
			if (newHeight <= 0)
				newHeight = 1;
			if (newWidth > TEXTURE_MAX_SIZE)
				newWidth = TEXTURE_MAX_SIZE;
			if (newHeight > TEXTURE_MAX_SIZE)
				newHeight = TEXTURE_MAX_SIZE;

			return new Rectangle(newX, newY, newWidth, newHeight);
		}

		/*public static function getTexture(displObj:flash.display.DisplayObject, z:int = 0, xScale:Number = 1, yScale:Number = 1, repeat: Boolean = false, from: String = null, uniq: Boolean = false): Texture
		{
			var texture:Texture = null;
			var className: String = getQualifiedClassName(displObj);
			var len:int = _collectionTexture.getItem(className).length;

			if (!from || (from is String && from.length == 0))
				from = getCallee();

			if (len > 0 && !uniq)
			{
				texture = _collectionTexture.getItem(className)[len - 1].item;
			}
			else
			{
				try
				{
					var rect:Rectangle = getNormalizeRect(displObj, xScale * _scaleFactor, yScale * _scaleFactor);
					var bd:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
					var mx:Matrix = new Matrix();
					var rescaleX: Number = xScale * _scaleFactor;
					var rescaleY: Number = yScale * _scaleFactor;

					mx.scale(rescaleX, rescaleY);
					mx.translate(z - rect.x, z - rect.y);

					bd.draw(displObj, mx);
				}
				catch (e:Error)
				{
					trace('convertToImage', e.message);
				}

				texture = textureFromBitmapData(bd, repeat);

				if (!uniq)
					_collectionTexture.add(className, texture, false, from);
				if (uniq)
					_collectionTexture.addShapeTextures(new StarlingItem(texture, true, from));

				if (bd)
					bd.dispose();

				bd = null;
			}

			return texture;
		}*/
		public static function getTexture(displObj:flash.display.DisplayObject, z:int = 0, xScale:Number = 1, yScale:Number = 1, repeat: Boolean = false, from: String = null, uniq: Boolean = false, noDelete: Boolean = false): Texture
		{
			var texture:Texture = null;
			var className: String = getQualifiedClassName(displObj);
			var len:int = _collectionTexture.getItem(className).length;

			if (!from || (from is String && from.length == 0))
				from = getCallee();

			if (len > 0 && !uniq)
			{
				texture = _collectionTexture.getItem(className)[len - 1].item;
			}
			else
			{
				try
				{
					var rect:Rectangle = getNormalizeRect(displObj, xScale * _scaleFactor, yScale * _scaleFactor);
					var bd:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
					var mx:Matrix = new Matrix();
					var rescaleX: Number = xScale * _scaleFactor;
					var rescaleY: Number = yScale * _scaleFactor;

					mx.scale(rescaleX, rescaleY);
					mx.translate(z - rect.x, z - rect.y);

					bd.draw(displObj, mx);
				}
				catch (e:Error)
				{
					trace('convertToImage', e.message);
				}

				texture = textureFromBitmapData(bd, repeat);

				if (!uniq && !noDelete)
					_collectionTexture.add(className, texture, false, from);
				if (uniq && !noDelete)
					_collectionTexture.addShapeTextures(new StarlingItem(texture, true, from));

				if (bd)
					bd.dispose();

				bd = null;
			}

			return texture;
		}

		public static function getCallee(callStackIndex:int = 4) : String
		{
			var stackLine:String = '';
			if (Logger.traceTextureEnabled)
			{
				stackLine = new Error().getStackTrace().split( "\n" , callStackIndex + 1 )[callStackIndex];
			}

			return stackLine;
		}

		public static function textureFromBitmapData(bmd:BitmapData, repeat: Boolean = false):Texture
		{
			var texture: Texture;
			try
			{
				if (bmd && bmd.width > 0 && bmd.height > 0)
				{
					texture = TextureEx.fromBitmapData(bmd, false, true, 1, 'bgra', repeat);
				}
			}
			catch (e: Error)
			{
				texture = Texture.empty(2, 2);
				Logger.add('textureFromBitmapData: ' + e.message);
			}

			return texture;
		}
	}
}