package game.mainGame.entity.view
{
	import flash.geom.Point;

	import starling.display.Image;
	import starling.textures.Texture;

	import utils.GeomUtil;
	import utils.starling.StarlingAdapterSprite;

	public class RopeView extends StarlingAdapterSprite
	{
		private var _start:Point = new Point();
		private var _end:Point = new Point();
		private var _offset:Number = 0;
		private var drawSprite:StarlingAdapterSprite = new StarlingAdapterSprite();
		private var lastLength: int = 0;
		private var vecImages: Vector.<Image> = new Vector.<Image>();
		private var image: Image;
		private var _texture: Texture;
		private var _textureWidth: int = 0;
		private var _lastWidth: int = 0;

		public function RopeView(imageClass:Class = null):void
		{
			if (!imageClass)
				imageClass = RopeSegmentView;
			var sprite: StarlingAdapterSprite = new StarlingAdapterSprite(new imageClass);
			_texture = sprite.texture;

			if (_texture != null)
				_textureWidth = _texture.width;

			addChildStarling(drawSprite);
		}

		public function set start(value:Point):void
		{
			this._start.x = value.x;
			this._start.y = value.y;
			this.x = value.x;
			this.y = value.y;
		}

		public function set end(value:Point):void
		{
			if (this._end.equals(value))
				return;

			this._end.x = value.x;
			this._end.y = value.y;

			calcRotation();
			draw();
		}

		public function get start():Point
		{
			return this._start;
		}

		public function get end():Point
		{
			return this._end;
		}

		public function set offset(value:Number):void
		{
			if (this._offset == value)
				return;

			this._offset = value;
			draw();
		}

		public function get length():Number
		{
			return _start.clone().subtract(_end).length;
		}

		private function calcRotation():void
		{
			this.rotation = GeomUtil.getAngle(_start, _end) - 90;
		}

		private function draw():void
		{
			if (Math.round(this.length) > lastLength + 2 || Math.round(this.length) < lastLength - 2) {

				lastLength = Math.round(this.length);

				var sprite:StarlingAdapterSprite = new StarlingAdapterSprite();

				var widthRope: int = Math.ceil(this.length / _textureWidth);
				var offestSize: int = Math.max(widthRope - 1, 0);

				if (widthRope == _lastWidth)
					return;

				for (var j: int = offestSize, lenVec: int = vecImages.length; j < lenVec; j++) {
					vecImages[j].removeFromParent(true);
					vecImages[j] = null;
				}

				vecImages.length = Math.min(vecImages.length, offestSize);
				offestSize = Math.max(0, vecImages.length - 1);

				for(var i: int = offestSize, len: int = widthRope; i < len; i++)
				{
					image = new Image(_texture);
					image.x = i * _textureWidth;
					image.y = -image.height / 2;
					vecImages.push(image);
					sprite.addChildStarling(image);
				}

				_lastWidth = widthRope;

				drawSprite.addChildStarling(sprite);
			}
		}
	}
}