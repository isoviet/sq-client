package views.shop
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.DialogShop;
	import dialogs.DialogSkinInfo;
	import events.GameEvent;
	import game.gameData.CloseoutManager;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;
	import tape.TapeDataSelectable;
	import tape.events.TapeElementEvent;
	import tape.shopTapes.TapeShopSkinElement;
	import tape.wardrobeTapes.TapeWardrobeSkinView;
	import views.PackageImageLoader;
	import views.TemporaryClothesTimer;
	import views.content.PerkWidget;
	import views.widgets.DiscountWidget;
	import views.widgets.RibbonEdgeView;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class OutfitElementView extends Sprite
	{
		static private const FORMAT_TITLE:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0x663300, null, null, null, null, null, "center");
		static private const FORMAT_TEXT:TextFormat = new TextFormat(null, 12, 0x845B41, true);

		private var id:int = -1;
		private var extend:Boolean = false;
		private var selectId:int = 0;

		private var updated:Boolean = false;

		private var buttonRent:ButtonBase = null;
		private var buttonBuy:ButtonBase = null;
		private var buttonMore:SimpleButton = null;

		private var fieldRent:GameField = null;
		private var fieldBuy:GameField = null;
		private var fieldTitle:GameField = null;

		private var imageLoader:PackageImageLoader = null;
		private var tapeSkins:TapeWardrobeSkinView = null;

		protected var backSelected:MovieClip = null;

		protected var ribbonEdgeView:RibbonEdgeView = null;
		protected var temporaryTimer:TemporaryClothesTimer = null;
		protected var discount:DiscountWidget = null;

		public function OutfitElementView(id:int, extend:Boolean = false, instant:Boolean = true):void
		{
			this.id = id;
			this.extend = extend;

			var index:int = this.extend ? -1 : OutfitData.getSellingSkin(this.id);
			this.selectId = index == -1 ? GameConfig.getOutfitPackages(this.id)[0] : index;

			var back:ElementPackageBack = new ElementPackageBack();
			back.height = 400;
			addChild(back);

			this.backSelected = new ElementPackageBackSelectedGreen();
			this.backSelected.height = 400;
			this.backSelected.visible = false;
			addChild(this.backSelected);

			if (!this.extend && (OutfitData.newestPackages.indexOf(this.id) != -1))
			{
				var alertView:NotificationAnimationView = new NotificationAnimationView();
				alertView.x = 10;
				alertView.y = 10;
				addChild(alertView);
			}

			this.fieldTitle = new GameField(ClothesData.getPackageTitleById(this.selectId), 30, 5, FORMAT_TITLE, back.width - 60);
			addChild(this.fieldTitle);

			this.buttonMore = new ButtonShowMore();
			this.buttonMore.x = 170;
			this.buttonMore.y = 260;
			this.buttonMore.scaleX = this.buttonMore.scaleY = 2.0;
			this.buttonMore.addEventListener(MouseEvent.CLICK, showDetails);
			this.buttonMore.visible = !this.extend;
			addChild(this.buttonMore);

			this.fieldRent = new GameField(gls("На день"), 0, 0, FORMAT_TEXT);
			this.fieldRent.x = 50 - int(this.fieldRent.textWidth * 0.5);
			if (this.extend)
				addChild(this.fieldRent);

			this.buttonRent = new ButtonBase("", 80);
			this.buttonRent.x = 10;
			this.buttonRent.y = back.height - int(this.buttonRent.height * 0.5);
			this.fieldRent.y = this.buttonRent.y - 20;
			this.buttonRent.addEventListener(MouseEvent.CLICK, onRent);
			if (this.extend)
				addChild(buttonRent);

			this.fieldBuy = new GameField(gls("Навсегда"), 0, 0, FORMAT_TEXT);
			this.fieldBuy.x = (this.extend ? 160 : 105) - int(this.fieldBuy.textWidth * 0.5);
			if (this.extend)
				addChild(this.fieldBuy);

			this.buttonBuy = new ButtonBase("", 80);
			this.buttonBuy.x = this.extend ? 120 : 65;
			this.buttonBuy.y = back.height - int(this.buttonBuy.height * 0.5);
			this.fieldBuy.y = this.buttonBuy.y - 20;
			this.buttonBuy.addEventListener(MouseEvent.CLICK, onBuy);
			addChild(this.buttonBuy);

			if (!this.extend)
			{
				this.tapeSkins = new TapeWardrobeSkinView(55, 8, 2, false);
				this.tapeSkins.x = 78;
				this.tapeSkins.y = 280;
				addChild(this.tapeSkins);
			}
			else if (GameConfig.getPackageSkills(this.selectId).length > 0)
			{
				var iconPerk:PerkWidget = new PerkWidget(GameConfig.getPackageSkills(this.selectId)[0]);
				iconPerk.width = iconPerk.height = 30;
				iconPerk.x = 190;
				iconPerk.y = 20;
				addChild(iconPerk);
			}

			if (!instant)
				return;
			onShow();
		}

		public function set selected(select:Boolean):void
		{
			this.backSelected.visible = select;
		}

		public function onShow():void
		{
			if (this.updated)
				return;
			update();
			updateImage();

			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, update);
			CloseoutManager.addEventListener(GameEvent.CLOSEOUT_START, update);
			CloseoutManager.addEventListener(GameEvent.CLOSEOUT_END, update);

			if (!this.tapeSkins)
				return;

			var data:TapeDataSelectable = new TapeDataSelectable(TapeShopSkinElement);
			data.setData(GameConfig.getOutfitPackages(this.id).filter(function(item:int, index:int, parentArray:Array):Boolean
			{
				if (index || parentArray) {/*unused*/}
				return GameConfig.getPackageCoinsPrice(item) != 0;
			}));
			this.tapeSkins.setData(data);
			for (var i:int = 0; i < data.objects.length; i++)
			{
				if ((data.objects[i] as TapeShopSkinElement).id != this.selectId)
					continue;
				this.tapeSkins.select(data.objects[i] as TapeShopSkinElement);
				break;
			}
			this.tapeSkins.addEventListener(TapeElementEvent.SELECTED, onSelect);
		}

		protected function get isRented():Boolean
		{
			if (OutfitData.isBaseSkin(this.selectId))
				return ClothesManager.getPackageTime(this.selectId) != 0;
			return false;
		}

		protected function get isBought():Boolean
		{
			if (!OutfitData.isBaseSkin(this.selectId))
				return ClothesManager.packagesIds.indexOf(this.selectId) != -1;
			return !this.isRented && (ClothesManager.packagesIds.indexOf(this.selectId) != -1);
		}

		private function update(e:GameEvent = null):void
		{
			this.updated = true;

			if (e && e.type == GameEvent.CLOTHES_STORAGE_CHANGE && this.isBought)
			{
				var index:int = this.extend ? -1 : OutfitData.getSellingSkin(this.id);
				if (index != -1)
				{
					this.selectId = index;
					var data:TapeDataSelectable = this.tapeSkins.getData() as TapeDataSelectable;
					for (var i:int = 0; i < data.objects.length; i++)
					{
						if ((data.objects[i] as TapeShopSkinElement).id != this.selectId)
							continue;
						this.tapeSkins.select(data.objects[i] as TapeShopSkinElement);
						break;
					}
				}
			}

			if (this.isBought)
			{
				if (!this.ribbonEdgeView)
				{
					this.ribbonEdgeView = new RibbonEdgeView(RibbonEdgeView.SKIN_BOUGHT);
					this.ribbonEdgeView.x = 55;
					this.ribbonEdgeView.y = 380;
					addChild(this.ribbonEdgeView);
				}
				else
					this.ribbonEdgeView.visible = true;
			}
			else if (this.ribbonEdgeView)
				this.ribbonEdgeView.visible = false;

			if (this.isRented)
			{
				if (!this.temporaryTimer)
				{
					this.temporaryTimer = new TemporaryClothesTimer(this.selectId);
					this.temporaryTimer.x = 105 - int(this.temporaryTimer.width * 0.5);
					this.temporaryTimer.y = 60;
				}
				addChild(this.temporaryTimer);
			}
			else if (this.temporaryTimer && contains(this.temporaryTimer))
				removeChild(this.temporaryTimer);

			this.buttonRent.field.text = GameConfig.getOutfitRentCoinsPrice(this.id) + " *";
			this.buttonRent.clear();
			this.buttonRent.redraw();
			FieldUtils.replaceSign(this.buttonRent.field, "*", ImageIconCoins, 0.7, 0.7, -this.buttonRent.field.x, -3, false, false);

			this.buttonBuy.field.text = GameConfig.getPackageCoinsPrice(this.selectId) + " *";
			this.buttonBuy.clear();
			this.buttonBuy.redraw();
			this.buttonBuy.visible = !this.isBought;
			FieldUtils.replaceSign(this.buttonBuy.field, "*", ImageIconCoins, 0.7, 0.7, -this.buttonBuy.field.x, -3, false, false);

			this.buttonRent.visible = !this.isBought;
			this.fieldBuy.visible = !this.isBought;
			this.fieldRent.visible = !this.isBought;
			this.fieldTitle.text = ClothesData.getPackageTitleById(this.selectId);

			if (this.extend)
				return;
			if (CloseoutManager.closeoutDiscount(this.selectId) == 1)
			{
				if (this.discount)
					this.discount.visible = false;
			}
			else
			{
				if (!this.discount)
				{
					this.discount = new DiscountWidget();
					this.discount.scaleX = this.discount.scaleY = 0.8;
					this.discount.discount = CloseoutManager.DISCOUNT_TEXT;
					this.discount.x = 2;
					this.discount.y = 45;
					addChild(this.discount);
				}
			}
		}

		private function updateImage():void
		{
			if (this.imageLoader)
				removeChild(this.imageLoader);
			this.imageLoader = new PackageImageLoader(this.selectId);
			this.imageLoader.x = -51;
			this.imageLoader.y = 270 - this.imageLoader.height;
			addChild(this.imageLoader);
			addChild(this.buttonMore);

			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0xFFFFFF);
			mask.graphics.drawRect(51, 0, 210, this.imageLoader.height);
			this.imageLoader.addChild(mask);
			this.imageLoader.mask = mask;

			if (this.discount)
				addChild(this.discount);
		}

		private function onSelect(e:TapeElementEvent):void
		{
			if (this.tapeSkins.lastSticked != null)
				this.selectId = this.tapeSkins.lastSticked.id;
			else
				this.selectId = GameConfig.getOutfitPackages(this.id)[0];

			update();
			updateImage();
		}

		private function onBuy(e:MouseEvent):void
		{
			if (OutfitData.isBaseSkin(this.selectId))
				Game.buyWithoutPay(PacketClient.BUY_PACKAGE, GameConfig.getPackageCoinsPrice(this.selectId), 0, Game.selfId, this.selectId);
			else if (ClothesManager.getPackageActive(OutfitData.getBaseSkin(this.selectId)))
				Game.buyWithoutPay(PacketClient.BUY_SKIN, GameConfig.getPackageCoinsPrice(this.selectId), 0, Game.selfId, this.selectId);
			else
				DialogSkinInfo.show(this.selectId);
		}

		private function onRent(e:MouseEvent):void
		{
			Game.buyWithoutPay(PacketClient.BUY_PACKAGE_DAY, GameConfig.getOutfitRentCoinsPrice(this.id), 0, Game.selfId, this.selectId);
		}

		private function showDetails(e:MouseEvent):void
		{
			DialogShop.selectOutfit(this.id, this.selectId);
		}
	}
}