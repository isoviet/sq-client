package statuses
{
	import flash.display.DisplayObject;
	import flash.text.StyleSheet;

	import clans.Clan;
	import clans.ClanManager;
	import clans.TotemsData;
	import statuses.Status;

	public class StatusTotem extends Status
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

		private var status:String = null;
		private var max:int = 0;
		private var current:int = 0;
		private var id:int = 0;
		private var totemLevel:int = 0;

		public function StatusTotem(owner:DisplayObject, status:String, id:int, totemLevel:int, current:int, max:int)
		{
			super(owner);
			this.max = max;
			this.current = current;
			this.id = id;
			this.totemLevel = totemLevel;
			this.status = status;

			init();
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var statusText:GameField = new GameField("<body>" + this.status + "</body>", 5, 2, style);
			addChild(statusText);

			if (this.totemLevel == TotemsData.MAX_TOTEM_LEVEL)
			{
				var maxLevelText:GameField = new GameField(gls("<body><span class='bold'>Достигнут максимальный уровень тотема.</span></body>"), 5, statusText.y + statusText.textHeight + 2, style);
				addChild(maxLevelText);
			}
			else
			{
				var expText:GameField = new GameField("<body><span class='bold'>" + this.current + "/" + this.max + "</span></body>", 5, statusText.y + statusText.textHeight + 2, style);
				addChild(expText);

				var clan:Clan = ClanManager.getClan(Game.selfId);
				var level:int = TotemsData.getNextLevel(this.id, this.totemLevel);

				if (clan.level < level)
				{
					var requiredLevel:GameField = new GameField(gls("<body>Требуется: <span class='bold'>{0}</span> уровень клана</body>", level), 5, expText.y + expText.textHeight + 2, style);
					addChild(requiredLevel);
				}
			}

			draw();
		}
	}
}