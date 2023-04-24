package dialogs.clan
{
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import loaders.RuntimeLoader;

	import com.api.Services;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketClanState;

	import utils.EditField;
	import utils.FieldUtils;
	import utils.FiltersUtil;

	public class DialogClanCreate extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #000000;
			}
			a {
				margin-right: 0px;
				font-size: 12px;
			}
			a:hover {
				text-decoration: underline;
				color: #FF1B00;
			}
			.small {
				text-decoration: underline;
				color: #0069EC;
			}
			.center {
				text-align: center;
			}
			.cost {
				font-weight: bold;
			}
		]]>).toString();

		static private const OFFSET_X:int = 5;

		static private var _instance:DialogClanCreate = null;

		private var createButton:ButtonBase = null;

		private var nameField:EditField = null;
		private var createResultField:GameField = null;
		private var createCostField:GameField = null;

		private var _blockCreate:Boolean = false;

		public function DialogClanCreate():void
		{
			super(gls("Создать клан"));

			_instance = this;

			init();

			Connection.listen(onPacket, PacketClanState.PACKET_ID);
		}

		static public function get block():Boolean
		{
			return _instance.blockCreate;
		}

		static public function set block(value:Boolean):void
		{
			_instance.blockCreate = value;
		}

		static public function show(e:MouseEvent = null):void
		{
			if (_instance == null)
				_instance = new DialogClanCreate();
			_instance.show();
		}

		static public function hide():void
		{
			if (_instance == null || !_instance.visible)
				return;

			_instance.hide();
		}

		static public function set infoMessage(value:String):void
		{
			if (!_instance.visible)
				return;

			_instance.createResultField.text = value;
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide(e);

			this.createResultField.text = "";
			this.nameField.text = "";
			this.blockCreate = false;
		}

		private function get blockCreate():Boolean
		{
			return this._blockCreate;
		}

		private function set blockCreate(value:Boolean):void
		{
			if (this._blockCreate == value)
				return;

			this._blockCreate = value;

			this.createButton.enabled = !value;
			this.createButton.filters = value ? FiltersUtil.GREY_FILTER : [];
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.createCostField = new GameField("", OFFSET_X, 3, style);
			this.createCostField.htmlText = gls("<body>Ты можешь создать свой клан за <span class = 'cost'>{0} </span> @ </body>", this.price);
			addChild(this.createCostField);

			FieldUtils.replaceSign(this.createCostField, "@", ImageIconCoins, 0.65, 0.65, -this.createCostField.x, -this.createCostField.y, true);

			addChild(new GameField(gls("<body>Название:</body>"), OFFSET_X, 30, style));

			var nameFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 14, 0x000000, true);

			this.nameField = new EditField("", OFFSET_X + 75, 30, 188, 19, nameFormat, nameFormat, Config.NAME_MAX_LENGTH);
			this.nameField.restrict = "a-zA-Z а-яёА-ЯЁ[0-9]\-";
			addChild(this.nameField);

			this.createResultField = new GameField("", OFFSET_X, 49, new TextFormat(null, 12, 0xFF0000));
			addChild(this.createResultField);

			var descriptionField:GameField = new GameField(gls("<body><a><span class = 'center'><b>Информация о кланах</b></span><br/>Создавая свой клан, ты становишься вождем клана. Ты сможешь принимать белок в клан, выгонять, и распоряжаться казной клана.</a><br/></body>"), OFFSET_X, 105, style);
			descriptionField.width = 293;
			descriptionField.multiline = true;
			descriptionField.wordWrap = true;
			addChild(descriptionField);

			this.createButton = new ButtonBase(gls("Создать"));
			this.createButton.x = OFFSET_X + 10;
			this.createButton.y = 69;
			this.createButton.addEventListener(MouseEvent.CLICK, create);
			addChild(this.createButton);

			var cancelButton:ButtonBase = new ButtonBase(gls("Отмена"));
			cancelButton.x = OFFSET_X + 170;
			cancelButton.y = 69;
			cancelButton.addEventListener(MouseEvent.CLICK, hide);
			addChild(cancelButton);

			place();

			this.width -= 20;
			this.height = 220;
		}

		private function get price():int
		{
			return Game.CLAN_CREATE_COST;
		}

		private function create(e:MouseEvent):void
		{
			if (this.nameField.text == "")
				return;

			if (Game.balanceCoins < this.price)
			{
				hide();
				RuntimeLoader.load(function():void
				{
					Services.bank.open();
				});
				return;
			}

			this.blockCreate = true;
			Connection.sendData(PacketClient.CLAN_CREATE, this.nameField.text);
		}

		private function onPacket(packet:PacketClanState):void
		{
			switch(packet.status)
			{
				case PacketServer.CLAN_STATE_SUCCESS:
					hide();
					break;
				case PacketServer.CLAN_STATE_ERROR:
					DialogClanCreate.block = false;
					DialogClanCreate.infoMessage = gls("Клан с таким именем уже существует!\n ");
					break;
				case PacketServer.CLAN_STATE_NO_BALANCE:
					DialogClanCreate.block = false;
					DialogClanCreate.infoMessage = gls("Не удалось создать клан!");
					break;
			}
		}
	}
}