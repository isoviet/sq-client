package statuses
{
	import flash.display.DisplayObject;

	public class StatusPerk extends Status
	{
		public function StatusPerk(owner:DisplayObject, status:String = "", bold:Boolean=false, isHtml:Boolean=false):void
		{
			super(owner, status, bold, isHtml);
		}

		override public function setStatus(data:String):void
		{
			if (this.field.htmlText == data)
				return;

			this.field.htmlText = data;
			this.field.width = this.maxWidth;
			this.field.width = this.field.textWidth + 6;

			draw();
		}
	}
}