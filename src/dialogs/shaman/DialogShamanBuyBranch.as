package dialogs.shaman
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import game.gameData.ShamanTreeManager;
	import sounds.GameSounds;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class DialogShamanBuyBranch extends Dialog
	{
		private var content:GameField = null;
		private var branchId:int = ShamanTreeManager.EMPTY;

		private var buttonBuy:ButtonBase;

		public function DialogShamanBuyBranch():void
		{
			super(gls("Покупка профессии"));

			this.content = new GameField(gls("Ты покупаешь профессию. Набор навыков в текущей профессии будет сохранен, и ты сможешь переключаться между профессиями.\n\nПолученные перья сохранятся, и ты сможешь изучить новые способности."), 0, 10, new TextFormat(null, 14, 0x1f1f1f));
			this.content.width = 370;
			this.content.wordWrap = true;
			this.content.multiline = true;
			addChild(this.content);

			this.buttonBuy = new ButtonBase(gls("Купить за {0}", ShamanTreeManager.SHAMAN_BRANCH_PRICE) + " - ");
			this.buttonBuy.addEventListener(MouseEvent.CLICK, buy);
			place(this.buttonBuy);

			FieldUtils.replaceSign(this.buttonBuy.field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonBuy.field.x, -3, false, false);

			this.height = this.topOffset + this.content.y + this.content.height + this.bottomOffset + this.buttonBuy.height + 20;
			this.content.x = int((this.width - this.content.width) / 2) - this.leftOffset;
		}

		public function set branch(id:int):void
		{
			this.branchId = id;
			this.content.text = gls("Ты покупаешь профессию «{0}». Набор навыков в текущей профессии будет сохранен, и ты сможешь переключаться между профессиями.\n\nПолученные перья сохранятся, и ты сможешь изучить новые способности.", ShamanTreeManager.BRANCH_TYPES[this.branchId]);

			this.height = this.topOffset + this.content.y + this.content.height + this.bottomOffset + this.buttonBuy.height + 20;
			this.content.x = int((this.width - this.content.width) / 2) - this.leftOffset;
		}

		private function buy(e:MouseEvent):void
		{
			GameSounds.play("click");
			Game.buyWithoutPay(PacketClient.BUY_SHAMAN_BRANCH, ShamanTreeManager.SHAMAN_BRANCH_PRICE, 0, Game.selfId, this.branchId);
			super.hide();
		}
	}
}