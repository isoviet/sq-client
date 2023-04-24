package utils
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import clans.TotemsData;

	import utils.Bar;

	public class TotemExperienceBar extends Bar
	{
		private var redStarLeft:TotemRedStar = null;
		private var redStarRight:TotemRedStar = null;

		private var levelLeft:GameField = null;
		private var levelRight:GameField = null;

		public function TotemExperienceBar(progressWidth:int)
		{
			var emptyProgressBar:TotemEmptyProgressBar = new TotemEmptyProgressBar();
			emptyProgressBar.scaleX = progressWidth / emptyProgressBar.width;

			var progressBar:TotemProgressBar = new TotemProgressBar();
			progressBar.scaleX = progressWidth / progressBar.width;

			var maskProgressBar:Sprite = new Sprite();
			maskProgressBar.graphics.beginFill(0xFFFFFF);
			maskProgressBar.graphics.drawRect(0, 0, progressBar.width, progressBar.height);
			maskProgressBar.graphics.endFill();

			super([
				{'image': emptyProgressBar, 'X': 0, 'Y': 0},
				{'image': progressBar, 'X': 0, 'Y': 0},
				{'image': maskProgressBar, 'X': 0, 'Y': 0}
			], progressWidth);

			var formatLevel:TextFormat = new TextFormat(null, 9, 0xFFFFFF, true);

			this.redStarLeft = new TotemRedStar();
			this.redStarLeft.x = 0;
			this.redStarLeft.y = 5;
			addChild(this.redStarLeft);

			this.redStarRight = new TotemRedStar();
			this.redStarRight.x = progressWidth + 2;
			this.redStarRight.y = 5;
			addChild(this.redStarRight);

			this.levelLeft = new GameField("", this.redStarLeft.x - 5, this.redStarLeft.y - 4, formatLevel);
			this.levelLeft.filters = [new GlowFilter(0x5F4624, 1, 1, 2, 3.5)];
			addChild(this.levelLeft);

			this.levelRight = new GameField("", this.redStarRight.x - 5, this.redStarRight.y - 4, formatLevel);
			this.levelRight.filters = [new GlowFilter(0x5F4624, 1, 1, 2, 3.5)];
			addChild(this.levelRight);
		}

		public function setExperience(level:int, exp:int, maxExp:int):void
		{
			if (level == TotemsData.MAX_TOTEM_LEVEL)
			{
				exp = maxExp;
				level--;
			}

			super.setValues(exp, maxExp);

			this.levelLeft.text = String(level);
			this.levelLeft.x = this.redStarLeft.x - this.levelLeft.width / 2;
			this.levelRight.text = String(level + 1);
			this.levelRight.x = this.redStarRight.x - this.levelRight.width / 2;
		}
	}
}