package chat
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.StyleSheet;

	import clans.Clan;
	import clans.ClanManager;
	import events.ClanEvent;
	import menu.MenuProfile;
	import screens.ScreenGame;
	import views.ClanIconLoader;

	import com.api.Player;

	import protocol.PacketServer;

	import utils.HtmlTool;

	public class ChatDeadMessage extends Sprite
	{
		static public const MESSAGE_HEIGHT:int = 20;

		static public const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #FFFFFF;
			}
			.name {
				font-weight: bold;
			}
			a {
				text-decoration: underline;
			}
			a:hover {
				text-decoration: none;
			}
			.complain {
				text-decoration: none;
			}
			.service_message {
				color: #F7CF81;
				font-weight: bold;
			}
			.vip_message {
				color: #FEFE00;
			}
			.name_shaman {
				color: #A6DAF7;
				font-weight: bold;
			}
			.name_leader {
				color: #FF0000;
				font-weight: bold;
			}
			.name_moderator {
				color: #7CF772;
				font-weight: bold;
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

		static private const FILTERS:Array = [new DropShadowFilter(0, 0, 0x000000, 0.5, 1.5, 1.5, 7)];

		static private const BAN_COLOR:int = 0xD43838;
		static private const DEFAULT_COLOR:int = 0x000000;

		static private const LOAD_MASK:uint = PlayerInfoParser.NAME | PlayerInfoParser.MODERATOR | PlayerInfoParser.CLAN | PlayerInfoParser.EXPERIENCE | PlayerInfoParser.VIP_INFO;

		private var color:int = 0;
		private var style:StyleSheet = null;

		private var message:GameField = null;
		private var sprite:Sprite = null;

		private var banIcon:ChatBanIcon = null;

		protected var player:Player;
		protected var text:String;
		protected var clan:Boolean;
		protected var showClanIcon:Boolean;
		protected var loader:ClanIconLoader;

		public function ChatDeadMessage(player:Player, text:String, clan:Boolean = false, showClanIcon:Boolean = true):void
		{
			this.player = player;
			this.text = text;
			this.clan = clan;
			this.color = this.clan ? 0xFFF5B7 : DEFAULT_COLOR;
			this.showClanIcon = showClanIcon;

			init();

			this.player.addEventListener(ChatDeadMessage.LOAD_MASK, onPlayerLoaded);
			Game.request(this.player['id'], ChatDeadMessage.LOAD_MASK);
		}

		public function dispose():void
		{
			if (this.message)
				this.message.removeEventListener(MouseEvent.MOUSE_DOWN, onLink);
		}

		public function get isNull():Boolean
		{
			return this.text == "";
		}

		protected function onLink(e:MouseEvent):void
		{
			var obj: GameField = GameField(e.target);

			var id:int = int(obj.userData);
			if (Game.selfId == id)
				return;

			MenuProfile.showMenu(id);
		}

		protected function styleMessage(text:String):String
		{
			var name:String = styleNameLink() + " " + getLevelPlayer() + ":";

			return "<body>" + styleNameColor(name) + " " + styleTextLink(text) + "</body>";
		}

		protected function draw(changeMessage:Boolean = true):void
		{
			while (this.numChildren > 0)
				removeChildAt(0);

			if (changeMessage)
			{
				if (this.message)
					this.message.removeEventListener(MouseEvent.MOUSE_DOWN, onLink);

				while (this.sprite.numChildren > 0)
					this.sprite.removeChildAt(0);

				this.message = new GameField("", 0, 0, this.style);
				this.message.addEventListener(MouseEvent.MOUSE_DOWN, onLink, false, 0, true);
				this.message.filters = FILTERS;
				this.message.htmlText = styleMessage(this.text);
				this.message.userData = this.player.id;
				this.sprite.addChild(this.message);
			}

			this.sprite.graphics.clear();
			this.sprite.graphics.beginFill(this.color, this.banStyled ? 0.5 : 0.35);
			this.sprite.graphics.drawRoundRectComplex((this.loader && this.showClanIcon ? this.loader.x : 0) - 5, this.message.y - 2, (this.loader && this.showClanIcon ? 10 : 0) + this.message.textWidth + 14, MESSAGE_HEIGHT, 5, 5, 5, 5);
			this.sprite.graphics.endFill();
			addChild(this.sprite);

			this.banIcon.visible = this.banStyled;
			if (this.banStyled)
			{
				this.banIcon.x = this.sprite.width - 1;
				this.banIcon.y = 1;
				addChild(this.banIcon);
			}

			if (this.loader && this.showClanIcon)
			{
				this.message.x = this.loader.x + 10;
				addChild(loader);
			}
		}

		protected function onPlayerLoaded(player:Player):void
		{
			player.removeEventListener(onPlayerLoaded);

			draw();

			if (this.player['clan_id'] == 0)
				return;

			ClanManager.listen(onClanLoaded);
			ClanManager.request(this.player['clan_id']);
		}

		protected function styleNameLink():String
		{
			var name:String = this.player.name;
			if (this.player.id != Game.selfId)
				name = HtmlTool.anchor(this.player.name, "event:" + this.player.id);
			return name;
		}

		private function init():void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.sprite = new Sprite();

			this.banIcon = new ChatBanIcon();
			this.banIcon.visible = false;
		}

		private function styleNameColor(name:String = ""):String
		{
			if (!name)
				name = this.player.name + (this.player.moderator && Game.self.moderator ? "[M]" : "");

			if (this.clan && Game.self.clan_id != 0)
			{
				var clan:Clan = ClanManager.getClan(Game.self.clan_id);

				if (this.player.id == clan.leaderId)
					return HtmlTool.span(name, "name_leader");
			}

			if (ScreenGame.squirrelShaman(this.player.id))
				return HtmlTool.span(name, "name_shaman");

			if (this.player['moderator'] && !Config.isEng)
				return HtmlTool.span(name, "name_moderator");

			if (this.player['vip_exist'] > 0)
				return HtmlTool.span(name, "color" + this.player['vip_color']);

			return HtmlTool.span(name, "name");
		}

		private function getLevelPlayer():String
		{
			return "[" + Experience.getTextLevel(this.player['exp']) + "]";
		}

		private function styleTextLink(text:String):String
		{
			if (this.player['vip_exist'] > 0)
				text = HtmlTool.span(text, "vip_message");
			return "<a href = \"event:complain\"><span class = \"complain\">" + text + "</span></a>";
		}

		private function onClanLoaded(e:ClanEvent):void
		{
			if (e.clan.id != this.player['clan_id'])
				return;

			ClanManager.forget(onClanLoaded);

			if (e.clan.state != PacketServer.CLAN_STATE_SUCCESS)
				return;

			this.loader = new ClanIconLoader(e.clan.emblemLink, 0, 3);

			draw();
		}

		private function get banStyled():Boolean
		{
			return (this.color == BAN_COLOR);
		}
	}
}