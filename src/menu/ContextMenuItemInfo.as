package menu
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import clans.Clan;
	import clans.ClanManager;
	import dialogs.clan.DialogClanInfo;
	import events.ClanEvent;
	import views.ClanEmblemLoader;

	import com.api.Player;

	import protocol.PacketServer;

	import utils.PlayerUtil;
	import utils.TextFieldUtil;

	public class ContextMenuItemInfo extends Sprite
	{
		static private const CSS:String = (<![CDATA[
		body {
			font-family: "Droid Sans";
			font-size: 10px;
		}
		a {
			color: #2D200D;
			text-decoration: none;
			margin-right: 0px;
			font-weight: bold;
			text-align: center;
		}
		a:hover {
			text-decoration: underline;
		}
		]]>).toString();

		private var clanField:TextField;

		private var nameField:GameField;
		private var rankField:GameField;
		private var uidField:GameField;

		private var clanEmblem:ClanEmblemLoader;

		private var background:TitleMenuBackgroundImage;
		private var lineImage:MenuLineImage;

		private var clanId:int = -1;

		public function ContextMenuItemInfo():void
		{
			super();
			init();

			ClanManager.listen(onClanLoad);
		}

		override public function get height():Number
		{
			return this.background.height + 0.5;
		}

		override public function set height(value:Number):void
		{
			this.background.height = value;
		}

		public function setPlayer(player:Player):void
		{
			this.rankField.text = Experience.getTitle(player['level'], false);
			PlayerUtil.formatName(this.nameField, player, 130);
			this.clanField.text = "";
			this.clanField.visible = false;
			this.clanId = -1;
			this.clanEmblem.visible = false;
			TextFieldUtil.formatField(this.uidField, "ID: " + player['uid'], 140, true, true);
			this.uidField.visible = Boolean(Game.self['moderator']);

			var clan:Clan = null;
			if (player['clan_id'] != 0)
				clan = ClanManager.getClan(player['clan_id']);

			if (player['clan_id'] == 0 || (clan != null && clan.isLoaded() && clan.state != PacketServer.CLAN_STATE_SUCCESS))
			{
				this.nameField.y = 21;
				this.uidField.y = 37;
				this.background.height = 41.5 + (this.uidField.visible ? 11 : 0);
				this.lineImage.y = this.background.height;
				return;
			}

			this.nameField.y = 17;
			this.uidField.y = 49;
			this.background.height = 52.5 + (this.uidField.visible ? 11 : 0);

			this.clanId = player['clan_id'];
			this.clanEmblem.visible = true;

			this.lineImage.y = this.background.height;

			if (clan != null && clan.isLoaded() && clan.state == PacketServer.CLAN_STATE_SUCCESS)
			{
				onClanLoad(new ClanEvent(clan, true));
				return;
			}

			ClanManager.request(this.clanId);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.background = new TitleMenuBackgroundImage();
			this.background.x = 2;
			addChild(this.background);

			var nameFormat:TextFormat = new TextFormat(null, 14, 0x2D200D, true);
			var rankFormat:TextFormat = new TextFormat(null, 10, 0xAA6800, true);

			this.rankField = new GameField("", 3, 4, rankFormat);
			this.rankField.width = 140;
			this.rankField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.rankField);

			this.nameField = new GameField("", 0, 21, nameFormat);
			this.nameField.width = 140;
			this.nameField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.nameField);

			this.clanField = new TextField();
			this.clanField.x = 16;
			this.clanField.y = 36;
			this.clanField.width = 120;
			this.clanField.styleSheet = style;
			this.clanField.multiline = true;
			this.clanField.selectable = false;
			this.clanField.embedFonts = true;
			this.clanField.antiAliasType = AntiAliasType.ADVANCED;
			this.clanField.gridFitType = GridFitType.PIXEL;
			this.clanField.thickness = 100;
			this.clanField.sharpness = 0;
			addChild(this.clanField);
			this.clanField.addEventListener(MouseEvent.MOUSE_UP, onClick);

			this.clanEmblem = new ClanEmblemLoader("", 0, 38);
			addChild(this.clanEmblem);

			this.uidField = new GameField("", 0, 32, style);
			this.uidField.width = 140;
			this.uidField.autoSize = TextFieldAutoSize.CENTER;
			this.uidField.addEventListener(MouseEvent.CLICK, onUidClick);
			addChild(this.uidField);

			this.lineImage = new MenuLineImage();
			this.lineImage.y = this.background.height;
			addChild(this.lineImage);
		}

		private function onClanLoad(e:ClanEvent):void
		{
			var clan:Clan = e.clan;

			if (clan.id != this.clanId)
				return;

			if (clan.state != PacketServer.CLAN_STATE_SUCCESS && clan.state != PacketServer.CLAN_STATE_BLOCKED)
			{
				this.clanField.text = "";
				this.clanField.visible = false;
				this.clanEmblem.visible = false;

				this.nameField.y = 21;
				this.background.height = 41.5;
				this.lineImage.y = this.background.height;
				MenuProfile.update();
				return;
			}

			TextFieldUtil.formatField(this.clanField, clan.name, 120, true, true);
			this.clanField.visible = true;
			this.clanField.name = clan.id.toString();

			var bound:Rectangle = this.clanField.getCharBoundaries(0);

			this.clanEmblem.x = bound.x + this.clanField.x - 12;
			this.clanEmblem.load(clan.emblemLink);
		}

		private function onUidClick(e:MouseEvent):void
		{
			System.setClipboard(this.uidField.text.split(" ")[1]);
		}

		private function onClick(e:MouseEvent):void
		{
			DialogClanInfo.show(e.target.name);
		}
	}
}