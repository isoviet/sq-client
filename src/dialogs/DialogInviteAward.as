package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;

	public class DialogInviteAward extends Dialog
	{
		static private var _instance:DialogInviteAward;

		public function DialogInviteAward()
		{
			super(gls("Монеты за друга!"));

			var imageAward:CoinsForFriendImage = new CoinsForFriendImage();
			imageAward.x = -48;
			addChild(imageAward);

			var textFormat:TextFormat = new TextFormat(null, 12, 0x4A240F, true);
			textFormat.align = TextFormatAlign.CENTER;

			var textField:GameField = new GameField(gls("Твой друг принял приглашение в игру.\nТвоё вознаграждение"), 10, 5, textFormat);
			addChild(textField);

			var button:ButtonBase = new ButtonBase(gls("Забрать"));
			button.x = 90;
			button.y = 150;
			button.addEventListener(MouseEvent.CLICK, hide);
			addChild(button);

			place();

			this.width = 300;
			this.height = 230;
		}

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogInviteAward();

			_instance.show();
		}
	}
}