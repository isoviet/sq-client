package tape.collectionTapes
{
	import flash.display.Sprite;

	import tape.TapeView;

	public class TapeCollectionView extends TapeView
	{
		public function TapeCollectionView(numColumns:int, numRows:int, leftMargin:int, topMargin:int, offsetX:int, offsetY:int, objectWidth:int, objectHeight:int, pagination:Boolean = false, isSnake:Boolean = true):void
		{
			super(numColumns, numRows, leftMargin, topMargin, offsetX, offsetY, objectWidth, objectHeight, pagination, isSnake);
		}

		override protected function placeButtons():void
		{}

		override protected function updateButtons():void
		{}

		override protected function updateSprite():void
		{
			if (this.data == null)
				return;

			clearSprite();

			var offset:int = (numColumns * numRows - this.data.objects.length) * (this.objectWidth + this.offsetX) * 0.5;

			var maxI:int = Math.min(this.offset + this.numColumns * this.numRows, this.data.objects.length);
			for (var i:int = this.offset, j:int = 0; i < maxI; i++, j++)
			{
				var object:Sprite = this.data.objects[i];

				if (this.isSnake)
				{
					object.x = (this.objectWidth + this.offsetX) * int((i - this.offset) % this.numColumns) + (int((i - this.offset) / this.numColumns) == (numRows - 1) ? offset : 0);
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
	}
}