package views
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import game.mainGame.gameBattleNet.BattlePlayersList;
	import screens.ScreenGame;

	public class PlayersCountView extends Sprite
	{
		private var spriteCommon:Sprite = null;
		private var spriteBattle:Sprite = null;

		private var buttonCount:SimpleButton = null;

		private var fieldCount:GameField = null;

		private var fieldRedCount:GameField = null;
		private var fieldBlueCount:GameField = null;

		private var _battlePlayers:Sprite = null;

		public function PlayersCountView():void
		{
			initCommon();
			initBattle();
		}

		public function setSquirrels(value:int):void
		{
			show();

			this.fieldCount.text = value.toString();
		}

		public function setTeams(redTeamIds:Vector.<int>, blueTeamIds:Vector.<int>):void
		{
			if (redTeamIds == null || blueTeamIds == null)
				return;

			show(true);

			this.battlePlayers.set(redTeamIds, blueTeamIds);
			this.fieldBlueCount.text = blueTeamIds.length.toString();
			this.fieldRedCount.text = redTeamIds.length.toString();

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.battlePlayers.onKey);
			Game.stage.addEventListener(KeyboardEvent.KEY_UP, this.battlePlayers.onKey);
		}

		public function onRemove(id:int):void
		{
			if (!this.spriteBattle.visible)
				return;
			this.battlePlayers.remove(id);
			this.fieldBlueCount.text = String(this.battlePlayers.bluePlayersCount);
			this.fieldRedCount.text = String(this.battlePlayers.redPlayersCount);
		}

		public function get battlePlayers():BattlePlayersList
		{
			//TODO сделать рантайм
			if (!this._battlePlayers)
			{
				this._battlePlayers = new BattlePlayersList();
				this._battlePlayers.x = -165;
				addChild(this._battlePlayers);
			}
			return this._battlePlayers as BattlePlayersList;
		}

		public function hide():void
		{
			if (this.spriteCommon)
				this.spriteCommon.visible = false;
			if (this.spriteBattle)
				this.spriteBattle.visible = false;

			if (!this._battlePlayers)
				return;
			this.battlePlayers.hide();
			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.battlePlayers.onKey);
			Game.stage.removeEventListener(KeyboardEvent.KEY_UP, this.battlePlayers.onKey);
		}

		public function show(battle:Boolean = false):void
		{
			if (!battle && !this.spriteCommon)
				initCommon();
			if (battle && !this.spriteBattle)
				initBattle();
			if (this.spriteCommon)
				this.spriteCommon.visible = !battle;
			if (this.spriteBattle)
				this.spriteBattle.visible = battle;
		}

		private function initCommon():void
		{
			this.spriteCommon =  new Sprite();
			addChild(this.spriteCommon);

			this.buttonCount = new ButtonSquirrelCount();
			this.buttonCount.x = 35;
			this.buttonCount.y = 8;
			this.buttonCount.addEventListener(MouseEvent.CLICK, toggleResult);
			this.spriteCommon.addChild(this.buttonCount);

			this.fieldCount = new GameField("", 45, 0, new TextFormat(null, 13, 0xFFFFFF, true));
			this.spriteCommon.addChild(this.fieldCount);
		}

		private function initBattle():void
		{
			this.spriteBattle =  new Sprite();
			addChild(this.spriteBattle);

			var buttonFlag:SimpleButton = new BlueTeamCounterFlagImage();
			buttonFlag.x = 20;
			buttonFlag.addEventListener(MouseEvent.CLICK, showTeamList);
			this.spriteBattle.addChild(buttonFlag);

			buttonFlag = new RedTeamCounterFlagImage();
			buttonFlag.x = 48;
			buttonFlag.addEventListener(MouseEvent.CLICK, showTeamList);
			this.spriteBattle.addChild(buttonFlag);

			this.fieldBlueCount = new GameField("", 35, 0, new TextFormat(null, 13, 0xFFFFFF, true));
			addChild(this.fieldBlueCount);

			this.fieldRedCount = new GameField("", 63, 0, new TextFormat(null, 13, 0xFFFFFF, true));
			this.spriteBattle.addChild(this.fieldRedCount);
		}

		private function toggleResult(e:MouseEvent):void
		{
			ScreenGame.toggleResults();
		}

		private function showTeamList(e:MouseEvent):void
		{
			this.battlePlayers.show();

			e.stopImmediatePropagation();
		}
	}
}