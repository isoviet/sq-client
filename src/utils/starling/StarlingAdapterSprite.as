package utils.starling
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;

	import utils.starling.collections.DisplayObjectManager;
	import utils.starling.collections.TextureCollection;
	import utils.starling.extensions.virtualAtlas.AssetManager;
	import utils.starling.utils.StarlingConverter;

	public dynamic class StarlingAdapterSprite extends flash.display.Sprite implements IStarlingAdapter
	{
		private var _starlingSprite: starling.display.Sprite = null;
		private var _children: Vector.<StarlingItem> = new Vector.<StarlingItem>();
		private var _parent:* = null;
		private var _textureFromAtlas: Boolean = false;
		private var _originDisplayObject: flash.display.DisplayObject = null;
		private var _originImage: Image = null;
		private var _lastIndex:int = 0;
		private var _localRect: Rectangle = new Rectangle();
		private var _userRescaleOriginalImage: Boolean = true;
		private var _lastScaleX: Number = 0;
		private var _lastScaleY: Number = 0;
		private var _scaleX: Number = 1;
		private var _scaleY: Number = 1;
		private var _actualAlpha: Number = 1;

		public function StarlingAdapterSprite(child:* = null, uniq: Boolean = false)
		{
			super();
			_textureFromAtlas = false;

			_starlingSprite = new starling.display.Sprite();

			if (child)
			{
				_scaleX = child.scaleX;
				_scaleY = child.scaleY;

				_lastScaleX = child.scaleX;
				_lastScaleY = child.scaleY;

				_originDisplayObject = child;

				var from: String = StarlingConverter.getCallee();
				var _texture: Texture = AssetManager.instance.getTexture(_originDisplayObject);
				if (_texture)
				{
					_originImage = new Image(_texture);
					_textureFromAtlas = true;
				}
				else
				{
					_originImage = StarlingConverter.convertToImage(_originDisplayObject, 0, child.scaleX, child.scaleY, from, uniq);
				}

				_starlingSprite.addChild(_originImage);
			}
			else
			{
				_starlingSprite.addChild(new starling.display.Sprite());
			}
			//_starlingSprite.touchable = false;
		}

		public function set touchable(value: Boolean): void
		{
			_starlingSprite.touchable = value;
		}

		public function get touchable(): Boolean
		{
			return _starlingSprite.touchable;
		}

		public function get texture(): Texture
		{
			return _originImage ? _originImage.texture : null;
		}

		public function get clipRect():Rectangle
		{
			return _starlingSprite.clipRect;
		}

		public function set clipRect(value:Rectangle):void
		{
			_starlingSprite.clipRect = value;
		}

		public function set useRescaleOriginalImage(value: Boolean): void
		{
			_userRescaleOriginalImage = value;
		}

		public function get useRescaleOriginalImage(): Boolean
		{
			return _userRescaleOriginalImage;
		}

		public function set localRect(value: Rectangle): void
		{
			_localRect = value;
		}

		public function get localRect(): Rectangle
		{
			return _localRect;
		}

		public function set smoothing(value:String):void
		{
			if (_originImage)
			{
				_originImage.smoothing = value;
			}
		}

		public function set lastIndex(value:int):void
		{
			_lastIndex = value;
		}

		public function get lastIndex():int
		{
			return _lastIndex;
		}

		override public function globalToLocal(point:Point):Point
		{
			var point: Point;

			try
			{
				point = _starlingSprite.globalToLocal(point);
			}
			catch(e: Error)
			{
				Logger.add('StarlingAdapterSprite->globalToLocal: ' + e.message);
				point = new Point();
			}

			return point;
		}

		override public function localToGlobal(point:Point):Point
		{
			return _starlingSprite.localToGlobal(point);
		}

		public function getRectStarling(obj:*):Rectangle
		{
			return _starlingSprite.getBounds(obj);
		}

		public function boundsStarling():Rectangle
		{
			return _starlingSprite.bounds;
		}

		public function hitTestObjectStarling(obj:*):Boolean
		{
			if (obj)
			{
			}
			return false;
		}

		public function hitTestPointStarling(localPoint:Point):Boolean
		{
			return _starlingSprite.hitTest(localPoint) != null;
		}

		public function hitTestStarling(localPoint:Point, forTouch:Boolean = false):*
		{
			var toObjectPoint:Point = _starlingSprite.globalToLocal(localPoint);
			var objBounds:Rectangle = _starlingSprite.getBounds(_starlingSprite);
			if (!_starlingSprite || toObjectPoint.x < objBounds.x || toObjectPoint.x > objBounds.x + objBounds.width || toObjectPoint.y < objBounds.y || toObjectPoint.y > objBounds.y + objBounds.height) return null;
			var color:uint = StarlingConverter.getPixelByCoord(_starlingSprite, localPoint.x, localPoint.y);
			if (this.alpha <= 0) return this;
			if (color > 0)
				return this;

			return null;
		}

		public function hitTestRectStarling(localRect:Rectangle, forTouch:Boolean = false):*
		{
			if (forTouch && (!_starlingSprite.visible || !_starlingSprite.touchable)) return null;
			var theBounds:Rectangle = _starlingSprite.getBounds(_starlingSprite);
			theBounds.inflate(0, 0);
			if (theBounds.containsRect(localRect)) return this;
			return null;
		}

		public function removeFromParent(dispose:Boolean = true):void
		{
			try
			{
				if (_starlingSprite.filter)
				{
					_starlingSprite.filter.dispose();
					_starlingSprite.filter = null;
				}

				if (dispose)
				{
					var item:*;
					for (var i:int = 0; i < _children.length; i++)
					{
						item = _children[i].item;
						if (item is IStarlingAdapter)
						{
							item.removeFromParent();
						}
						else if (item is starling.display.DisplayObject)
						{
							disposeTextureImage(item);
						}
						item = null;
						_children[i] = null;
					}

					if (this._starlingSprite && _starlingSprite.numChildren > 0)
					{
						disposeTextureImage(_starlingSprite);
					}

					if (_originImage)
					{
						disposeTextureImage(_originImage);
					}

					_children = new Vector.<StarlingItem>();
					_originDisplayObject = null;
					_originImage = null;
					//_starlingSprite.dispose();
				}

				_parent = null;
				_starlingSprite.removeFromParent(dispose);

				if (this.parent)
					this.parent.removeChild(this);
			}
			catch (e:Error)
			{
				trace('sprite removeFromParent', e.message);
			}
		}

		private function disposeTextureImage(dplObj:starling.display.DisplayObject):void
		{
			var exitCriticalCount:int = -1;
			var textureCollection: TextureCollection = TextureCollection.getInstance();

			if (dplObj is Image)
			{
				var txr: * = (dplObj as Image).texture;

				if (txr && !textureCollection.existTexture(txr))
				{
					textureCollection.removeShapeTextures(txr);
				}

				DisplayObjectManager.getInstance().remove(Image(dplObj));
				(dplObj as Image).removeFromParent();

				(dplObj as Image).dispose();
			}
			else if (dplObj is QuadBatch)
			{
				if (QuadBatch(dplObj).texture && !textureCollection.existTexture((dplObj as QuadBatch).texture))
					QuadBatch(dplObj).texture.dispose();

				QuadBatch(dplObj).reset();
				QuadBatch(dplObj).dispose();
				QuadBatch(dplObj).removeFromParent();
			}
			else if (dplObj is starling.display.Sprite)
			{
				while (starling.display.Sprite(dplObj).numChildren > 0)
				{
					if (exitCriticalCount == (dplObj as starling.display.Sprite).numChildren)
					{
						trace('disp while: ', (dplObj as starling.display.Sprite).numChildren, (dplObj as starling.display.Sprite).getChildAt(0));
						trace('critical exit!', dplObj);
						dplObj.removeFromParent();
						dplObj.dispose();
						exitCriticalCount = -1;
						break;
					}
					exitCriticalCount = (dplObj as starling.display.Sprite).numChildren;

					disposeTextureImage((dplObj as starling.display.Sprite).getChildAt(0));
				}
				dplObj.removeFromParent();
				dplObj.dispose();
			}
			else
			{
				dplObj.removeFromParent();
				dplObj.dispose();
			}
			dplObj = null;
		}

		public function set useCursorHand(value:Boolean):void
		{
			_starlingSprite.useHandCursor = value;
		}

		public function set pivotX(value:Number):void
		{
			_starlingSprite.pivotX = value;
		}

		public function get pivotY():Number
		{
			return _starlingSprite.pivotY;
		}

		public function set pivotY(value:Number):void
		{
			_starlingSprite.pivotY = value;
		}

		public function get pivotX():Number
		{
			return _starlingSprite.pivotX;
		}

		public function alignPivot(hAlign:String = 'center', vAlign:String = 'center'):void
		{
			_starlingSprite.alignPivot(hAlign, vAlign);
		}

		public function getinfo():void
		{
			trace('getinfo', _children, _starlingSprite.numChildren, _children.length, super.numChildren);
		}

		override public function set blendMode(value:String):void
		{
			_starlingSprite.blendMode = value;
		}

		public function getStarlingView():starling.display.DisplayObjectContainer
		{
			return _starlingSprite;
		}

		public function addChildStarlingAt(child:*, index:int):void
		{
			setChildStarlingIndex(addChildStarling(child), index);
		}

		public function addChildStarling(child:*):*
		{
			_children.push(new StarlingItem(child));
			if (child is IStarlingAdapter)
			{
				var scaleX: Number = this.scaleX * child.scaleX;
				var scaleY: Number = this.scaleY * child.scaleY;
				IStarlingAdapter(child).scaleXY(scaleX, scaleY);
			}
			else
			{
				child.scaleX *= this.scaleX;
				child.scaleY *= this.scaleY;
			}

			if (child is IStarlingAdapter)
			{
				child.parentStarling = this;
				_starlingSprite.addChild(child.getStarlingView());
			}
			else
			{
				_starlingSprite.addChild(child);
			}

			return child;
		}

		public function removeChildStarling(child:*, dispose:Boolean = true):void
		{
			var index:int = -1;

			if (child is IStarlingAdapter)
			{
				index = _starlingSprite.getChildIndex((child as IStarlingAdapter).getStarlingView()) - 1;
				child.removeFromParent(dispose);
			}
			else if (child is starling.display.DisplayObject)
			{
				index = _starlingSprite.getChildIndex(child) - 1;
				if (index > 0)
					starling.display.DisplayObject(child).removeFromParent(false);
				if (dispose) disposeTextureImage(child);
			}

			if (index > -1)
				_children.splice(index, 1);

			if (!(child is IStarlingAdapter) && child is flash.display.DisplayObject)
				removeChild(child);
		}

		override public function set scaleX(value:Number):void
		{
			if (_scaleX == value && _starlingSprite.scaleX == value)
				return;

			_scaleX = value;

			if (this._originDisplayObject && _userRescaleOriginalImage)
			{
				rescaleImage();
			}

			if (_textureFromAtlas == false && !this._originDisplayObject)
			{
				_starlingSprite.scaleX = value;
			}
			else
			{
				updateForAll();
			}
		}

		override public function set scaleY(value:Number):void
		{
			if (_scaleY == value && _starlingSprite.scaleY == value) return;

			_scaleY = value;

			if (this._originDisplayObject && _userRescaleOriginalImage)
			{
				rescaleImage();
			}

			if (_textureFromAtlas == false && !this._originDisplayObject)
			{
				_starlingSprite.scaleY = value;
			}
			else
			{
				updateForAll();
			}
		}

		public function scaleXY(x:Number, y: Number = 0):void
		{
			if (y == 0)
				y = x;

			if (_scaleX == x && _scaleY == y) return;
			_scaleX = x;
			_scaleY = y;

			if (this._originDisplayObject && _userRescaleOriginalImage)
			{
				rescaleImage();
			}

			updateForAll();
		}

		public function set scaleFlashX(value: Number): void
		{
			super.scaleX = value;
		}

		public function set scaleFlashY(value: Number): void
		{
			super.scaleY = value;
		}

		override public function get scaleX(): Number
		{
			return _scaleX;
		}

		override public function get scaleY(): Number
		{
			return _scaleY;
		}

		override public function set x(value:Number):void
		{
			super.x = Math.round(value);
			_starlingSprite.x =  Math.round(value);
		}

		override public function set y(value:Number):void
		{
			super.y =  Math.round(value);
			_starlingSprite.y =  Math.round(value);
		}

		override public function set alpha(value:Number):void
		{
			_actualAlpha = _starlingSprite.alpha = value;
		}

		override public function get alpha():Number
		{
			return _actualAlpha;
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			_starlingSprite.visible = value;
		}

		override public function get visible():Boolean
		{
			return _starlingSprite.visible;
		}

		public function get realAlpha(): Number
		{
			return _starlingSprite.alpha;
		}

		public function hideSprite(): void
		{
			if (_starlingSprite.alpha > 0)
				_starlingSprite.alpha = 0;
		}

		public function showSprite(): void
		{
			if (_actualAlpha > 0)
				_starlingSprite.alpha = _actualAlpha;
		}

		override public function set rotation(value:Number):void
		{
			super.rotation = value;
			_starlingSprite.rotation = value * Math.PI / 180;
		}

		override public function get rotation():Number
		{
			return super.rotation;
		}

		override public function get width():Number
		{
			return _starlingSprite.width;
		}

		override public function get height():Number
		{
			return _starlingSprite.height;
		}

		public function containsStarling(child:*):Boolean {
			if (child is IStarlingAdapter)
				return _starlingSprite.contains(child.getStarlingView());

			return false;
		}

		override public function set filters(value:Array):void
		{
			try
			{
				if (!value || !value.length)
				{
					if (_starlingSprite.filter)
					{
						_starlingSprite.filter.dispose();
						_starlingSprite.filter = null;
					}
				}
				else
				{
					if (value[0] is BlurFilter || value[0] is ColorMatrixFilter)
					{
						_starlingSprite.filter = value[0];
					}
					else if (typeof(value[0]) == 'object' && value[0].color && value[0].alpha && value[0].quality)
					{
						var bf:BlurFilter = BlurFilter.createGlow(value[0].color, value[0].alpha, value[0].blurX, value[0].quality);
						bf.blurX = value[0].blurX;
						bf.blurY = value[0].blurY;
						_starlingSprite.filter = bf;
					}
				}
			}
			catch (e:Error)
			{
				trace('starling adatpter sprite ', e.message);
			}
		}

		override public function get numChildren():int
		{
			var count:int = 0;
			count = _children.length;

			if (count < _starlingSprite.numChildren - 1)
			{
				count = _starlingSprite.numChildren - 1;
			}

			if (super.numChildren && count < super.numChildren)
			{
				count = super.numChildren;
			}
			return count;
		}

		public function get parentStarling():*
		{
			return _parent;
		}

		public function set parentStarling(parent:*):void
		{
			_parent = parent;
		}

		public function getChildStarlingIndex(child:*, onlyReal:Boolean = false):int
		{
			if (child is IStarlingAdapter)
			{
				if (!child.getStarlingView().parent && !onlyReal)
				{
					return child.lastIndex;
				}
				child = child.getStarlingView();
			}

			return _starlingSprite.getChildIndex(child);
		}

		public function setChildStarlingIndex(child:*, index:int):void
		{
			var ind:int = -1;

			if (child is IStarlingAdapter)
				child = child.getStarlingView();

			ind = _starlingSprite.getChildIndex(child) - 1;

			if (ind > -1)
			{
				var item:* = _children[ind];
				_children.splice(ind, 0);
				_children.splice(index, 0, item);
			}
			else
			{
				_children.splice(index, 0, StarlingItem(child));
			}

			_starlingSprite.setChildIndex(child, index);
			_lastIndex = index;
		}

		public function getChildStarlingAt(index:int):*
		{
			if (_children.length <= index) {
				if (super.numChildren > index)
				{
					return super.getChildAt(index);
				}
				else
				{
					return null;
				}
			}
			return _children[index].item;
		}

		public function removeChildStarlingAt(index:int, dispose:Boolean = true):starling.display.DisplayObject
		{
			var obj:*;

			if (index < 0)
				return null;

			if (_children.length > index)
			{
				if (_children[index] == null) {
					_children.splice(index, 1);
					return null;
				}
				obj = _children[index].item;
				_children.splice(index, 1);
			}
			else
			{
				if (_starlingSprite.numChildren > index)
				{
					obj = _starlingSprite.getChildAt(index);
				}
				else if (super.numChildren > index)
				{
					super.removeChildAt(index);
					return null;
				}
				else if (super.numChildren > 0)
				{
					super.removeChildAt(super.numChildren - 1);
					return null;
				}
			}

			if (obj is IStarlingAdapter)
			{
				obj.removeFromParent(dispose);
				obj = null;
			}
			else if (obj is starling.display.DisplayObject)
			{
				if (dispose) disposeTextureImage(obj);
			}

			return null;
		}

		override public function removeChildAt(index:int):flash.display.DisplayObject
		{
			try
			{
				if (index < super.numChildren)
					return super.removeChildAt(index);
				return null;
			}
			catch (e:Error)
			{
				trace('error: ', e.message);
			}
			return null;
		}

		override public function getChildAt(index:int):flash.display.DisplayObject
		{
			try
			{
				if (!super.numChildren) return null;
				return super.getChildAt(index);
			}
			catch (e:Error)
			{
				trace('Starling adapter sprite getChildAt', e.message);
			}
			return null;
		}

		public function numberOfChildSprite():int
		{
			return super.numChildren;
		}

		override public function addChild(child:flash.display.DisplayObject):flash.display.DisplayObject
		{
			try
			{
				if (super.contains(child)) return child;
				return super.addChildAt(child, super.numChildren);
			}
			catch (e:Error)
			{
				trace('StarlingAdapterSprite', e.message);
			}
			return null;
		}

		override public function removeChild(child:flash.display.DisplayObject):flash.display.DisplayObject
		{
			try
			{
				super.removeChild(child);
			}
			catch (e:Error)
			{
				trace(e.message);
			}
			return child;
		}

		private function rescaleImage():void
		{
			if (!_originImage) return;

			if (_lastScaleX == _scaleX && _lastScaleY == _scaleY) return;

			_lastScaleX = _scaleX;
			_lastScaleY = _scaleY;

			//DisplayObjectManager.getInstance().remove(_originImage);
			//_starlingSprite.scaleX = super.scaleX;
			//_starlingSprite.scaleY = super.scaleY;

			if (_textureFromAtlas == false)
			{
				_starlingSprite.removeChild(_originImage);
				disposeTextureImage(_originImage);
				updateView();
			}
			else
			{
				_originImage.scaleX = _scaleX;
				_originImage.scaleY = _scaleY;
			}

		}

		public function updateView(): void
		{
			_originImage = StarlingConverter.convertToImage(this._originDisplayObject, 0, _scaleX, _scaleY, StarlingConverter.getCallee(), true);
			_starlingSprite.addChild(_originImage);
		}

		public function updateForAll():void
		{
			for (var i:int = 0; i < _children.length; i++)
			{
				if (_children[i].item.scaleX != _scaleX || _starlingSprite.scaleX != _children[i].item.scaleX) _children[i].item.scaleX = _scaleX;
				if (_children[i].item.scaleY != _scaleY || _starlingSprite.scaleY != _children[i].item.scaleY) _children[i].item.scaleY = _scaleY;
			}
		}
	}
}