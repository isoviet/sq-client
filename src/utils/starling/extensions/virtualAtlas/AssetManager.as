package utils.starling.extensions.virtualAtlas
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;

	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import utils.starling.utils.StarlingConverter;

	public class AssetManager
	{
		static public const MAX_SIZE_FONT: int = 72;
		static private const BLOCK_ARRAY:Array = ["Block", "GlassBlock", "MetalBlock", "WoodenBlock"];

		static private var _instance: AssetManager = null;

		private var listTextureAtlas:Object = {}; // {name}= textureAtlas
		private var itemTextureAtlas:Object = {}; // {texture} = atlasName;
		private var _atlasCount:int = 0;
		private var _scaleFactor:Number = 1;

		public function AssetManager(): void
		{}

		public static function get instance(): AssetManager
		{
			if (_instance == null)
				_instance = new AssetManager();
			return _instance;
		}

		public function parseAtlas(atlas: Sprite): void
		{
			var nameAtlas: String = getQualifiedClassName(atlas);
			var bounds: Rectangle = null;
			var nameChild: String = '';
			var child: DisplayObject;
			var listObjects: Vector.<Object> = new Vector.<Object>();
			var textureAtlas: TextureAtlas = null;
			var itemObject: Object = null;
			var rect:Rectangle = StarlingConverter.getNormalizeRect(atlas, _scaleFactor, _scaleFactor);
			var bd:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			var mx:Matrix = new Matrix();
			var rescaleX: Number = _scaleFactor;
			var rescaleY: Number = _scaleFactor;

			for(var i: int = 0, len: int = atlas.numChildren; i < len; i++)
			{
				child = atlas.getChildAt(i);

				if (!(child is Sprite))
					continue;

				nameChild = getQualifiedClassName(child);
				bounds = child.getBounds(atlas);

				bounds.x = Math.ceil(bounds.x) - 2;
				bounds.y = Math.ceil(bounds.y) - 2;
				if (BLOCK_ARRAY.indexOf(nameChild) != -1)
				{
					bounds.width = 64;
					bounds.height = 32;
				}
				else
				{
					bounds.width = Math.ceil(bounds.width);
					bounds.height = Math.ceil(bounds.height);
				}

				listObjects.push({name: nameChild, rect: bounds});
				itemTextureAtlas[nameChild] = nameAtlas;
			}

			mx.scale(rescaleX, rescaleY);
			mx.translate(-rect.x,-rect.y);

			bd.draw(atlas, mx);

			textureAtlas = new TextureAtlas(StarlingConverter.textureFromBitmapData(bd));
			listTextureAtlas[nameAtlas] = textureAtlas;

			for(i = 0, len = listObjects.length; i < len; i++)
			{
				itemObject = listObjects[i];
				textureAtlas.addRegion(itemObject.name, itemObject.rect);
			}

			listObjects = null;
		}

		public function getTexture(objClass: DisplayObject):Texture
		{
			var name:String = getQualifiedClassName(objClass);
			var atlasName: String = itemTextureAtlas.hasOwnProperty(name) ? itemTextureAtlas[name] : null;
			var atlasTexture: TextureAtlas;

			if (atlasName != null)
			{
				atlasTexture = listTextureAtlas.hasOwnProperty(atlasName) ? listTextureAtlas[atlasName] : null;
				if (atlasTexture != null)
				{
					return atlasTexture.getTexture(name) as Texture;
				}
			}

			return null;
		}
	}
}