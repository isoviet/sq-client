package statuses
{
	import flash.display.DisplayObject;

	public class StatusClothes extends Status
	{
		public function StatusClothes(owner:DisplayObject, text:String):void
		{
			super(owner, "", false, true);

			this.maxWidth = 240;

			setStatus(text);
		}

		override protected function draw():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(2, 0x744C0C);
			this.graphics.beginFill(0xFFFCDB);
			this.graphics.drawRoundRectComplex(0, 0, this.width + 10, this.height + 4, 5, 5, 5, 5);
			this.graphics.endFill();
		}
	}
}