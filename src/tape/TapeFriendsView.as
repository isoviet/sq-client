package tape
{
	import buttons.ButtonDouble;

	public class TapeFriendsView extends TapeView
	{
		static public const MAX_SHOW:int = 12;

		public function TapeFriendsView():void
		{
			super(0, 1, 115, 7, 8, 0, 55, 60);
		}

		override public function set offset(value:int):void
		{
			this._offset = value;

			if (this.data != null)
				this._offset = Math.min(this._offset, this.data.objects.length - MAX_SHOW);
			this._offset = Math.max(this._offset, 0);

			update();
		}

		override protected function placeButtons():void
		{
			this.buttonPrevious = new ButtonDouble(new ButtonRewindLeft, new ButtonRewindLeftInactive);
			this.buttonRewindPrevious = new ButtonDouble(new ButtonRewindLeftDouble, new ButtonRewindLeftDoubleInactive);
			this.buttonNext = new ButtonDouble(new ButtonRewindRight, new ButtonRewindRightInactive);
			this.buttonRewindNext = new ButtonDouble(new ButtonRewindRightDouble, new ButtonRewindRightDoubleInactive);

			this.buttonPrevious.setState(true);
			this.buttonRewindPrevious.setState(true);
			this.buttonNext.setState(true);
			this.buttonRewindNext.setState(true);

			this.buttonPrevious.x = 85;
			this.buttonPrevious.y = 7;

			this.buttonRewindPrevious.x = 85;
			this.buttonRewindPrevious.y = 38;

			this.buttonNext.x = 870;
			this.buttonNext.y = 7;

			this.buttonRewindNext.x = 870;
			this.buttonRewindNext.y = 38;

			super.placeButtons();
		}

		override protected function getMaxShow():int
		{
			return MAX_SHOW;
		}

		override protected function updateSprite():void
		{
			if (this.data == null)
				return;

			clearSprite();

			for (var i:int = this.offset; i < this.offset + MAX_SHOW; i++)
			{
				if (i > this.data.objects.length - 1)
					return;

				var object:TapeObject = this.data.objects[i];
				object.x = (this.objectWidth + this.offsetX) * (i - this.offset);
				object.y = 0;
				this.sprite.addChild(object);
			}
		}
	}
}