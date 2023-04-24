package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;

	import clans.Clan;
	import clans.ClanManager;
	import dialogs.clan.DialogClanInfo;

	import protocol.PacketServer;

	import utils.TextFieldUtil;

	public class ClanBoard extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #ffffff;
				font-weight: bold;
			}
			a {
				text-decoration: none;
			}
			a:hover {
				text-decoration: underline;
			}
		]]>).toString();

		private var clan:Clan = null;

		private var nameField:GameField;
		private var clanEmblem:ClanEmblemLoader;

		public function ClanBoard():void
		{
			init();
		}

		public function set clanId(value:int):void
		{
			if (this.clan != null)
			{
				this.clan.removeEventListener(onClanLoaded);
				this.clan = null;
			}
			if (value == 0)
			{
				this.visible = false;
				return;
			}

			this.clan = ClanManager.getClan(value);
			this.clan.addEventListener(ClanInfoParser.INFO, onClanLoaded);
			ClanManager.request(value, false, ClanInfoParser.INFO);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var iconClan:DisplayObject = new ButtonClan().upState;
			iconClan.x = 30;
			iconClan.y = 10;
			addChild(iconClan);

			this.nameField = new GameField("", 80, 0, style);
			this.nameField.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			addChild(this.nameField);

			this.clanEmblem = new ClanEmblemLoader("", 58, 0, 20);
			addChild(this.clanEmblem);
		}

		private function onClanLoaded(clan:Clan, type:uint):void
		{
			if (type && clan) {/* unused */}

			this.visible = (this.clan.state == PacketServer.CLAN_STATE_SUCCESS);

			if (this.clan.state != PacketServer.CLAN_STATE_SUCCESS)
				return;

			TextFieldUtil.formatField(this.nameField, this.clan.name, 130, true, true, this.clan.id);
			this.clanEmblem.load(this.clan.photoLink);
		}

		private function onClick(e:MouseEvent):void
		{
			DialogClanInfo.show(this.clan.id);
		}
	}
}