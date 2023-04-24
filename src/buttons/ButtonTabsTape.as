package buttons
{
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class ButtonTabsTape extends ButtonTabGroup
	{
		private var leftMargin:int;
		private var topMargin:int;

		private var offsetX:int;
		private var offsetY:int;

		private var _offset:int = 0;

		protected var numColumns:int;
		protected var numRows:int;
		protected var tabButtons:Array = [];

		protected var buttonNext:ButtonDouble = null;
		protected var buttonPrev:ButtonDouble = null;

		public function ButtonTabsTape(numRows:int, numColumns:int, leftMargin:int, topMargin:int, offsetX:int = 0, offsetY:int = 0):void
		{
			this.numColumns = numColumns;
			this.numRows = numRows;

			this.leftMargin = leftMargin;
			this.topMargin = topMargin;

			this.offsetX = offsetX;
			this.offsetY = offsetY;

			placeButtons();
		}

		override public function insert(button:ButtonTab, elements:* = null):void
		{
			super.insert(button, elements);
			this.tabButtons.push(button);
		}

		public function initButtons(buttonsScale:Number, buttonNextPos:Point, buttonPrevPos:Point, buttonNextRotation:int = 0, buttonPrevRotation:int = 0):void
		{
			this.buttonNext = new ButtonDouble(new ButtonRewindRight, new ButtonRewindRightInactive);
			this.buttonPrev = new ButtonDouble(new ButtonRewindLeft, new ButtonRewindLeftInactive);

			this.buttonNext.scaleX = buttonsScale;
			this.buttonPrev.scaleX = buttonsScale;
			this.buttonNext.scaleY = this.buttonPrev.scaleY = buttonsScale;

			this.buttonNext.x = buttonNextPos.x;
			this.buttonNext.y = buttonNextPos.y;

			this.buttonPrev.x = buttonPrevPos.x;
			this.buttonPrev.y = buttonPrevPos.y;

			this.buttonNext.rotation = buttonNextRotation;
			this.buttonPrev.rotation = buttonPrevRotation;

			placeButtons();
		}

		public function setData(_buttons:Array):void
		{
			this.tabButtons = [];
			this._offset = 0;

			for (var i:int = 0; i < _buttons.length; i++)
				insert(_buttons[i]);
			update();
		}

		public function get offset():int
		{
			return this._offset;
		}

		public function set offset(value:int):void
		{
			this._offset = value;
			if (this.tabButtons != null)
				this._offset = Math.min(this._offset, this.tabButtons.length);

			this._offset = Math.max(this._offset, 0);

			update();
		}

		protected function update():void
		{
			if (this.tabButtons == null)
				return;

			for (var i:int = this.offset; i < this.offset + this.numColumns * this.numRows; i++)
			{
				if (i > this.tabButtons.length - 1)
					break;

				if (this.tabButtons[i].sticked)
					break;
			}

			updateSprite();
			updateButtons();

			if ((i == this.offset + this.numColumns * this.numRows) || (i == this.tabButtons.length))
			{
				if ((this.offset - 1 >= 0) && this.tabButtons[this.offset - 1].sticked)
					setSelected(this.tabButtons[this.offset]);
				else
					setSelected(this.tabButtons[this.offset + this.numColumns * this.numRows - 1]);
			}
		}

		protected function updateSprite():void
		{
			if (this.tabButtons == null)
				return;

			clearSprite();

			var objects:Array = this.tabButtons;
			var maxI:int = Math.min(this.offset + this.numColumns * this.numRows, this.tabButtons.length);

			for (var i:int = this.offset, j:int = 0; i < maxI; i++, j++)
			{
				var object:ButtonTab = objects[i];

				var row:int = j % this.numRows;
				var column:int = j / this.numRows;

				object.x = (column == 0 ? 0 : (objects[i - 1].x + objects[i - 1].width + this.offsetX));
				object.y = (row == 0 ? 0 : (objects[i - 1].y + objects[i - 1].height + this.offsetY));

				addChild(object);
			}
		}

		protected function updateButtons():void
		{
			var canNext:Boolean = (this.offset + this.numColumns * this.numRows) < this.tabButtons.length;
			this.buttonNext.setState(canNext);
			this.buttonNext.visible = canNext;

			var canPrev:Boolean = this.offset > 0;
			this.buttonPrev.setState(canPrev);
			this.buttonPrev.visible = canPrev;
		}

		protected function placeButtons():void
		{
			if (!this.buttonPrev || !this.buttonNext)
				return;
			addChild(this.buttonPrev);
			addChild(this.buttonNext);
			this.buttonPrev.addEventListener(MouseEvent.CLICK, onButtonClickPrev);
			this.buttonNext.addEventListener(MouseEvent.CLICK, onButtonClickNext);
		}

		private function clearSprite():void
		{
			while (this.numChildren > 0)
				removeChildAt(0);

			addChild(this.buttonPrev);
			addChild(this.buttonNext);
		}

		private function onButtonClickNext(e:MouseEvent):void
		{

			if (this.offset + this.numColumns * this.numRows >= this.tabButtons.length)
				return;

			this.offset += 1;
		}

		private function onButtonClickPrev(e:MouseEvent):void
		{

			if (this.offset == 0)
				return;

			this.offset -= 1;
		}
	}
}