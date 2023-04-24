package statuses
{
	import flash.display.DisplayObject;
	import flash.text.StyleSheet;

	import game.gameData.CollectionsData;
	import statuses.Status;

	import utils.HtmlTool;

	public class StatusCollectionItem extends Status
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
				text-align: justify;
			}
			.gold {
				color: #B48000;
				font-weight: bold;
			}
			.green {
				color: #1B5B08;
				font-weight: bold;
			}
			.brown {
				color: #754E0E;
				font-weight: bold;
			}
			.center {
				text-align: center;
			}
		]]>).toString();

		static private const STATUS_WIDTH:int = 207;

		private var style:StyleSheet = null;

		public function StatusCollectionItem(owner:DisplayObject, type:int, id:int):void
		{
			super(owner, "", false, true);

			this.visible = false;

			this.style = new StyleSheet();
			style.parseCSS(CSS);

			this.field.styleSheet = style;
			this.field.width = STATUS_WIDTH - 13;

			init(type, id);
		}

		override protected function draw():void
		{
			var newHeight:int = int(this.field.textHeight) + 10;

			this.graphics.clear();
			this.graphics.lineStyle(2, 0x744C0C);
			this.graphics.beginFill(0xFFFCDB);
			this.graphics.drawRoundRectComplex(0, 0, STATUS_WIDTH, newHeight, 5, 5, 5, 5);
			this.graphics.endFill();
		}

		private function init(type:int, id:int):void
		{
			var status:String = "<body><textformat leading = '3'><span class = 'center'>";

			var titleClass:String;
			var header:String;
			var text:String;

			switch (type)
			{
				case CollectionsData.TYPE_REGULAR:
					titleClass = "green";
					header = CollectionsData.regularData[id]['tittle'];
					text = CollectionsData.regularData[id]['description'];
					break;
				case CollectionsData.TYPE_UNIQUE:
					titleClass = "gold";
					header = CollectionsData.uniqueData[id]['tittle'];
					text = CollectionsData.uniqueData[id]['description'];
					break;
				case CollectionsData.TYPE_TROPHY:
					titleClass = "brown";
					header = CollectionsData.trophyData[id]['tittle'];
					text = CollectionsData.trophyData[id]['description'];
					break;
			}

			status += HtmlTool.span(header, titleClass) + "</span><br/></textformat>";
			status += text;

			if (type == CollectionsData.TYPE_REGULAR)
				status += gls("<br/><br/><span class = 'center'>Предмет из коллеции<br/><span class = 'gold'>«{0}»</span></span>", CollectionsData.uniqueData[CollectionsData.regularData[id]['collection']]['collectionName']);
			else if (type == CollectionsData.TYPE_UNIQUE)
				status += gls("<br/><br/><span class = 'center'>Предмет с локации<br/><span class = 'gold'>«{0}»</span></span>", Locations.getLocation(CollectionsData.getLocation(id)).name);

			this.field.htmlText = status + "</body>";
			draw();
		}
	}
}