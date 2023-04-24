package statuses
{
	import flash.display.DisplayObject;
	import flash.text.TextFormat;

	public class StatusCollection extends Status
	{
		public function StatusCollection(owner:DisplayObject, status:String = "", bold:Boolean = false):void
		{
			super(owner, status, bold);
		}

		override protected function get baseFormat():TextFormat
		{
			return new TextFormat(null, 12, 0x754E0E, true);
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