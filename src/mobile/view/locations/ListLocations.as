package mobile.view.locations
{
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import screens.ScreenStarling;

	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import utils.starling.utils.StarlingConverter;

	public class ListLocations extends Sprite
	{
		private const ELEMENT_WIDTH: int = 210;
		private const TIME_ACCELERATION: int = 500;
		private const WIDTH_PLACE: int = 800;
		private const HEIGHT_PLACE: int = 400;
		private const VIEW_ITEM_COUNT: int = 3;

		private var _listLocations: Vector.<LocationItem> = null;
		private var _maskPlace: Sprite = new Sprite();
		private var _btnArrowLeft: Button = null;
		private var _btnArrowRight: Button = null;
		private var _scrollTo: int = 0;
		private var _needScroll: Boolean = true;
		private var _touchDown: Boolean = false;
		private var _point: Point = null;
		private var _startScroll: int = 0;
		private var _indexScroll: int = 0;
		private var _time: Number = 0;
		private var _backgroundShape: Image = null;
		private var _onChange: Function = null;
		private var _onScroll: Function = null;
		private var _selectedItemIndex: int = 0;
		private var _scrollStartPosition: int = -1;
		private var objItemPositions: Array = [
			{
				position: 0,
				scale: 1
			},
			{
				position: ELEMENT_WIDTH * 1,
				scale: 1
			},
			{
				position: ELEMENT_WIDTH * 1.5,
				scale: 0.85
			},
			{
				position: ELEMENT_WIDTH * 2,
				scale: 0.7
			}
		];


		public function ListLocations(listLocations: Vector.<LocationItem>, onChange: Function = null, onScroll: Function = null)
		{
			var shape: Shape = new Shape();

			_onChange = onChange;
			_onScroll = onScroll;

			_listLocations = listLocations;
			_btnArrowLeft = new Button(StarlingConverter.getTexture(new BtnArrowLocations, 0, 1, 1, false, null, false, true));
			_btnArrowLeft.rotation = 3.14;
			_btnArrowLeft.addEventListener(TouchEvent.TOUCH, onTouchArrow);

			_btnArrowRight = new Button(StarlingConverter.getTexture(new BtnArrowLocations, 0, 1, 1, false, null, false, true));
			_btnArrowRight.addEventListener(TouchEvent.TOUCH, onTouchArrow);

			this.addChild(_maskPlace);
			this.addChild(_btnArrowLeft);
			this.addChild(_btnArrowRight);

			shape.graphics.beginFill(0xFFFFFF, 0.01);
			shape.graphics.drawRect(0, 0 , WIDTH_PLACE, HEIGHT_PLACE);
			shape.graphics.endFill();

			_backgroundShape = StarlingConverter.convertToImage(shape);
			_maskPlace.clipRect = new Rectangle(0, 0, WIDTH_PLACE, HEIGHT_PLACE);

			_maskPlace.addChild(_backgroundShape);

			for (var i: int = 0, len: int = _listLocations.length; i < len; i++)
			{
				_maskPlace.addChild(_listLocations[i]);
				_listLocations[i].alignPivot();
				_listLocations[i].x = WIDTH_PLACE / 2 + ELEMENT_WIDTH * i;
				_listLocations[i].y = HEIGHT_PLACE / 2;

				if (i > 0)
					_listLocations[i].scaleX = _listLocations[i].scaleY = 0.8;
			}

			_indexScroll = Math.min(VIEW_ITEM_COUNT * 2, _listLocations.length);

			calcScrollPosition();
			resize();

			_needScroll = true;

			EnterFrameManager.addListener(updateScrollList);
			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onTouch);
		}

		override public function dispose(): void
		{
			EnterFrameManager.removeListener(updateScrollList);
			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onTouch);
			_btnArrowLeft.removeEventListener(TouchEvent.TOUCH, onTouchArrow);
			_btnArrowRight.removeEventListener(TouchEvent.TOUCH, onTouchArrow);
			_btnArrowLeft.removeFromParent(true);
			_btnArrowRight.removeFromParent(true);


			while (_maskPlace.numChildren > 0)
				_maskPlace.removeChildAt(0, false);
			_maskPlace.removeFromParent(true);
			_backgroundShape.removeFromParent(true);

			_btnArrowLeft = null;
			_btnArrowRight = null;
			_maskPlace = null;
			_backgroundShape = null;

			this.removeFromParent();
			super.dispose();
		}

		private function calcScrollPosition(): void
		{
			if (_indexScroll > _listLocations.length - 1)
				_indexScroll = 0;
			if (_indexScroll < 0)
				_indexScroll = _listLocations.length - 1;

			_scrollTo = int(WIDTH_PLACE / 2 - (ELEMENT_WIDTH * _indexScroll));
		}

		private function onTouch(e: TouchEvent): void
		{
			var touch: Touch = e.getTouch(_maskPlace);
			var scrolling: int = 0;
			var dirScroll: int = 0;

			if (touch == null || _maskPlace == null || touch.getLocation(_maskPlace) == null)
				return;

			if (touch.phase == TouchPhase.BEGAN)
			{
				_startScroll = _scrollTo;
				_point = touch.getLocation(_maskPlace);
				_touchDown = true;
				_needScroll = false;
				_time = new Date().getTime();
			}
			else if (touch.phase == TouchPhase.ENDED && _point != null)
			{
				dirScroll = ((_point.x - touch.getLocation(_maskPlace).x) >= 0 ? 1 : -1);
				scrolling = Math.round((_point.x - touch.getLocation(_maskPlace).x) / (ELEMENT_WIDTH * 0.5));

				_time = new Date().getTime() - _time;
				_time = Math.abs(TIME_ACCELERATION - Math.min(_time, TIME_ACCELERATION)) / 200;
				_time = _time * dirScroll;

				if (Math.abs(_point.x - touch.getLocation(_maskPlace).x) < 10)
					_time = 0;

				if (scrolling == 0)
				{
					if (touch.getLocation(_maskPlace).x >=
						_maskPlace.width / 2 + (ELEMENT_WIDTH * LocationItem.SCALE_ACTIVE_ITEM) / 2)
						dirScroll = 1;
					else if (touch.getLocation(_maskPlace).x <=
						_maskPlace.width / 2 - (ELEMENT_WIDTH * LocationItem.SCALE_ACTIVE_ITEM) / 2)
						dirScroll = -1;
					else
						return;
				}

				_scrollTo = _indexScroll;
				_indexScroll += 1 * dirScroll;
				calcScrollPosition();
				_touchDown = false;
				_needScroll = true;
				updateScrollList();
			}
			else if (touch.phase == TouchPhase.MOVED && _touchDown == true && _point != null)
			{
				if (Math.abs(_point.x - touch.getLocation(_maskPlace).x) < 15)
					return;

				_scrollTo = _startScroll - (_point.x - touch.getLocation(_maskPlace).x);
				_needScroll = true;
			}
		}

		private function onTouchArrow(e: TouchEvent): void
		{
			var touch: Touch = e.getTouch(e.currentTarget as DisplayObject, TouchPhase.BEGAN);

			if (touch == null || _needScroll == true)
				return;

			if (e.currentTarget == _btnArrowLeft)
				_indexScroll--;

			if (e.currentTarget == _btnArrowRight)
				_indexScroll++;

			calcScrollPosition();
			_needScroll = true;
			e.stopImmediatePropagation();
		}

		private function updateScrollList(): void
		{
			var scale: Number = 1;
			var item: LocationItem = null;
			var posX: int = 0;
			var diff: Number = 0;
			var countOnPlace: int = 0;
			var scaleIndex: int = 0;
			var diffScroll: Number = 0;
			var isSelected: Boolean = false;
			var dir: int = 0;
			var valueScale: Number = 0;
			var index: int = 0;

			if (!_needScroll)
				return;

			_selectedItemIndex = -1;

			for (var i: int = 0, len: int = _listLocations.length; i < len; i++)
			{
				item = _listLocations[calcIndex(_indexScroll + i)];
				index = i - VIEW_ITEM_COUNT;
				isSelected = index == 0;
				dir = index >= 0 ? 1 : -1;
				posX = WIDTH_PLACE / 2 + (objItemPositions[Math.abs(index)] == null ? 0 : objItemPositions[Math.abs(index)].position * dir);
				valueScale = objItemPositions[Math.abs(index)] == null ? 0 : objItemPositions[Math.abs(index)].scale;
				scale = Math.min(valueScale - (Math.abs(((WIDTH_PLACE / 2) - item.x) / WIDTH_PLACE)), 1);
				item.scaleX = item.scaleY = scale;

				if (isSelected)
				{
					if (_scrollStartPosition == -1)
						_scrollStartPosition = Math.abs(Math.abs(posX) - Math.abs(item.x));

					diffScroll = 1 - Math.abs(Math.abs(posX) - Math.abs(item.x)) / _scrollStartPosition;
					_selectedItemIndex = calcIndex(_indexScroll + i);
					if (_onScroll != null && _needScroll) _onScroll(diffScroll, _selectedItemIndex);
				}

				diff = posX - item.x;

				if ((diff as int) >= -1 && (diff as int) <= 1)
				{
					countOnPlace++;
					item.x = posX;
				}
				else
				{
					item.x += Math.ceil(Math.abs(diff) * 0.3) * (diff < 0 ? -1 : 1);
				}

				scaleIndex = Math.max(Math.min(3 - Math.abs(index), item.parent.numChildren), 1);
				_maskPlace.addChildAt(item, scaleIndex);

				item.visible = i < (VIEW_ITEM_COUNT * 2) && i > 0;
			}

			if (countOnPlace >= _listLocations.length - 1)
			{
				if (_onChange != null) _onChange(_selectedItemIndex);
				_scrollStartPosition = -1;
				_needScroll = false;
			}
		}

		private function calcIndex(index: int): int {
			if (index >= _listLocations.length)
				return index - (_listLocations.length);
			if (index < 0)
				return (_listLocations.length - 1) + index;

			return index;
		}

		private function resize(): void
		{
			_btnArrowLeft.x = _btnArrowLeft.width / 2;
			_btnArrowLeft.y = _maskPlace.height / 2 + _btnArrowLeft.height / 2;
			_maskPlace.x = _btnArrowLeft.x;
			_btnArrowRight.x = _maskPlace.x + WIDTH_PLACE;
			_btnArrowRight.y = _btnArrowLeft.y - _btnArrowRight.height;
		}
	}
}