package utils.starling.extensions.virtualAtlas
{
	import starling.textures.TextureAtlas;

	public class CombineAtlas
	{
		private var _textureAtlas: TextureAtlas = null;
		private var _bitmapDataAtlas: BitmapDataAtlas = null;
		private var _name: String = '';

		public function CombineAtlas(name: String, textureAtlas: TextureAtlas = null, bitmapDataAtlas: BitmapDataAtlas =  null): void
		{
			_name = name;
			_textureAtlas = textureAtlas;
			_bitmapDataAtlas = bitmapDataAtlas;
		}

		public function get name(): String
		{
			return _name;
		}

		public function get textureAtlas(): TextureAtlas
		{
			return _textureAtlas;
		}

		public function set textureAtlas(value: TextureAtlas): void
		{
			_textureAtlas = value;
		}

		public function get bitmapDataAtlas(): BitmapDataAtlas
		{
			return _bitmapDataAtlas;
		}

		public function set bitmapDataAtlas(value: BitmapDataAtlas): void
		{
			_bitmapDataAtlas = value;
		}
	}
}