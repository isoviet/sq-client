package dialogs
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import events.GameEvent;
	import game.gameData.DialogOfferManager;
	import game.gameData.GameConfig;
	import game.gameData.VIPManager;
	import sounds.GameSounds;
	import statuses.Status;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;

	import utils.ColorMatrix;
	import utils.FieldUtils;
	import utils.FiltersUtil;

	public class DialogDeath extends DialogResults
	{
		static private const TEXT_FORMAT_FOR_VIP_TABLE:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0x7E5836, true, null, null, null, null, TextFormatAlign.CENTER);

		static public const RESPAWN_STATUS:int = 0;
		static public const RESPAWN_VIP_STATUS:int = 1;
		static public const RESPAWN_HARD_STATUS:int = 2;
		static public const RESPAWN_BUY_VIP_STATUS:int = 3;
		static public const RESPAWN_OTHER:int = 4;

		private const STATUSES:Array = [
			{'text': "<body>" + gls("Ты еще очень молодая белка, поэтому Шаман предлагает воскресить тебя!") + "</body>",
				'function': respawnLowLevel},
			{'text': "<body>" + gls("Ты приобрёл VIP-статус, и теперь тебе доступно бесплатное воскрешение.") + "</body>",
				'function': respawnVIP},
			{'text': "<body>" + gls("На испытаниях тебе доступно одно бесплатное воскрешение.") + "</body>",
				'function': respawnHard},
			{'text': "<body>" + gls("Купи <b>VIP-статус</b> на сутки и получи:") + "</body>"},
			{'text': "<body>" + gls("Воспользуйся магией воскрешения!") + "</body>"}
		];

		static private const CSS:String = (<![CDATA[
			body {
			font-family: "Droid Sans";
			font-size: 14px;
			color: #7E5836;
			text-align: center;
		}
		]]>).toString();

		private var respawnLayer:Sprite = null;
		private var buttonRespawn:ButtonBase = null;
		private var buttonVIP:ButtonBase = null;
		private var state:int = 0;

		private var gameVIPView:DialogVIPPart1 = null;
		private var containerForVIPView:Sprite = null;
		private var respawnText:GameField = null;
		private var lineShape:Shape = null;

		private var _isLastSquirrel:Boolean = false;

		public function DialogDeath()
		{
			super(MovieEndRoundDeath);
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = -150;
			this.rightOffset = 0;
			this.topOffset = -90;
			this.bottomOffset = 0;
		}

		override public function show():void
		{
			GameSounds.play("dialog_dead");
			super.show();
		}

		override protected function init(classHeader:Class):void
		{
			super.init(classHeader);

			//--- respawn Layer
			this.respawnLayer = new Sprite();
			this.respawnLayer.x = 0;
			this.respawnLayer.y = 125;
			addChild(this.respawnLayer);

			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.buttonRespawn = new ButtonBase(gls("Воскреснуть"), 132, 16, onDistribute);
			this.buttonRespawn.x = 210;
			this.buttonRespawn.y = 45;
			new Status(this.buttonRespawn, gls("Воскреснуть бесплатно!"));
			this.respawnLayer.addChild(this.buttonRespawn);

			this.buttonVIP = new ButtonBase(gls("Купить VIP за {0}   -", GameConfig.getVIPCoinsPrice(VIPManager.VIP_DAY)), 185, 16, buyVIP);
			this.buttonVIP.x = 15;
			this.buttonVIP.y = 45;
			new Status(this.buttonVIP, gls("Купить VIP статус"));
			this.respawnLayer.addChild(this.buttonVIP);

			FieldUtils.replaceSign(this.buttonVIP.field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonVIP.field.x + 5, -3, false, false);

			this.lineShape = new Shape();
			this.lineShape.graphics.lineStyle(2, 0xAF9E8D, 1, false);
			this.lineShape.graphics.moveTo(0,0);
			this.lineShape.graphics.lineTo(339, 0);
			this.lineShape.y = 82;
			this.lineShape.x = 11;
			this.respawnLayer.addChild(this.lineShape);

			this.respawnText = new GameField("", 43, -75, style, 270);
			this.respawnText.x = this.respawnLayer.width/2 - this.respawnText.width/2;
			this.respawnLayer.addChild(this.respawnText);

			this.containerForVIPView = new Sprite();
			this.respawnLayer.addChild(this.containerForVIPView);

			this.gameVIPView = new DialogVIPPart1();
			this.gameVIPView.x = 39;
			this.gameVIPView.y = -52;
			this.containerForVIPView.addChild(this.gameVIPView);

			var textField:GameField = new GameField("", 48, 20, style, 270);
			textField.htmlText = "<body>" + gls("и многое другое") + "</body>";
			this.containerForVIPView.addChild(textField);

			//и много других преимуществ
			textField = new GameField(gls("Одно бесплатное воскрешение на раунде"), 95, -52, TEXT_FORMAT_FOR_VIP_TABLE);
			textField.wordWrap = true;
			textField.width = 230;
			this.containerForVIPView.addChild(textField);

			textField = new GameField(gls("Макс. энергия 300\nВосполнение 2 эн./мин."), 95, -15, TEXT_FORMAT_FOR_VIP_TABLE);
			textField.wordWrap = true;
			textField.width = 230;
			this.containerForVIPView.addChild(textField);

			this.ribbonText.text = gls("твоя белочка погибла");
			this.textReward.text = gls("Но ты можешь воскреснуть!");

			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(-44, -3, -81, -94);
			this.ribbon.filters = [new ColorMatrixFilter(colorMatrix)];

			VIPManager.addEventListener(GameEvent.CHANGED, onButtonUpdate);
			onButtonUpdate(null);

			setBgHeight = 323;
		}

		override protected function set setBgHeight(value:int):void
		{
			super.setBgHeight = value;

			if(this.lineShape)
				this.lineShape.y = value - 242;
			if(this.buttonRespawn && this.buttonVIP)
				this.buttonRespawn.y = this.buttonVIP.y = value - 279;
		}

		private function onButtonUpdate(event:GameEvent = null):void
		{
			this.buttonVIP.visible = !VIPManager.haveVIP;

			this.buttonRespawn.visible = this.state != 4;
			this.buttonRespawn.x = VIPManager.haveVIP ? (DialogResults.WIDTH/2 - this.buttonRespawn.width/2) : 210;
			buttonRespawnEnable = this.state != 3 && !this._isLastSquirrel;

			this.respawnText.htmlText = STATUSES[this.state]['text'];
		}

		public function set buttonRespawnEnable(value:Boolean):void
		{
			this.buttonRespawn.enabled = value;
			this.buttonRespawn.filters = value ? [] : FiltersUtil.GREY_FILTER;
		}

		public function update(state:int):void
		{
			this.state = state;
			onButtonUpdate();

			this.topOffset = this.state != RESPAWN_BUY_VIP_STATUS ? -90 : -128;
			setBgHeight = this.state == RESPAWN_BUY_VIP_STATUS ? 323 : 280;

			this.containerForVIPView.visible = this.state == RESPAWN_BUY_VIP_STATUS;
		}

		private function onDistribute(e:MouseEvent):void
		{
			var executer:Function = STATUSES[this.state]['function'];
			if(executer != null)
				executer();
		}

		private function respawnLowLevel():void
		{
			Connection.sendData(PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_LOW_LEVEL);
		}

		private function respawnVIP():void
		{
			Connection.sendData(PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_VIP);
		}

		private function respawnHard():void
		{
			Connection.sendData(PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_FREE_HARD);
		}

		private function buyVIP(e:MouseEvent = null):void
		{
			DialogOfferManager.used(DialogOfferManager.VIP_GAME_STATUS);

			if (VIPManager.buy(VIPManager.VIP_DAY))
				VIPManager.respawnAfterBuy = true;
		}

		public function set isLastSquirrel(value:Boolean):void
		{
			_isLastSquirrel = value;
			onButtonUpdate();
		}
	}
}