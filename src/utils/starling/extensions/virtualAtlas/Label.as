package utils.starling.extensions.virtualAtlas
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Sprinter
	 */

	public class Label extends Sprite {
		private var _fontName: String;
		private var _text: String = '';
		private var _lastText: String;
		private var _color: int;
		private var _size: int = 15;
		private var _realSizeScale: Number = 0;
		private var _letters: Vector.<Image> = new Vector.<Image>();

		public function Label(fontName: String, text: String = '', color: int = 0xFFFFFF, size: int = 15)
		{
			super();
			_fontName = fontName;
			_text = text;
			_lastText = text;
			_color = color;
			_size = size;
			_realSizeScale = size / AssetManager.MAX_SIZE_FONT;

			draw();
		}
		//TODO оптимизировать. не удалять уже созданные символы
		private function draw(): void
		{
			var letter: String;
			var img: Image;
			var texture: Texture;
			var offset: Number = 0;

			if (_text == _lastText)
			{
				return;
			}

			_lastText = _text;

			for (var i: int = 0, len: int = _letters.length; i < len; i++) {
				_letters[i].removeFromParent(true);
			}

			_letters.length = 0;

			for (var i: int = 0, len: int = _text.length; i < len; i++) {
				letter = _text.substr(i, 1);
				texture = AssetManager.instance.getTextureLetter(_fontName + letter);
				if (texture != null) {
					img = new Image(texture);
					img.scaleX = img.scaleY = _realSizeScale;
					img.x = offset;
					img.color = _color;
					_letters.push(img);
					this.addChild(img);
					offset = img.x + img.width;
				}
			}
		}

		private function get_text(): String {
			return _text;
		}

		private function set_text(value: String): String {
			_text = value;
			draw();
			return value;
		}

		private function get_textSize(): int {
			return _size;
		}

		private function set_textSize(value: int): int {
			_size = value;
			draw();
			return value;
		}

	}
}