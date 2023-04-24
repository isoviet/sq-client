package game.mainGame.gameBattleNet
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import events.ScreenEvent;
	import menu.MenuProfile;
	import screens.ScreenGame;
	import screens.Screens;
	import tape.list.ListBattlePlayersData;
	import tape.list.ListPlayersView;

	public class BattlePlayersList extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			.default {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
			}
			a {
				font-size: 11px;
				text-decoration: underline;
			}
			.bold {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
				font-weight: bold;
			}
		]]>).toString();

		static private const ROW_HEIGHT:int = 17;
		static private const SHIFT_Y:int = 33;

		private var style:StyleSheet = null;
		private var background:BattlePlayersListImage = new BattlePlayersListImage();

		private var redTeamSprite:Sprite = new Sprite();
		private var blueTeamSprite:Sprite = new Sprite();

		private var redStripeImage:RedStripeImage = null;
		private var blueStripeImage:BlueStripeImage = null;

		private var textField:GameField = null;

		private var redsData:ListBattlePlayersData = null;
		private var blueData:ListBattlePlayersData = null;

		private var tabDown:Boolean = false;

		public function BattlePlayersList():void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.graphics.beginFill(0x000000, 0);
			this.graphics.drawRect(0, 0, 480, SHIFT_Y + 5 + 100);
			this.graphics.endFill();

			this.y = -7;

			this.background.width = 350;
			this.background.y = SHIFT_Y;
			addChild(this.background);

			this.textField = new GameField("", 3, 41, this.style);
			addChild(this.textField);

			this.redTeamSprite.addChild(new GameField(gls("Красные:"), -4, 0, new TextFormat(null, 11, 0xBD0400, true)));

			this.redsData = new ListBattlePlayersData(Hero.TEAM_RED);

			var redListPlayers:ListPlayersView = new ListPlayersView();
			redListPlayers.x = 9;
			redListPlayers.y = 17;
			redListPlayers.setData(this.redsData);
			this.redTeamSprite.addChild(redListPlayers);

			this.redStripeImage = new RedStripeImage();
			this.redStripeImage.y = 17;
			this.redTeamSprite.addChild(this.redStripeImage);

			this.redTeamSprite.x = 180;
			this.redTeamSprite.y = SHIFT_Y + 25;
			addChild(this.redTeamSprite);

			this.blueTeamSprite.addChild(new GameField(gls("Синие:"), -4, 0, new TextFormat(null, 11, 0x1349A7, true)));

			this.blueData = new ListBattlePlayersData();

			var blueListPlayers:ListPlayersView = new ListPlayersView();
			blueListPlayers.x = 9;
			blueListPlayers.y = 16;
			blueListPlayers.setData(this.blueData);
			this.blueTeamSprite.addChild(blueListPlayers);

			this.blueStripeImage = new BlueStripeImage();
			this.blueStripeImage.y = 16;
			this.blueTeamSprite.addChild(this.blueStripeImage);

			this.blueTeamSprite.x = 7;
			this.blueTeamSprite.y = SHIFT_Y + 25;
			addChild(this.blueTeamSprite);

			this.visible = false;

			addEventListener(MouseEvent.ROLL_OVER, onOver);

			Screens.instance.addEventListener(ScreenEvent.SHOW, onShowScreen);
		}

		public function get redPlayersCount():int
		{
			return this.redsData.count;
		}

		public function get bluePlayersCount():int
		{
			return this.blueData.count;
		}

		public function setFrags(frags:Array):void
		{
			for each (var fragData:Array in frags)
			{
				if (!ScreenGame.squirrelExist(fragData[0]))
					continue;

				this.blueData.setPlayerFrags(fragData[0], fragData[1]);
				this.redsData.setPlayerFrags(fragData[0], fragData[1]);
			}
		}

		public function set(redIds:Vector.<int>, blueIds:Vector.<int>):void
		{
			this.redsData.setPlayers(redIds);
			this.blueData.setPlayers(blueIds);

			updateView();
		}

		public function add(id:int):void
		{
			this.redsData.addPlayer(id);

			updateView();
		}

		public function remove(id:int):void
		{
			this.redsData.removePlayer(id);
			this.blueData.removePlayer(id);

			updateView();
		}

		public function setMap(number:int):void
		{
			this.textField.text = gls("<span class='bold'>Карта № </span><span class='default'>{0}</span>", number);
		}

		public function show():void
		{
			this.visible = true;

			Game.stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		public function hide(e:Event = null):void
		{
			if (MenuProfile.isShowing())
				return;

			this.visible = false;

			removeEventListener(MouseEvent.ROLL_OUT, hide);
			Game.stage.removeEventListener(MouseEvent.CLICK, onClick);
		}

		public function onKey(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.TAB)
				return;

			if (!this.tabDown && e.type == KeyboardEvent.KEY_DOWN)
				this.visible ? hide() : show();

			this.tabDown = e.type != KeyboardEvent.KEY_UP;
		}

		private function onOver(e:MouseEvent):void
		{
			addEventListener(MouseEvent.ROLL_OUT, hide);
		}

		private function onClick(e:MouseEvent):void
		{
			if (e.target is GameField)
				return;

			if (e.target == this)
				return;

			hide();
		}

		private function onShowScreen(e:ScreenEvent):void
		{
			hide();
			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			Game.stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
		}

		private function updateView():void
		{
			this.redStripeImage.height = this.redPlayersCount * ROW_HEIGHT;
			this.blueStripeImage.height = this.bluePlayersCount * ROW_HEIGHT;

			this.background.height = this.blueTeamSprite.y + Math.max(this.redStripeImage.height, this.blueStripeImage.height) - SHIFT_Y + 24;
		}
	}
}