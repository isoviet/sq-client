package dialogs.shaman
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import game.mainGame.perks.shaman.PerkShamanFactory;
	import sounds.GameSounds;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class DialogShamanBuySkill extends Dialog
	{
		private var content:GameField = null;
		private var skillId:int = -1;
		private var goldCost:int = 0;

		private var buttonBuy:ButtonBase;
		private var buyField:GameField;

		public function DialogShamanBuySkill():void
		{
			super(gls("Изучение навыка"));

			this.content = new GameField(gls("Ты собираешься выучить 4-й уровень навыка!"), 0, 10, new TextFormat(null, 14, 0x1f1f1f, null, null, null, null, null, TextFormatAlign.CENTER));
			this.content.width = 300;
			this.content.wordWrap = true;
			this.content.multiline = true;
			addChild(this.content);

			this.buttonBuy = new ButtonBase("");
			this.buttonBuy.addEventListener(MouseEvent.CLICK, buy);
			place(this.buttonBuy);

			this.buyField = new GameField("", 0, 0, new TextFormat(null, 14, 0x000000, true));
			this.buyField.mouseEnabled = false;
			addChild(this.buyField);

			this.height = this.topOffset + this.content.y + this.content.height + this.bottomOffset + this.buttonBuy.height + 20;
			this.content.x = int((this.width - this.content.width) / 2) - this.leftOffset;
		}

		public function set skill(id:int):void
		{
			this.skillId = id;
			this.content.text = gls("Ты собираешься выучить 4-й уровень навыка «{0}».", PerkShamanFactory.perkData[PerkShamanFactory.getClassById(id)]['name']);

			this.height = this.topOffset + this.content.y + this.content.height + this.bottomOffset + this.buttonBuy.height + 20;
			this.content.x = int((this.width - this.content.width) / 2) - this.leftOffset;
		}

		public function set cost(goldCost:int):void
		{
			this.goldCost = goldCost;

			this.buttonBuy.field.text = gls("Выучить за {0}", this.goldCost) + " - ";
			this.buttonBuy.redraw();
			this.buttonBuy.x = this.content.x + int((this.content.width - this.buttonBuy.width) * 0.5);
			FieldUtils.replaceSign(this.buttonBuy.field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonBuy.field.x, -3, false, false);
		}

		private function buy(e:MouseEvent):void
		{
			GameSounds.play("click");
			Game.buy(PacketClient.BUY_SHAMAN_SKILL, this.goldCost, 0, Game.selfId, this.skillId);
			super.hide();
		}
	}
}