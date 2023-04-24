package views
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import game.gameData.ProduceManager;

	public class GoldenCupBundle extends Sprite
	{
		protected var view:Sprite = null;
		protected var textCountGold:GameField = null;
		protected var textForDays:GameField = null;
		protected var textCountGoldInTime:GameField = null;
		protected var textEveryDay:GameField = null;

		public function GoldenCupBundle()
		{
			this.view = new ImageBundleGoldCup();

			this.textCountGold = new GameField(ProduceManager.COUNT_GOLD.toString(), 0, 0, new TextFormat(GameField.PLAKAT_FONT, 27, 0xFFFFFF, true));
			this.textForDays = new GameField(gls("за {0} дней", ProduceManager.FOR_DAYS), 0, 0, new TextFormat(GameField.PLAKAT_FONT, 12, 0xFFFFFF, true));
			this.textCountGoldInTime = new GameField("+" + ProduceManager.COUNT_GOLD_IN_TIME, 0, 0, new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF, true));
			this.textEveryDay = new GameField(gls("В день"), 0, 0, new TextFormat(GameField.PLAKAT_FONT, 15, 0xFFFFFF, true));

			addChild(this.view);
			addChild(this.textCountGold);
			addChild(this.textForDays);
			addChild(this.textCountGoldInTime);
			addChild(this.textEveryDay);

			this.textCountGold.x = 77;
			this.textCountGold.y = 62;
			this.textForDays.x = 75;
			this.textForDays.y = 95;
			this.textCountGoldInTime.rotation = 15;
			this.textCountGoldInTime.x = 63;
			this.textCountGoldInTime.y = 120;
			this.textEveryDay.rotation = -10;
			this.textEveryDay.x = 107;
			this.textEveryDay.y = 130;
		}

		public function removeFlagView():void
		{
			this.removeChild(this.textEveryDay);
			this.removeChild(this.textCountGoldInTime);
			this.view.removeChild((this.view as ImageBundleGoldCup).flag);
		}
	}
}