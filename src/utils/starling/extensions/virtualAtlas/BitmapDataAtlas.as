package utils.starling.extensions.virtualAtlas
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class BitmapDataAtlas extends BitmapData
	{
		private var freePlaceBMD: Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
		private var itemRect: Object = {}; //{name} = Rectangle;
		private static var MIN_SQUARE_PLACE: Number = 1; // maxTextureSize / MIN_SQUARE_PLACE == 1024 / 1; or 1024 / 10.24;
		private static var TEXTURE_MARGIN: int = 1; //x2 == 2/4/6/8
		private var _sprite: Sprite = new Sprite();
		private var _maxItems: int = 0;

		public function BitmapDataAtlas(textureSize: int, transparent: Boolean = true, fillColor: uint = 0xFFFFFFFF): void
		{
			super(textureSize, textureSize, transparent, fillColor);

			_maxItems = int(textureSize / MIN_SQUARE_PLACE);

			fillDataPlace(0);
		}

		private function fillDataPlace(value: int): void
		{
			freePlaceBMD = new Vector.<Vector.<int>>();
			var len: int = freePlaceBMD.length;
			for (var x: int = 0; x < _maxItems; x++)
			{
				freePlaceBMD.push(new Vector.<int>());
				for (var y: int = 0; y < _maxItems; y++)
				{
					freePlaceBMD[x][y] = value;
				}
			}
		}

		public function getItems(): Object
		{
			return itemRect;
		}

		public function resetRegions(): void
		{
			itemRect = {};
		}

		public function addRegions(name:String, rect:Rectangle): void
		{
			itemRect[name] =  rect;
		}

		public function translateBitmapData(bmd: BitmapData, name: String): Boolean
		{
			var maxSizeX: int = Math.ceil((Math.ceil(bmd.width) + TEXTURE_MARGIN * 2) / MIN_SQUARE_PLACE);
			var maxSizeY: int = Math.ceil((Math.ceil(bmd.height) + TEXTURE_MARGIN * 2) / MIN_SQUARE_PLACE);
			var offsetX: int = 0;
			var offsetY: int = 0;
			var freeCount: int = (maxSizeX * maxSizeY) * 2;
			var foundCount: int = 0;
			var mx:Matrix = new Matrix();
			var appendOffset: int = Math.ceil((TEXTURE_MARGIN * 2) / MIN_SQUARE_PLACE);
			var len: int = freePlaceBMD.length;

			if (maxSizeX >= len || maxSizeY >= len)
			{
				mx.translate(2, 2);
				this.draw(bmd, mx);
				itemRect[name] = new Rectangle(0, 0, len * MIN_SQUARE_PLACE, len * MIN_SQUARE_PLACE);

				fillDataPlace(1);

				return true;
			}

			while (true)
			{
				if (offsetX + maxSizeX + appendOffset > len)
				{
					offsetY++;
					offsetX = 0;
					foundCount = 0;
				}

				if (offsetY + maxSizeY + appendOffset > len)
				{
					return false;
				}
				var lenWidth: int = Math.min(offsetX + maxSizeX + appendOffset, len);
				var lenHeight: int = Math.min(offsetY + maxSizeY + appendOffset, len);

				for (var x: int = offsetX, lenX: int = lenWidth; x < lenX; x++)
				{
					for (var y: int = offsetY, lenY: int = lenHeight; y < lenY; y++)
					{
						if (freePlaceBMD[x][y] == 1)
						{
							offsetX = x + 1;
							foundCount = 0;
							break;
						}
						else
						{
							foundCount++;
							if (foundCount >= freeCount)
							{
								mx.translate(offsetX * MIN_SQUARE_PLACE, offsetY * MIN_SQUARE_PLACE);
								itemRect[name] = new Rectangle(
									offsetX,
									offsetY,
									bmd.width,
									bmd.height
								);

								this.draw(bmd, mx);

								for (var x1: int = offsetX, lenX1: int = (offsetX + maxSizeX + appendOffset); x1 < lenX1; x1++)
								{
									for (var y1: int = offsetY, lenY1: int = (offsetY + maxSizeY + appendOffset); y1 < lenY1; y1++)
									{
										if (freePlaceBMD[x1][y1] == 0) {
											freePlaceBMD[x1][y1] = 1;
										}
									}
								}
								return true;
							}
						}
					}
				}
			}

			return true;
		}
	}
}