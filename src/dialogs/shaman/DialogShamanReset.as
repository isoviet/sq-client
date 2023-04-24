package dialogs.shaman
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import game.gameData.ShamanTreeManager;
	import sounds.GameSounds;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.FieldUtils;

	public class DialogShamanReset extends Dialog
	{
		private var content:GameField = null;

		public function DialogShamanReset():void
		{
			super(gls("Сброс профессии"));

			this.content = new GameField(gls("Все перья будут возвращены. Ты сможешь распределить перья по навыкам заново."), 0, 10, new TextFormat(null, 14, 0x1f1f1f, null, null, null, null, null, TextFormatAlign.CENTER));
			this.content.width = 320;
			this.content.wordWrap = true;
			this.content.multiline = true;
			addChild(this.content);

			var resetButton:ButtonBase = new ButtonBase(gls("Сбросить за {0}", DiscountManager.freeShamanReset ? 0 : ShamanTreeManager.SHAMAN_RESET_PRICE) + " - ");
			resetButton.addEventListener(MouseEvent.CLICK, reset);
			place(resetButton);

			FieldUtils.replaceSign(resetButton.field, "-", ImageIconCoins, 0.7, 0.7, -resetButton.field.x + 2, -3, false, false);

			this.height = this.topOffset + this.content.y + this.content.height + this.bottomOffset + resetButton.height + 20;
			this.content.x = int((this.width - this.content.width) / 2) - this.leftOffset;
		}

		private function reset(e:MouseEvent):void
		{
			GameSounds.play("click");
			super.hide();
			if (DiscountManager.freeShamanReset)
				Connection.sendData(PacketClient.DISCOUNT_USE, DiscountManager.SHAMAN_SKILL, 0);
			else
				Game.buyWithoutPay(PacketClient.BUY_SHAMAN_BRANCH_RESET, ShamanTreeManager.SHAMAN_RESET_PRICE, 0, Game.selfId, ShamanTreeManager.currentBranch);
		}
	}
}