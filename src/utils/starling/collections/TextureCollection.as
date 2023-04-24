package utils.starling.collections
{
	import flash.display.Bitmap;
	import flash.display.Shape;

	import avmplus.getQualifiedClassName;

	import starling.textures.ConcreteTexture;
	import starling.textures.SubTexture;
	import starling.textures.Texture;

	import utils.starling.StarlingItem;

	public class TextureCollection extends DrawObjectCollection
	{
		private static var _instance: TextureCollection;
		private var _textures: Vector.<Texture> = new Vector.<Texture>();
		private var _texturesShapes: Vector.<StarlingItem> = new Vector.<StarlingItem>();

		public static function getInstance():TextureCollection
		{
			if (!_instance)
			{
				_instance = new TextureCollection();
			}

			return _instance;
		}

		public function existTexture(texture: Texture): Boolean
		{
			return _textures.indexOf(texture) != -1;
		}

		public function removeUniqTexture(texture: Texture): void
		{
			while (true)
			{
				if (_textures.indexOf(texture) == -1)
					return;

				_textures.splice(_textures.indexOf(texture), 1);
			}

			removeShapeTextures(texture);
		}

		private function disposeAllTexture(textures: Vector.<StarlingItem>): void
		{
			for(var i: int = 0, j: int = textures.length; i < j; i++)
			{
				if ((textures[i] is StarlingItem) && textures.length > 0)
				{
					if (textures[i].item)
					{
						if ((textures[i].item is SubTexture))
						{
							if (SubTexture(textures[i].item).parent &&
								SubTexture(textures[i].item).parent.base)
							{
								SubTexture(textures[i].item).parent.base.dispose();
							}

							SubTexture(textures[i].item).dispose();
						}
						else if ((textures[i].item is ConcreteTexture))
						{
							ConcreteTexture(textures[i].item).dispose();
						}
						else
						{
							textures[i].item.dispose();
						}

						textures[i] = null;
					}
				}
			}
			textures = new Vector.<StarlingItem>();
		}

		public function disposeAllUniqTextures(): void
		{
			var texture: Texture;

			for(var i: int = 0, j: int = _textures.length; i < j; i++)
			{
				texture = _textures[i];

				if ((texture is SubTexture))
				{
					if (SubTexture(texture).parent &&
						SubTexture(texture).parent.base)
					{
						SubTexture(texture).parent.base.dispose();
					}

					SubTexture(texture).dispose();
				}
				else if ((texture is ConcreteTexture))
				{
					ConcreteTexture(texture).dispose();
				}
				else
				{
					texture.dispose();
				}

				_textures[i] = null;
			}
			_textures = new Vector.<Texture>();
			objects = {};
		}

		public function disposeAllShapeTextures(): void
		{
			disposeAllTexture(_texturesShapes);
		}

		public function removeShapeTextures(texture: Texture): void
		{
			var clear:StarlingItem = new StarlingItem(null);
			var txr: StarlingItem;

			for(var i: int = 0, j: int = _texturesShapes.length; i < j; i++)
			{
				txr = _texturesShapes[i];
				if ((txr is StarlingItem) && txr)
				{
					if (txr.item == texture)
					{
						if ((txr.item is SubTexture))
						{
							if (SubTexture(txr.item).parent &&
								SubTexture(txr.item).parent.base)
							{
								SubTexture(txr.item).parent.base.dispose();
							}

							SubTexture(txr.item).dispose();
						}
						else if ((txr.item is ConcreteTexture))
						{
							ConcreteTexture(txr.item).dispose();
						}
						else
						{
							txr.item.dispose();
						}

						_texturesShapes[i] = clear;
					}
				}
			}

			while (true)
			{
				var ind: int = _texturesShapes.indexOf(clear);
				if (ind == -1)
					return;

				_texturesShapes.splice(ind, 1);
			}
		}

		public  function addShapeTextures(item: StarlingItem): StarlingItem
		{
			_texturesShapes.push(item);
			return item;
		}

		override public function add(className:String, item:*, dispose: Boolean = true, from: String = ''): StarlingItem
		{
			if (item is Texture)
			{
				if (className == getQualifiedClassName(Shape) || (className == getQualifiedClassName(Bitmap)) )
				{

					return addShapeTextures(new StarlingItem(item, true, from));
				}
				else
				{
					_textures.push(item);
					return super.add(className, item, dispose, from);
				}
			}
			else
			{
				trace('error! TextureCollection items is not texture!', item);
			}
			return null;
		}
	}
}