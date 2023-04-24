package utils.starling
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import starling.textures.Texture;

	public class TextureEx extends Texture
	{
		static public const TEXTURE_ERROR:String = "texture_error";

		static public var dispatcher:EventDispatcher = new EventDispatcher();

		public function TextureEx()
		{
			super();
		}

		override public function dispose(): void
		{
			super.dispose();
		}

		public static function fromBitmapData(data:BitmapData, generateMipMaps:Boolean=true,
			optimizeForRenderToTexture:Boolean=false,
			scale:Number=1, format:String="bgra",
			repeat:Boolean=false):Texture
		{
			var dataClone:BitmapData = data.clone();

			var texture:Texture = Texture.empty(data.width / scale, data.height / scale, true, generateMipMaps, optimizeForRenderToTexture, scale, format, repeat);

			try
			{
				texture.root.uploadBitmapData(data);
				texture.root.onRestore = function ():void
				{
					texture.root.uploadBitmapData(dataClone);
				};
			}
			catch(e:Error)
			{
				dispatcher.dispatchEvent(new Event(TEXTURE_ERROR));
			}
			finally
			{
				return texture;
			}
		}
	}
}