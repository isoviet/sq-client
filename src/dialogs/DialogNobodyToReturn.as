package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	public class DialogNobodyToReturn extends Dialog
	{
		public function DialogNobodyToReturn()
		{
			super(null, false, false);

			var background:DialogNoReturnBg = new DialogNoReturnBg();
			background.closeButton.addEventListener(MouseEvent.CLICK, hide);
			addChild(background);

			var field:GameField = new GameField(gls("Верни друзей"), 0, 17, Dialog.FORMAT_CAPTION_29);
			field.filters = Dialog.FILTERS_CAPTION;
			field.x = int((background.width - field.textWidth) * 0.5);
			addChild(field);

			field = new GameField(gls("В данный момент тебе некого возвращать."), 0, 60, new TextFormat(null, 14, 0x4F3412, true));
			field.x = int((background.width - field.textWidth) * 0.5);
			addChild(field);

			place();
		}
	}
}