package tape
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import buttons.ButtonDouble;
	import tape.events.TapeDataEvent;
	import views.customUI.ScrollDotted;

	public class TapeView extends Sprite
	{
		private var pagesStatus:Boolean;
		private var byItems:Boolean;
		private var pagesTotal:int = 0;

		protected var currentPage:int = 0;
		protected var numColumns:int;
		protected var numRows:int;
		protected var leftMargin:int;
		protected var topMargin:int;
		protected var offsetX:int;
		protected var offsetY:int;
		protected var objectWidth:int;
		protected var objectHeight:int;
		protected var isSnake:Boolean;

		protected var sprite:Sprite = new Sprite();

		protected var buttonPrevious:ButtonDouble = null;
		protected var buttonRewindPrevious:ButtonDouble = null;
		protected var buttonNext:ButtonDouble = null;
		protected var buttonRewindNext:ButtonDouble = null;

		protected var _offset:int;

		protected var data:TapeData;
		public var scrollDotted:ScrollDotted = null;

		public function TapeView(numColumns:int, numRows:int, leftMargin:int, topMargin:int, offsetX:int, offsetY:int, objectWidth:int, objectHeight:int, pagination:Boolean = false, isSnake:Boolean = true, byItems:Boolean = false):void
		{
			this.numColumns = numColumns;
			this.numRows = numRows;
			this.leftMargin = leftMargin;
			this.topMargin = topMargin;
			this.offsetX = offsetX;
			this.offsetY = offsetY;
			this.objectWidth = objectWidth;
			this.objectHeight = objectHeight;
			this.isSnake = isSnake;

			this.sprite.x = this.leftMargin;
			this.sprite.y = this.topMargin;
			addChild(this.sprite);

			this.pagesStatus = pagination;
			this.byItems = byItems;

			placeButtons();
		}

		public function getData(): TapeData
		{
			return this.data;
		}

		public function get page():int
		{
			return this.currentPage;
		}

		public function set page(value:int):void
		{
			if (!this.pagesStatus || this.currentPage == value)
				return;

			this.currentPage = value;
			this.scrollDotted.setSelected(this.currentPage);
		}

		public function show():void
		{
			this.visible = true;
		}

		public function hide():void
		{
			this.visible = false;
		}

		public function get offset():int
		{
			return this._offset;
		}

		public function set offset(value:int):void
		{
			this._offset = value;
			if (this.data != null)
				this._offset = Math.min(this._offset, this.data.objects.length);

			this._offset = Math.max(this._offset, 0);

			update();
		}

		public function get count():int
		{
			return this.data.objects.length;
		}

		public function setData(data:TapeData):void
		{
			if (this.data != null)
				this.data.removeEventListener(TapeDataEvent.UPDATE, onDataUpdate);
			this.offset = 0;
			this.data = data;

			update();

			this.data.addEventListener(TapeDataEvent.UPDATE, onDataUpdate);

			if (!this.pagesStatus)
				return;

			if (this.byItems)
				this.pagesTotal = this.count;
			else
				this.pagesTotal = (this.count - 1) / (this.numColumns * this.numRows) + 1;

			if (this.scrollDotted)
				removeChild(this.scrollDotted);

			this.scrollDotted = new ScrollDotted(this.pagesTotal, this.dotSize * 2 + this.pagesTotal * this.dotSize);
			this.scrollDotted.x = this.leftMargin + int((this.numColumns * (this.objectWidth + this.offsetX) - this.offsetX - this.scrollDotted.width) * 0.5);
			this.scrollDotted.y = this.topMargin * 2 + this.numRows * (this.objectHeight + this.offsetY);
			this.scrollDotted.setSelected(0);
			this.scrollDotted.setOnChangeIndex(gotoPage);
			this.scrollDotted.visible = this.count > this.numColumns * this.numRows;
			addChild(this.scrollDotted);

			centerPagination();
		}

		protected function get dotSize():int
		{
			return 25;
		}

		public function clearSprite():void
		{
			while (this.sprite.numChildren > 0)
				this.sprite.removeChildAt(0);
		}

		protected function placeButtons():void
		{
			if (!this.buttonPrevious)
			{
				this.buttonPrevious = new ButtonDouble(new ButtonRewindLeft, new ButtonRewindLeftInactive);
				this.buttonPrevious.x = -this.buttonPrevious.width - 1;
				this.buttonPrevious.y = this.topMargin + this.numRows * (this.objectHeight + this.offsetY) * 0.5 - this.buttonPrevious.height * 0.5;
				this.buttonPrevious.visible = false;
			}

			if (!this.buttonNext)
			{
				this.buttonNext = new ButtonDouble(new ButtonRewindRight, new ButtonRewindRightInactive);
				this.buttonNext.x = this.leftMargin * 2 + this.numColumns * (this.objectWidth + this.offsetX) - this.offsetX + 1;
				this.buttonNext.y = this.topMargin + this.numRows * (this.objectHeight + this.offsetY) * 0.5 - this.buttonNext.height * 0.5;
				this.buttonNext.visible = false;
			}

			if (!this.pagesStatus)
			{
				addChild(this.buttonPrevious);
				addChild(this.buttonNext);
			}

			this.buttonPrevious.addEventListener(MouseEvent.CLICK, onButtonClickPrev);
			this.buttonNext.addEventListener(MouseEvent.CLICK, onButtonClickNext);

			if (this.buttonRewindNext == null)
				return;

			this.buttonRewindNext.addEventListener(MouseEvent.CLICK, onButtonClickRewindNext);
			addChild(this.buttonRewindNext);

			this.buttonRewindPrevious.addEventListener(MouseEvent.CLICK, onButtonClickRewindPrev);
			addChild(this.buttonRewindPrevious);
		}

		protected function centerPagination():void
		{
		}

		protected function update():void
		{
			if (this.data == null)
				return;

			for (var i:int = this.offset; i < this.offset + getMaxShow(); i++)
			{
				if (i > this.data.objects.length - 1)
					break;

				this.data.objects[i].onShow();
			}

			updateSprite();
			updateButtons();
		}

		protected function getMaxShow():int
		{
			return this.numColumns * this.numRows;
		}

		protected function updateSprite():void
		{
			if (this.data == null)
				return;

			clearSprite();

			var maxI:int = Math.min(this.offset + this.numColumns * this.numRows, this.data.objects.length);
			for (var i:int = this.offset, j:int = 0; i < maxI; i++, j++)
			{
				var object:Sprite = this.data.objects[i];

				if (this.isSnake)
				{
					object.x = (this.objectWidth + this.offsetX) * int((i - this.offset) % this.numColumns);
					object.y = (this.objectHeight + this.offsetY) * int((i - this.offset) / this.numColumns);
				}
				else
				{
					var rows:int = j % this.numRows;
					var columns:int = j / this.numRows;

					object.x = (this.objectWidth + this.offsetX) * columns;
					object.y = (this.objectHeight + this.offsetY) * rows;
				}

				this.sprite.addChild(object);
			}
		}

		protected function updateButtons():void
		{
			var canNext:Boolean = this.offset + getMaxShow() < this.data.objects.length;
			this.buttonNext.setState(canNext);
			this.buttonNext.visible = this.data.objects.length > getMaxShow();
			if (this.buttonRewindNext != null)
			{
				this.buttonRewindNext.visible = this.buttonNext.visible;
				this.buttonRewindNext.setState(canNext);
			}

			var canPrev:Boolean = this.offset > 0;
			this.buttonPrevious.setState(canPrev);
			this.buttonPrevious.visible = this.data.objects.length > getMaxShow();
			if (this.buttonRewindPrevious != null)
			{
				this.buttonRewindPrevious.visible = this.buttonPrevious.visible;
				this.buttonRewindPrevious.setState(canPrev);
			}

			if (!this.pagesStatus)
				return;

			centerPagination();
		}

		protected function gotoPage(index:int, direction:int):void
		{
			if (this.byItems)
				this.offset = Math.max(0, Math.min(index, this.count - this.numColumns * this.numRows));
			else
				this.offset = index * (this.numColumns * this.numRows);

			this.currentPage = index;
			update();
		}

		private function onDataUpdate(e:TapeDataEvent):void
		{
			update();
		}

		private function onButtonClickNext(e:MouseEvent):void
		{
			if (this.offset + getMaxShow() >= this.data.objects.length)
				return;

			this.offset += this.numRows;
		}

		private function onButtonClickPrev(e:MouseEvent):void
		{
			if (this.offset == 0)
				return;

			this.offset -= this.numRows;
		}

		private function onButtonClickRewindNext(e:MouseEvent):void
		{
			if (this.offset + getMaxShow() >= this.data.objects.length)
				return;

			this.offset += getMaxShow();
		}

		private function onButtonClickRewindPrev(e:MouseEvent):void
		{
			if (this.offset == 0)
				return;

			this.offset -= getMaxShow();
		}
	}
}