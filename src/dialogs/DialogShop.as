package dialogs
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonFooterTab;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import events.GameEvent;
	import game.gameData.EducationQuestManager;
	import tape.shopTapes.TapeShopClothes;
	import views.VIPShopView;
	import views.shop.CloseoutShopView;
	import views.shop.OtherShopView;
	import views.shop.OutfitExtendView;
	import views.shop.PackageShopView;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketBuy;

	public class DialogShop extends Dialog
	{
		static public const STOCK:int = 0;
		static public const PACKAGES:int = 1;
		static public const ACCESSORIES:int = 2;
		static public const VIP:int = 3;
		static public const OTHER:int = 4;

		static private const FORMATS:Array = [new TextFormat(GameField.PLAKAT_FONT, 18, 0x857653),
							new TextFormat(GameField.PLAKAT_FONT, 18, 0x857653),
							new TextFormat(GameField.PLAKAT_FONT, 18, 0x857653)];

		static private var _instance:DialogShop = null;
		static private var tapeToShow:int = 0;

		private var itemBought:Boolean = false;

		private var shopButtons:Vector.<ButtonTab> = new Vector.<ButtonTab>();
		private var buttonsGroup:ButtonTabGroup;

		private var outfitExtendView:OutfitExtendView = null;

		private var spriteCommon:Sprite = new Sprite();
		private var spriteDetails:Sprite = new Sprite();

		private var fieldCoins:GameField = null;
		private var fieldNuts:GameField = null;

		public function DialogShop():void
		{
			super("Магазин", false, true, null, false);

			_instance = this;

			init();

			Connection.listen(onPacket, PacketBuy.PACKET_ID);
		}

		static public function get instance():DialogShop
		{
			if (_instance == null)
				_instance = new DialogShop();
			return _instance;
		}

		static public function selectTape(tapeId:int = -1, needShow:Boolean = true):void
		{
			tapeToShow = tapeId;

			if (needShow)
				instance.show();
		}

		static public function selectOutfit(outfitId:int, packageId:int):void
		{
			instance.selectOutfit(outfitId, packageId);
		}

		static public function selectTapes():void
		{
			instance.selectTapes();
		}

		override public function hide(e:MouseEvent = null):void
		{
			if (e != null && !this.itemBought)
				Connection.sendData(PacketClient.COUNT, PacketClient.SHOP, 1);
			super.hide(e);
		}

		override public function placeInCenter(sceneWidth:Number = Config.GAME_WIDTH, sceneHeight:Number = Config.GAME_HEIGHT):void
		{}

		override public function show():void
		{
			super.show();

			if (tapeToShow != -1)
			{
				this.buttonsGroup.setSelected(this.shopButtons[tapeToShow]);
				tapeToShow = -1;
			}

			Connection.sendData(PacketClient.COUNT, PacketClient.SHOP, 0);

			this.itemBought = false;
			DiscountManager.update();

			EducationQuestManager.done(EducationQuestManager.SHOP);

			//NotificationManager.instance.saveShopData((this.dataPackages[STOCK] && this.dataPackages[STOCK].length > 0) ? this.dataPackages[STOCK][0] : 0);
		}

		override protected function effectOpen():void
		{}

		private function init():void
		{
			addChild(new DialogShopBack);

			playShowDialod = false;

			place();

			this.width = Config.GAME_WIDTH;
			this.height = Config.GAME_HEIGHT;

			this.x = 0;
			this.y = 0;

			this.fieldCaption = new GameField(gls("Магазин"), 0, 5, new TextFormat(GameField.PLAKAT_FONT, 21, 0xFFCC00));
			this.fieldCaption.x = int((Config.GAME_WIDTH - this.fieldCaption.textWidth) * 0.5);
			this.fieldCaption.filters = Dialog.FILTERS_CAPTION;
			addChild(this.fieldCaption);

			this.buttonClose.x = 870;
			this.buttonClose.y = 10;
			addChild(this.buttonClose);

			var image:ImageShopBalance = new ImageShopBalance();
			image.x = 10;
			image.y = 10;
			addChild(image);

			this.fieldCoins = new GameField("0", 62 +100, 4, new TextFormat(null, 12, 0x957351, true));
			image.addChild(this.fieldCoins);

			this.fieldNuts = new GameField("0", 62, 4, new TextFormat(null, 12, 0x957351, true));
			image.addChild(this.fieldNuts);

			updateBalance();
			Game.event(GameEvent.BALANCE_CHANGED, updateBalance);

			addChild(this.spriteCommon);
			this.spriteDetails.y = 40;
			addChild(this.spriteDetails);

			this.buttonsGroup = new ButtonTabGroup();
			this.buttonsGroup.y = 45;

			var button:ButtonTab = new ButtonTab(new ButtonFooterTab(gls("Акция"), FORMATS, ButtonTabShop, 10));
			this.buttonsGroup.insert(button, this.spriteCommon.addChild(new CloseoutShopView));
			this.shopButtons.push(button);

			button = new ButtonTab(new ButtonFooterTab(gls("Костюмы"), FORMATS, ButtonTabShop, 10));
			button.x = 180;
			this.buttonsGroup.insert(button, this.spriteCommon.addChild(new PackageShopView));
			this.shopButtons.push(button);

			button = new ButtonTab(new ButtonFooterTab(gls("Аксессуары"), FORMATS, ButtonTabShop, 10));
			button.x = 360;
			this.buttonsGroup.insert(button, this.spriteCommon.addChild(new TapeShopClothes));
			this.shopButtons.push(button);

			button = new ButtonTab(new ButtonFooterTab(gls("VIP-статус"), FORMATS, ButtonTabShop, 10));
			button.x = 540;
			this.buttonsGroup.insert(button, this.spriteCommon.addChild(new VIPShopView));
			this.shopButtons.push(button);

			button = new ButtonTab(new ButtonFooterTab(gls("Разное"), FORMATS, ButtonTabShop, 10));
			button.x = 720;
			this.buttonsGroup.insert(button, this.spriteCommon.addChild(new OtherShopView));
			this.shopButtons.push(button);

			this.spriteCommon.addChild(this.buttonsGroup);
		}

		private function selectOutfit(outfitId:int, packageId:int = -1):void
		{
			this.spriteCommon.visible = false;
			this.spriteDetails.visible = true;

			if (!this.outfitExtendView)
			{
				this.outfitExtendView = new OutfitExtendView(outfitId);
				this.spriteDetails.addChild(this.outfitExtendView);
			}
			else if (this.outfitExtendView.id != outfitId)
			{
				this.spriteDetails.removeChild(this.outfitExtendView);

				this.outfitExtendView = new OutfitExtendView(outfitId);
				this.spriteDetails.addChild(this.outfitExtendView);
			}
			if (packageId != -1)
				this.outfitExtendView.setSelect(packageId);
		}

		private function selectTapes():void
		{
			this.spriteCommon.visible = true;
			this.spriteDetails.visible = false;
		}

		private function updateBalance(e:GameEvent = null):void
		{
			if ("nuts" in Game.self)
			{
				this.fieldNuts.text = Game.self.nuts;
				this.fieldNuts.x = 59 - int(this.fieldNuts.textWidth * 0.5);
			}
			if ("coins" in Game.self)
			{
				this.fieldCoins.text = Game.self.coins;
				this.fieldCoins.x = 159 - int(this.fieldCoins.textWidth * 0.5);
			}
		}

		private function onPacket(packet:PacketBuy):void
		{
			if (packet.status ==  PacketServer.BUY_SUCCESS)
				this.itemBought = true;
		}
	}
}