﻿package dragonBones.factorys
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;

	import dragonBones.Armature;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.display.StarlingDisplayBridge;
	import dragonBones.textures.ITextureAtlas;
	import dragonBones.textures.StarlingTextureAtlas;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.textures.TextureSmoothing;
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/

	use namespace dragonBones_internal;

	/**
	 * A object managing the set of armature resources for Starling engine. It parses the raw data, stores the armature resources and creates armature instances.
	 * @see dragonBones.Armature
	 */

	/**
	 * A StarlingFactory instance manages the set of armature resources for the starling DisplayList. It parses the raw data (ByteArray), stores the armature resources and creates armature instances.
	 * <p>Create an instance of the StarlingFactory class that way:</p>
	 * <listing>
	 * import flash.events.Event;
	 * import dragonBones.factorys.BaseFactory;
	 *
	 * [Embed(source = "../assets/Dragon2.png", mimeType = "application/octet-stream")]
	 *	private static const ResourcesData:Class;
	 * var starlingFactory:StarlingFactory = new StarlingFactory();
	 * starlingFactory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	 * starlingFactory.parseData(new ResourcesData());
	 * </listing>
	 * @see dragonBones.Armature
	 */
	public class StarlingFactory extends BaseFactory
	{
		/**
		 * Whether to generate mapmaps (true) or not (false).
		 */
		public var generateMipMaps:Boolean;
		/**
		 * Whether to optimize for rendering (true) or not (false).
		 */
		public var optimizeForRenderToTexture:Boolean;
		/**
		 * Apply a scale for SWF specific texture. Use 1 for no scale.
		 */
		public var scaleForTexture:Number;

		/**
		 * Creates a new StarlingFactory instance.
		 */
		public function StarlingFactory()
		{
			super(this);
			scaleForTexture = 1;
		}

		/** @private */
		override protected function generateTextureAtlas(content:Object, textureAtlasRawData:Object):ITextureAtlas
		{
			var texture:Texture;
			var bitmapData:BitmapData;
			if (content is BitmapData)
			{
				bitmapData = content as BitmapData;
				texture = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture);
			}
			else if (content is MovieClip)
			{
				var width:int = getNearest2N(content.width) * scaleForTexture;
				var height:int = getNearest2N(content.height) * scaleForTexture;

				_helpMatrix.a = 1;
				_helpMatrix.b = 0;
				_helpMatrix.c = 0;
				_helpMatrix.d = 1;
				_helpMatrix.scale(scaleForTexture, scaleForTexture);
				_helpMatrix.tx = 0;
				_helpMatrix.ty = 0;
				var movieClip:MovieClip = content as MovieClip;
				movieClip.gotoAndStop(1);
				bitmapData = new BitmapData(width, height, true, 0xFF00FF);
				bitmapData.draw(movieClip, _helpMatrix);
				movieClip.gotoAndStop(movieClip.totalFrames);
				texture = Texture.fromBitmapData(bitmapData, generateMipMaps, optimizeForRenderToTexture, scaleForTexture);
			}
			else
			{
				throw new Error();
			}
			var textureAtlas:StarlingTextureAtlas = new StarlingTextureAtlas(texture, textureAtlasRawData, false);
			if (Starling.handleLostContext)
			{
				textureAtlas._bitmapData = bitmapData;
			}
			else
			{
				bitmapData.dispose();
			}
			return textureAtlas;
		}

		/** @private */
		override protected function generateArmature():Armature
		{
			var armature:Armature = new Armature(new Sprite());
			return armature;
		}

		/** @private */
		override protected function generateSlot():Slot
		{
			var slot:Slot = new Slot(new StarlingDisplayBridge());
			return slot;
		}

		/** @private */
		override protected function generateDisplay(textureAtlas:Object, fullName:String, pivotX:Number, pivotY:Number):Object
		{
			var subTexture:SubTexture = (textureAtlas as TextureAtlas).getTexture(fullName) as SubTexture;
			if (subTexture && subTexture.width != 0 && subTexture.height != 0)
			{
				var image:Image = new Image(subTexture);
				image.pivotX = pivotX;
				image.pivotY = pivotY;
				image.smoothing = TextureSmoothing.NONE;
				return image;
			}
			return null;
		}

		private function getNearest2N(_n:uint):uint
		{
			return _n & _n - 1?1 << _n.toString(2).length:_n;
		}
	}
}