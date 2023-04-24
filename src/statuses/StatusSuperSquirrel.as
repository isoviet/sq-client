package statuses
{
	import flash.display.DisplayObject;
	import flash.text.StyleSheet;

	import statuses.Status;

	import utils.FieldUtils;

	public class StatusSuperSquirrel extends Status
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-size: 12px;
				color: #000000;
			}
		]]>).toString();

		public function StatusSuperSquirrel(owner:DisplayObject):void
		{
			super(owner);

			init();
		}

		private function init():void
		{
			removeChild(this.field);

			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);
			this.field = new GameField(gls("<body><b>Статус «Супер Белка»</b>\n+30 #En к максимальной энергии</body>"), 5, 2, style);
			addChild(this.field);
			FieldUtils.replaceSign(this.field, "#En", ImageEnergy, 0.8, 0.8, -6, -2, true);

			update();
		}
	}
}