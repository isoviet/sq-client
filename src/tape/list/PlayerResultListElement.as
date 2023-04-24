package tape.list
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import clans.Clan;
	import clans.ClanManager;
	import events.ClanEvent;
	import menu.MenuProfile;
	import screens.ScreenGame;
	import tape.list.ListElement;
	import tape.list.events.ListElementEvent;
	import views.ClanIconLoader;

	import com.api.Player;

	import utils.DateUtil;
	import utils.HtmlTool;
	import utils.StringUtil;

	public class PlayerResultListElement extends ListElement
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #000000;
			}
			a {
				font-family: "Droid Sans";
			}
			a:hover {
				text-decoration: underline;
			}
			.super {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #660000;
				font-weight: bold;
			}
			.bold {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #000000;
				font-weight: bold;
			}
		]]>).toString();

		public var player:Player;

		public var initedTime:Boolean = false;

		private var _shaman:Boolean = false;
		private var _isDead:Boolean = false;
		private var _time:int = int.MAX_VALUE;
		private var _number:int = -1;

		private var background:Sprite;
		private var fieldNumber:GameField;
		private var fieldName:GameField;
		private var fieldTime:GameField;
		private var deadSprite:IsDeathIcon;
		private var clanEmblem:ClanIconLoader = null;

		public function PlayerResultListElement(player:Player):void
		{
			this.player = player;
			super();
			init();
		}

		public function get id():int
		{
			return this.player.id;
		}

		public function set number(value:int):void
		{
			if (this._number == value)
				return;

			this._number = value;
			this.fieldNumber.htmlText = "<body><span class='bold'>" + (this._number + 1).toString() + "</span>.</body>";
		}

		public function get number():int
		{
			return this._number;
		}

		public function set time(value:int):void
		{
			initedTime = true;

			if (this._time == value)
				return;

			this._time = value;
			this.fieldTime.text = DateUtil.formatTime(value);
			dispatchEvent(new ListElementEvent(ListElementEvent.CHANGED, this));
		}

		public function get time():int
		{
			return this._time;
		}

		public function set isDead(value:Boolean):void
		{
			if (this._isDead == value)
				return;

			this._isDead = value;
			this.deadSprite.visible = value;
			dispatchEvent(new ListElementEvent(ListElementEvent.CHANGED, this));
		}

		public function get isDead():Boolean
		{
			return this._isDead;
		}

		public function set shaman(value:Boolean):void
		{
			if (this._shaman == value)
				return;

			this._shaman = value;
			if (this.background.parent)
				this.background.parent.removeChild(this.background);

			if (value)
			{
				if (ScreenGame.squirrelExist(this.player.id))
				{
					switch (ScreenGame.squirrelTeam(this.player.id))
					{
						case Hero.TEAM_NONE:
						case Hero.TEAM_BLUE:
							this.background = new ListElementBlue();
							break;
						case Hero.TEAM_RED:
							this.background = new ListElementRed();
							break;
						case Hero.TEAM_BLACK:
							this.background = new ListElementBlack();
							break;
					}
				}
			}
			else
				this.background = (this.player.id == Game.selfId) ? new ListElementGreen() : new ListElementGrey();

			addChildAt(this.background, 0);

			this.fieldNumber.visible = !value;

			dispatchEvent(new ListElementEvent(ListElementEvent.CHANGED, this));
		}

		public function get shaman():Boolean
		{
			return this._shaman;
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.background = (this.player.id == Game.selfId) ? new ListElementGreen() : new ListElementGrey();
			addChild(this.background);

			this.fieldTime = new GameField("", 0, 3, new TextFormat(null, 12, 0x1B6ED6, true, null, null, null, null, "right"));
			this.fieldTime.width = 242;
			this.fieldTime.wordWrap = true;
			addChild(this.fieldTime);

			var name:String = StringUtil.formatName(this.player.name, 90);
			this.fieldName = new GameField("", 30, 2, style);
			this.fieldName.name = String(this.player.id);
			this.fieldName.addEventListener(MouseEvent.MOUSE_DOWN, showMenu);
			this.fieldName.text = "<body>" + HtmlTool.anchor(name, "event:" + this.player['id']) + " [" + Experience.getTextLevel(this.player['exp']) + "]" + "</body>";
			if (this.player.id == Game.selfId)
				this.fieldName.text = "<body><span class='bold'>" + name + "</span>" + " [" + Experience.getTextLevel(this.player['exp']) + "]" + "</body>";
			addChild(this.fieldName);

			this.deadSprite = new IsDeathIcon();
			this.deadSprite.visible = false;
			this.deadSprite.x = 225;
			this.deadSprite.y = 4;
			addChild(this.deadSprite);

			this.fieldNumber = new GameField("", 1, 2, style);
			addChild(this.fieldNumber);

			if (this.player['clan_id'] == 0)
				return;

			var clan:Clan = ClanManager.getClan(player['clan_id']);

			if (clan != null && clan.isLoaded())
			{
				this.clanEmblem = new ClanIconLoader(clan.emblemLink, 20, 5);
				addChild(this.clanEmblem);
				return;
			}

			this.clanEmblem = new ClanIconLoader("", 20, 5);
			addChild(this.clanEmblem);

			ClanManager.listen(onClanLoaded);
			ClanManager.request(this.player['clan_id']);

		}

		private function onClanLoaded(e:ClanEvent):void
		{
			if (e.clan.id != this.player['clan_id'])
				return;

			ClanManager.forget(onClanLoaded);
			this.clanEmblem.load(e.clan.emblemLink);
		}

		private function showMenu(e:MouseEvent):void
		{
			var field:GameField = e.currentTarget as GameField;

			if (!field.visible)
				return;

			MenuProfile.showMenu(this.player.id);
		}
	}
}