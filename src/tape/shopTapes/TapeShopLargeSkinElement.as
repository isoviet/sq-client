package tape.shopTapes
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.DialogSkinInfo;
	import events.GameEvent;
	import game.gameData.CloseoutManager;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;
	import tape.TapeSelectableObject;
	import views.PackageImageLoader;
	import views.content.PerkWidget;
	import views.widgets.RibbonEdgeView;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class TapeShopLargeSkinElement extends TapeSelectableObject
	{
		protected var icon:PackageImageLoader;

		protected var buttonBuy:ButtonBase = null;
		protected var ribbonEdgeView:RibbonEdgeView = null;

		public function TapeShopLargeSkinElement(itemId:int):void
		{
			super(itemId);
		}

		override protected function init():void
		{
			super.init();

			this.backSelected = new ElementPackageLargeBackSelected();
			this.backSelected.visible = false;
			addChild(this.backSelected);

			this.back = new ElementPackageLargeBack();
			addChild(this.back);

			var fieldTitle:GameField = new GameField(ClothesData.getPackageTitleById(this.id), 30, 5, new TextFormat(null, 16, 0x663300, true, null, null, null, null, "center"), 125);
			addChild(fieldTitle);

			this.icon = new PackageImageLoader(this.id);
			this.icon.scaleX = this.icon.scaleY = 0.8;
			this.icon.x = int((this.back.width - this.icon.width) * 0.5);
			this.icon.y = int((this.back.height - this.icon.height) * 0.5);
			addChild(this.icon);

			if (GameConfig.getPackageSkills(this.id).length > 0)
			{
				var iconPerk:PerkWidget = new PerkWidget(GameConfig.getPackageSkills(this.id)[0]);
				iconPerk.width = iconPerk.height = 30;
				iconPerk.x = 180;
				iconPerk.y = 20;
				addChild(iconPerk);
			}

			update();

			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, update);
			CloseoutManager.addEventListener(GameEvent.CLOSEOUT_START, update);
			CloseoutManager.addEventListener(GameEvent.CLOSEOUT_END, update);
		}

		protected function update(e:GameEvent = null):void
		{
			//TODO
			if (ClothesManager.packagesIds.indexOf(this.id) == -1)
			{
				if (!this.buttonBuy)
				{
					this.buttonBuy = new ButtonBase("", 80);
					this.buttonBuy.x = 60;
					this.buttonBuy.y = 200;
					this.buttonBuy.addEventListener(MouseEvent.CLICK, onBuy);
					addChild(this.buttonBuy);
				}

				this.buttonBuy.field.text = GameConfig.getPackageCoinsPrice(this.id) + " *";
				this.buttonBuy.clear();
				this.buttonBuy.redraw();
				FieldUtils.replaceSign(this.buttonBuy.field, "*", ImageIconCoins, 0.7, 0.7, -this.buttonBuy.field.x, -3, false, false);
			}
			else
			{
				if (!this.ribbonEdgeView)
				{
					this.ribbonEdgeView = new RibbonEdgeView(RibbonEdgeView.SKIN_BOUGHT);
					this.ribbonEdgeView.x = 50;
					this.ribbonEdgeView.y = 197;
					addChild(this.ribbonEdgeView);
				}
				if (this.buttonBuy)
					this.buttonBuy.visible = false;
			}
		}

		private function onBuy(e:MouseEvent):void
		{
			if (OutfitData.isBaseSkin(this.id))
				Game.buyWithoutPay(PacketClient.BUY_PACKAGE, GameConfig.getPackageCoinsPrice(this.id), 0, Game.selfId, this.id);
			else if (ClothesManager.getPackageActive(OutfitData.getBaseSkin(this.id)))
				Game.buyWithoutPay(PacketClient.BUY_SKIN, GameConfig.getPackageCoinsPrice(this.id), 0, Game.selfId, this.id);
			else
				DialogSkinInfo.show(this.id);
		}
	}
}