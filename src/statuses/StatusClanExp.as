package statuses
{
	import flash.display.DisplayObject;
	import flash.text.StyleSheet;

	import clans.ClanExperience;
	import statuses.Status;

	public class StatusClanExp extends Status
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #1B120E;
			}
			.bold {
				font-weight: bold;
			}
		]]>).toString();

		private var max:Boolean;
		private var level:int = 0;
		private var exp:int = 0;
		private var maxExp:int = 0;
		private var dayExp:int = 0;
		private var maxDayExp:int = 0;

		public function StatusClanExp(owner:DisplayObject, exp:int, level:int, maxExp:int, dayExp:int, maxDayExp:int):void
		{
			super(owner);

			this.exp = exp;
			this.maxExp = maxExp;
			this.max = max;
			this.dayExp = dayExp;
			this.maxDayExp = maxDayExp;
			this.level = level;

			init();
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var levelText:GameField = new GameField(gls("<body>Уровень клана: <span class='bold'>{0}</span></body>", this.level), 5, 2, style);
			addChild(levelText);

			var text:String = this.level == ClanExperience.MAX_LEVEL ? gls("<body>Опыт: <span class='bold'>{0}</span></body>", this.exp) : gls("<body>Опыт: <span class='bold'>{0}/{1}</span></body>", this.exp, this.maxExp);
			var expText:GameField = new GameField(text, 5, 17, style);
			addChild(expText);

			var dayExpText:GameField = new GameField(gls("<body>Дневной лимит: <span class='bold'>{0}/{1}</span></body>", this.dayExp, this.maxDayExp), 5, 32, style);
			addChild(dayExpText);

			draw();
		}
	}
}