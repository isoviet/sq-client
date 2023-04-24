package views
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import clans.ClanExperience;
	import statuses.StatusClanExp;

	import utils.Bar;

	public class ClanExpirienceView extends Sprite
	{
		private var levelBar:Bar = null;
		private var progressField:GameField = null;
		private var expLimitView:ClanExpLimitView = null;

		private var levelField:GameField = null;
		private var status:StatusClanExp = null;

		public function ClanExpirienceView():void
		{
			super();
			init();
		}

		public function setData(exp:int, rank:int, maxRankExp:int, dailyExp:int, maxDailyExp:int):void
		{
			if (this.status != null)
				this.status.remove();

			this.status = new StatusClanExp(this, exp, rank, maxRankExp, dailyExp, maxDailyExp);

			var progress:int = exp / maxRankExp * 100;
			this.progressField.text = rank != ClanExperience.MAX_LEVEL ? progress + "%" : "100%";

			this.levelField.text = String(rank);

			var dailyLimit:Number = (exp - dailyExp + maxDailyExp) / maxRankExp;
			this.expLimitView.visible = dailyLimit <= 1;

			this.levelBar.setValues(rank != ClanExperience.MAX_LEVEL ? exp : maxRankExp, maxRankExp);

			if (dailyExp == maxDailyExp || rank == ClanExperience.MAX_LEVEL)
				this.expLimitView.x = 21 + this.levelBar.widthBar;
			else
				this.expLimitView.x = 21 + dailyLimit * (this.levelBar.width - 27);
		}

		private function init():void
		{
			var progressFormat:TextFormat = new TextFormat(null, 15, 0x4F4513, true);
			progressFormat.align = TextFormatAlign.CENTER;

			this.progressField = new GameField("", 40, 4, progressFormat);
			this.progressField.width = 136;
			this.progressField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.progressField);

			var levelFormat:TextFormat = new TextFormat(null, 14, 0x3C2B11, true);
			levelFormat.align = TextFormatAlign.CENTER;

			this.levelField = new GameField("", 185, 5, levelFormat);
			this.levelField.width = 24;
			this.levelField.autoSize = TextFieldAutoSize.CENTER;
			this.levelField.filters = [new GlowFilter(0xFFFF00, 1, 3, 3, 3)];
			addChild(this.levelField);

			this.expLimitView = new ClanExpLimitView();
			this.expLimitView.visible = false;
			this.expLimitView.y = 5;
			addChild(this.expLimitView);

			this.levelBar = new Bar([
				{'image': new BackgroundClanExpView(), 'X': 0, 'Y': 0},
				{'image': new ClanExpActiveBarImage(), 'X': 25, 'Y': 7},
				{'image': new ClanExpActiveBarImage(), 'X': 25, 'Y': 7}
			], 82, true);
			addChildAt(this.levelBar, 0);
		}
	}
}