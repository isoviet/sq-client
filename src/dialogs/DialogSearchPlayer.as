package dialogs
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import buttons.ButtonBase;
	import menu.MenuProfile;

	import com.api.Player;
	import com.api.PlayerEvent;

	import utils.PlayerUtil;

	public class DialogSearchPlayer extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body{
				font-family: "Droid Sans";
				font-size: 13px;
				color: #4A1901;
			}
				a {
				text-decoration: none;
				font-weight: bold;
			}
				a:hover {
				text-decoration: underline;
			}
			]]>).toString();

		private var style:StyleSheet;

		private var fieldPlayerName:GameField;
		private var fieldPlayerID:TextField = new TextField();

		private var playerId:int= 0;

		public function DialogSearchPlayer():void
		{
			super(gls("Поиск"));

			init();

			Game.listen(onPlayerLoaded);
			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, oKey, false, 0, true);
		}

		private function oKey(e:KeyboardEvent):void
		{
			if (!e || !Game.self || !Game.self.moderator)
				return;
			if (e.ctrlKey && e.keyCode == Keyboard.S)
				show();
		}

		private function init():void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			addChild(new GameField("ID:", 0, 5, new TextFormat(null, 13, 0x000000)));
			this.fieldPlayerID.x = 20;
			this.fieldPlayerID.y = 5;
			this.fieldPlayerID.width = 100;
			this.fieldPlayerID.height = 20;
			this.fieldPlayerID.type = TextFieldType.INPUT;
			this.fieldPlayerID.restrict = "[0-9]";
			this.fieldPlayerID.defaultTextFormat = new TextFormat(null, 13, 0x000000, true);
			this.fieldPlayerID.borderColor = 0xb3b3b3;
			this.fieldPlayerID.border = true;
			this.fieldPlayerID.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addChild(this.fieldPlayerID);

			addChild(new GameField(gls("Игрок:"), 0, 35, new TextFormat(null, 13, 0x000000)));
			this.fieldPlayerName = addChild(new GameField("", 50, 35, this.style)) as GameField;
			this.fieldPlayerName.addEventListener(MouseEvent.MOUSE_UP, onClick);

			var button:ButtonBase = new ButtonBase(gls("Запросить"));
			button.x = 50;
			button.y = 60;
			button.addEventListener(MouseEvent.CLICK, request);
			addChild(button);

			place();

			this.width = 250;
			this.height += 40;
		}

		private function request(event:MouseEvent):void
		{
			this.playerId = int(this.fieldPlayerID.text);
			Game.request(this.playerId, PlayerInfoParser.NAME);
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;
			this.playerId = int(this.fieldPlayerID.text);
			Game.request(this.playerId, PlayerInfoParser.NAME);
		}

		private function onClick(e:MouseEvent):void
		{
			MenuProfile.showMenu(e.target.name);
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (player.id != this.playerId)
				return;
			PlayerUtil.formatName(this.fieldPlayerName, player, 200, true, true, true);
			this.fieldPlayerName.name = player.id.toString();

			this.fieldPlayerID.text = player.id.toString();
		}
	}
}