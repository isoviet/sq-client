package dialogs
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.HtmlTool;

	public class DialogPalette extends Dialog
	{
		static public const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #FEFE00;
			}
			.color0 {
				color: #FFFFFF;
				font-weight: bold;
			}
			.color1 {
				color: #FF5A3A;
				font-weight: bold;
			}
			.color2 {
				color: #FFA800;
				font-weight: bold;
			}
			.color3 {
				color: #FFF12A;
				font-weight: bold;
			}
			.color4 {
				color: #FFC8FF;
				font-weight: bold;
			}
			.color5 {
				color: #66F2FF;
				font-weight: bold;
			}
			.color6 {
				color: #66A6FF;
				font-weight: bold;
			}
			.color7 {
				color: #EF66FF;
				font-weight: bold;
			}
		]]>).toString();

		static private var _instance:DialogPalette = null;

		private var color:int = 0;
		private var fieldExample:GameField = null;
		private var buttonsColor:Array = null;

		private var style:StyleSheet = null;

		public function DialogPalette():void
		{
			super(gls("Изменение цвета"));

			init();
		}

		static public function show(e:MouseEvent = null):void
		{
			if (!_instance)
				_instance = new DialogPalette();
			_instance.show();
		}

		static public function hide():void
		{
			if (!_instance)
				return;
			_instance.hide();
		}

		private function init():void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			addChild(new GameField(gls("Выбери цвет для имени"), 60, 0, new TextFormat(null, 14, 0x000000)));

			var palette:PaletteView = new PaletteView();
			palette.x = 5;
			palette.y = 30;
			addChild(palette);

			this.buttonsColor = [palette.button0, palette.button1, palette.button2, palette.button3,
						palette.button4, palette.button5, palette.button6, palette.button7];
			for (var i:int = 0; i < this.buttonsColor.length; i++)
				(this.buttonsColor[i] as SimpleButton).addEventListener(MouseEvent.CLICK, setColor);
			this.fieldExample = new GameField("", 5, 165, this.style);

			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0x003300, 0.18);
			mask.graphics.drawRect(palette.x, this.fieldExample.y, palette.width, 20);
			addChild(mask);
			addChild(this.fieldExample);

			var button:ButtonBase = new ButtonBase(gls("Ок"));
			button.x = 100;
			button.y = 190;
			button.addEventListener(MouseEvent.CLICK, onClick);
			addChild(button);

			place();

			this.height += 40;
		}

		private function onClick(e:MouseEvent):void
		{
			Game.self["vip_color"] = this.color;
			Connection.sendData(PacketClient.COLOR, this.color);

			hide();
		}

		private function setColor(e:MouseEvent):void
		{
			for (var i:int = 0; i < this.buttonsColor.length; i++)
			{
				if (e.currentTarget != this.buttonsColor[i])
					continue;
				this.color = i;
				break;
			}
			update();
		}

		private function update():void
		{
			this.fieldExample.text = gls("<body>{0} текст сообщения.</body>", HtmlTool.span(Game.self.name + ":", "color" + this.color));
		}

		override public function show():void
		{
			super.show();

			this.color = Game.self["vip_color"];
			update();
		}
	}
}