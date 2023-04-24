package views
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import menu.MenuProfile;

	import utils.HtmlTool;
	import utils.StringUtil;

	public class ClanDailyRatingElement extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #000000;
				font-weight: bold;
				text-decoration: underline;
			}
			a {
				font-family: "Droid Sans";
			}
			a:hover {
				text-decoration: underline;
			}
			.self {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #660000;
			}
			.bold {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #000000;
				font-weight: bold;
			}
		]]>).toString();

		public var id:int = 0;

		private var fieldNumber:GameField;
		private var fieldName:GameField;
		private var fieldSamples:GameField;
		private var fieldExp:GameField;

		public function ClanDailyRatingElement(id:int):void
		{
			this.id = id;

			init();
		}

		public function set number(value:int):void
		{
			this.fieldNumber.text = value.toString();
			this.fieldNumber.x = 5 - int(this.fieldNumber.textWidth * 0.5);
		}

		public function set playerName(value:String):void
		{
			var name:String = StringUtil.formatName(value, 175);
			if (this.id == Game.selfId)
				this.fieldName.text = "<body><span class='self'>" + HtmlTool.anchor(name, "event:" + this.id) + "</span></body>";
			else
				this.fieldName.text = "<body>" + HtmlTool.anchor(name, "event:" + this.id) + "</body>";
		}

		public function set expirience(value:int):void
		{
			this.fieldExp.text = value.toString();
			this.fieldExp.x = 250 - int(this.fieldExp.textWidth * 0.5);
		}

		public function get expirience():int
		{
			return int(this.fieldExp.text);
		}

		public function set samples(value:int):void
		{
			this.fieldSamples.text = value.toString();
			this.fieldSamples.x = 160 - int(this.fieldSamples.textWidth * 0.5);
		}

		public function get samples():int
		{
			return int(this.fieldSamples.text);
		}

		public function setData(data:Object):void
		{
			this.samples = data['samples'];
			this.expirience = data['exp'];
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var format:TextFormat = new TextFormat(null, 12, 0x000000, true);
			this.fieldNumber = new GameField("", 0, 0, format);
			addChild(this.fieldNumber);

			this.fieldName = new GameField("", 15, 0, style);
			this.fieldName.addEventListener(MouseEvent.MOUSE_DOWN, showMenu);
			addChild(this.fieldName);

			this.fieldSamples = new GameField("", 160, 0, format);
			addChild(this.fieldSamples);

			this.fieldExp = new GameField("", 250, 0, format);
			addChild(this.fieldExp);
		}

		private function showMenu(e: MouseEvent):void
		{
			var field:GameField = e.currentTarget as GameField;

			if (!field.visible)
				return;

			MenuProfile.showMenu(this.id);
		}
	}
}