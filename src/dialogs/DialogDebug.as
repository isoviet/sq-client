package dialogs
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import fl.containers.ScrollPane;
	import fl.controls.CheckBox;

	import utils.InstanceCounter;
	import utils.TextFieldUtil;
	import utils.starling.collections.DisplayObjectManager;

	public class DialogDebug extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				color: #000000;
				font-size: 12px;
			}
			a {
				text-decoration: underline;
				margin-right: 0px;
			}
			a:hover {
				text-decoration: none;
			}
		]]>).toString();

		static private const FORMATS:Object = {
			'Warning':						new TextFormat(null, 12, 0xFF8000, true),
			'Error':						new TextFormat(null, 12, 0xFF0000, true),
			'Sending packet with type':				new TextFormat(null, 12, 0x008040, true),
			'Received server packet':				new TextFormat(null, 12, 0x0000FF, true),
			'[Request user info]':					new TextFormat(null, 12, 0x2FB8BB, true),
			'[Request user info direct]':				new TextFormat(null, 12, 0x2Fe8FF, true),

			' loadPhoto:true':					new TextFormat(null, 12, 0xF40006, true),
			' nocache:true':					new TextFormat(null, 12, 0xF40006, true),
			'ControllerHeroLocal.ControllerHeroLocal':		new TextFormat(null, 12, 0xF40006, true),
			'ControllerHeroLocal.remove':				new TextFormat(null, 12, 0xF40006, true),
			'SquirrelCollection':					new TextFormat(null, 12, 0x0080FF, true),
			'SquirrelGame':						new TextFormat(null, 12, 0x0080FF, true),
			'GameMap':						new TextFormat(null, 12, 0x0080FF, true),

			'GameState:':						new TextFormat(null, 12, 0x0080FF, true),
				'ROUND_START':					new TextFormat(null, 12, 0x0DFF00, true),
				'ROUND_STARTING':				new TextFormat(null, 12, 0xFFEC00, true),
				'ROUND_PLAYING':				new TextFormat(null, 12, 0xFF00F9, true),
				'ROUND_WAITING':				new TextFormat(null, 12, 0xFF00F9, true),

			'Cast':							new TextFormat(null, 12, 0x0080FF, true),
			'new Hero:':						new TextFormat(null, 12, 0xF40006, true),
			'Hero remove:':						new TextFormat(null, 12, 0xF40006, true)
		};

		static private const OFFSET_X:int = 15;
		
		private var logField:TextField = new TextField();
		private var logPane:ScrollPane = new ScrollPane();
		private var logSprite:Sprite = new Sprite();
		private var checkBox:CheckBox = new CheckBox();
		private var traceCheckBox:CheckBox = new CheckBox();
		private var traceTextureCheckBox:CheckBox = new CheckBox();

		public function DialogDebug():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.logField.width = 250;
			this.logField.multiline = true;
			this.logField.wordWrap = false;
			this.logField.mouseWheelEnabled = false;
			this.logField.autoSize = TextFieldAutoSize.LEFT;
			this.logField.embedFonts = true;
			this.logField.defaultTextFormat = new TextFormat(GameField.DEFAULT_FONT, 12);
			this.logSprite.addChild(this.logField);

			this.logPane.x = OFFSET_X;
			this.logPane.y = 15;
			this.logPane.setSize(300, 300);
			this.logPane.source = this.logSprite;
			addChild(this.logPane);

			TextFieldUtil.setStyleCheckBox(this.checkBox);
			this.checkBox.x = OFFSET_X;
			this.checkBox.y = this.logPane.y + 320;
			this.checkBox.label = gls("Авто прокрутка");
			this.checkBox.width = 300;
			addChild(this.checkBox);

			TextFieldUtil.setStyleCheckBox(this.traceCheckBox);
			this.traceCheckBox.x = OFFSET_X;
			this.traceCheckBox.y = checkBox.y + 20;
			this.traceCheckBox.label = "Trace";
			this.traceCheckBox.width = 300;
			this.traceCheckBox.selected = Logger.traceEnabled;
			this.traceCheckBox.addEventListener(MouseEvent.CLICK, onTraceClick);
			addChild(this.traceCheckBox);

			addChild(new GameField(gls("Порт: {0}", String(Config.SERVER_PORT)), 200, this.logPane.y + 322, new TextFormat(null, 12, 0x000000)));

			TextFieldUtil.setStyleCheckBox(this.traceTextureCheckBox);
			this.traceTextureCheckBox.x = 198;
			this.traceTextureCheckBox.y = checkBox.y + 20;
			this.traceTextureCheckBox.label = "Trace Texture";
			this.traceTextureCheckBox.width = 400;
			this.traceTextureCheckBox.selected = Logger.traceTextureEnabled;
			this.traceTextureCheckBox.addEventListener(MouseEvent.CLICK, onTraceTextureClick);
			addChild(this.traceTextureCheckBox);

			place();

			this.width = 370;
			this.height = 400;
			update();

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, oKey, false, 0, true);

			Logger.callBacks.push(update);
		}

		override public function show():void
		{
			Logger.add('number of texture:', DisplayObjectManager.getInstance().length);

			showDialog();

			update();
		}

		public function update(message:String = ""):void
		{
			if (!this.visible)
				return;

			if (message == "")
				this.logField.text = Logger.getMessages(500);
			else
				this.logField.appendText(message);

			updateView();
		}

		private function oKey(e:KeyboardEvent):void
		{
			if (e.altKey && e.ctrlKey && e.shiftKey && e.keyCode == Keyboard.Z)
				show();

			if (e.altKey && e.ctrlKey && e.shiftKey && e.keyCode == Keyboard.Q)
			{
				//var r:DialogIconHeader = new DialogIconHeader(null);
				//r.show();

				var r:DialogHolidayTicket = new DialogHolidayTicket();
				r.show();

				/*var r:DialogDeath = new DialogDeath();
				r.setSquirrels(new Vector.<int>());
				r.update(DialogDeath.RESPAWN_OTHER);
				r.show();*/
				/*var r:DialogWinSquirrel = new DialogWinSquirrel();
				r.setSquirrels(new Vector.<int>());
				r.updateBonus();
				r.show();*/
				/*var r:DialogWinShaman = new DialogWinShaman();
				r.setSquirrels(new Vector.<int>());
				r.show();*/

			}

			if (e.altKey && e.ctrlKey && e.shiftKey && e.keyCode == Keyboard.X)
				Logger.add(InstanceCounter.report());
		}

		private function updateView():void
		{
			this.logField.height = this.logField.textHeight + 20;
			this.logPane.update();

			hilight();

			if (this.checkBox.selected)
				this.logPane.verticalScrollBar.scrollPosition = this.logPane.verticalScrollBar.maxScrollPosition;
		}

		private function setFormat(text:String, format:TextFormat):void
		{
			var start:int = 0;
			while (true)
			{
				var index:int = this.logField.text.indexOf(text, start);
				if (index == -1)
					return;

				start = index + text.length;
				this.logField.setTextFormat(format, index, start);
			}
		}

		private function hilight():void
		{
			for (var text:String in FORMATS)
				setFormat(text, FORMATS[text]);
		}

		private function onTraceTextureClick(e: MouseEvent): void
		{
			Logger.traceTextureEnabled = this.traceTextureCheckBox.selected;
		}

		private function onTraceClick(e:MouseEvent):void
		{
			Logger.traceEnabled = this.traceCheckBox.selected;
		}
	}
}