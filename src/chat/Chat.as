package chat
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.Screens;
	import sounds.GameSounds;

	import com.api.Player;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketBan;

	import utils.TextFieldUtil;

	public class Chat extends ChatBase
	{
		private var direction:TextField = new TextField();
		private var inputBackground:MovieClip = null;

		private var chatType:int = PacketClient.CHAT_ROOM;

		public function Chat():void
		{
			super();

			Game.stage.addEventListener(KeyboardEvent.KEY_UP, inputKey);
			Game.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onHide);

			Connection.listen(onPacket, PacketBan.PACKET_ID);
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
		}

		private function _onHide(event:MouseEvent):void
		{
			var _chat:Chat = event.target.parent as Chat;
			if(_chat == null && this.visible == true) hide();
		}

		private function onChangeScreenSize(e: Event = null): void
		{
			this.x = Game.starling.stage.stageWidth / 2 - this.inputBackground.width / 2;
			this.y = Game.starling.stage.stageHeight - 5 - this.height;
		}

		public function show():void
		{
			this.visible = true;

			onChangeScreenSize();

			if (this.blockChat)
				return;

			this.inputBox.type = TextFieldType.INPUT;
			Game.stage.focus = this.inputBox;
		}

		public function hide():void
		{
			this.visible = false;

			if (this.blockChat)
				return;

			this.inputBox.type = TextFieldType.DYNAMIC;
			this.inputBox.text = "";
			Game.stage.focus = Game.stage;
		}

		public function toggle():void
		{
			if (this.visible)
				hide();
			else
				show();
		}

		public function hasFocus():Boolean
		{
			return (Game.stage.focus == this.inputBox && this.inputBox.type == TextFieldType.INPUT);
		}

		override protected function onKeyDown(e:KeyboardEvent):void
		{}

		override protected function processMessage(text:String):void
		{
			super.processMessage(text);
			hide();
		}

		override protected function sendMessage(message:String):void
		{
			if (this.blockChat || (Screens.active is ScreenLearning))
				return;

			Connection.sendData(PacketClient.CHAT_MESSAGE, this.chatType, message);
			GameSounds.play("message_send");
		}

		override protected function init():void
		{
			this.inputBackground = new BackgroundInputBox();
			this.inputBackground.x = 0;
			this.inputBackground.y = 0;
			addChild(this.inputBackground);

			this.inputFormat = new TextFormat(GameField.DEFAULT_FONT, 13, 0x000000);

			this.direction.x = 0;
			this.direction.y = 3;
			this.direction.selectable = false;
			this.direction.autoSize = TextFieldAutoSize.LEFT;
			this.direction.defaultTextFormat = this.inputFormat;
			TextFieldUtil.embedFonts(this.direction);
			addChild(this.direction);

			this.direction.text = " > ";

			this.inputFormat.indent = this.direction.textWidth - 15;

			this.inputBox = new TextField();
			this.inputBox.x = 14;
			this.inputBox.y = 3;
			this.inputBox.width = 240;
			this.inputBox.height = 65;
			TextFieldUtil.embedFonts(this.inputBox);
			addChild(this.inputBox);

			super.init();

			hide();
		}

		private function inputKey(e:KeyboardEvent):void
		{
			if (!(Screens.active is ScreenGame || Screens.active is ScreenLearning))
				return;

			if (!this.visible)
			{
				if (e.keyCode == Keyboard.ENTER)
					show();
				return;
			}

			if (e.keyCode == Keyboard.DELETE || e.keyCode == Keyboard.ENTER && this.blockChat)
			{
				hide();
				return;
			}

			super.onKeyDown(e);
		}

		private function onPacket(packet: PacketBan):void
		{
			if ((Game.selfId != packet.targetId) && (Game.selfId != packet.moderatorId) && !Game.self['moderator'])
				return;

			var player:Player = Game.getPlayer(packet.targetId);
			var moderator:Player = (packet.moderatorId != 0) ? Game.getPlayer(packet.moderatorId) : null;

			ChatDead.instance.sendBanMessage(player, moderator, packet.duration, packet.type, packet.reason);
		}
	}
}