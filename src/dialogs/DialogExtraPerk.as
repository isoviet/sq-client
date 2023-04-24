package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import events.GameEvent;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import tape.TapeDataSelectable;
	import tape.TapeSelectableObject;
	import tape.TapeSelectableView;
	import tape.events.TapeElementEvent;
	import tape.perksTapes.TapePerkSelectableElement;
	import tape.wardrobeTapes.TapeWardrobeSkinElement;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.FieldUtils;

	public class DialogExtraPerk extends Dialog
	{
		static private var _instance:DialogExtraPerk = null;

		private var packageId:int = 0;
		private var tapePerk:TapeSelectableView = null;

		private var fieldTitle:GameField = null;
		private var fieldText:GameField = null;

		private var buttonUse:ButtonBase = null;
		private var buttonBuy:ButtonBase = null;

		private var imagePerk:DisplayObject = null;
		private var back:DisplayObject = null;

		private var spriteBuy:Sprite = null;
		private var imagePackage:DisplayObject = null;

		static public function show(packageId:int):void
		{
			if (!_instance)
				_instance = new DialogExtraPerk();
			_instance.setPackage(packageId);
			_instance.show();
		}

		public function DialogExtraPerk()
		{
			super(gls("Книга заклинаний"), true, true, null, false);

			init();

			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, onChange);
		}

		override protected function get captionFormat():TextFormat
		{
			return FORMAT_CAPTION_23_CENTER;
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 5;
			this.rightOffset = 5;
			this.topOffset = 10;
			this.bottomOffset = 0;
		}

		private function init():void
		{
			this.back = new DialogExtraPerkBack();
			addChild(this.back);

			this.fieldTitle = new GameField("", 520, 0, new TextFormat(GameField.DEFAULT_FONT, 20, 0x663300, true, null, null, null, null, "center"), 290);
			addChild(this.fieldTitle);

			this.fieldText = new GameField("", 520, 225, new TextFormat(GameField.DEFAULT_FONT, 12, 0x663300, false, null, null, null, null, "center"), 290);
			addChild(this.fieldText);

			this.buttonUse = new ButtonBase(gls("Применить"));
			this.buttonUse.x = 520 + int((290 - this.buttonUse.width) * 0.5);
			this.buttonUse.y = 300;
			this.buttonUse.visible = false;
			this.buttonUse.addEventListener(MouseEvent.CLICK, select);
			addChild(this.buttonUse);

			this.buttonBuy = new ButtonBase("");
			this.buttonBuy.x = 520 + int((290 - this.buttonBuy.width) * 0.5);
			this.buttonBuy.y = 300;
			this.buttonBuy.visible = false;
			this.buttonBuy.addEventListener(MouseEvent.CLICK, buy);
			addChild(this.buttonBuy);

			this.spriteBuy = new Sprite();
			this.spriteBuy.x = 520;
			this.spriteBuy.y = 340;
			this.spriteBuy.visible = false;
			this.spriteBuy.addChild(new GameField(gls("Для доступа к магии необходим костюм:"), 0, 0, new TextFormat(GameField.DEFAULT_FONT, 12, 0x663300, false, null, null, null, null, "center"), 290));
			addChild(this.spriteBuy);

			place();

			this.height += 40;
			this.buttonClose.x -= 10;
			this.fieldCaption.y -= 5;
		}

		public function setPackage(value:int):void
		{
			this.packageId = value;

			update();
		}

		private function update():void
		{
			var outfitId:int = OutfitData.packageToOutfit(this.packageId);
			var perkIds:Array = [];
			for (var i:int = 0; i < GameConfig.outfitCount; i++)
			{
				if (OutfitData.shaman_outfits.indexOf(i) != -1)
					continue;
				if (i == outfitId)
					continue;
				perkIds = perkIds.concat(OutfitData.getPerksByOutfit(i));
			}
			perkIds = perkIds.filter(OutfitData.filterPerkBuyableOrSelf);

			if (this.tapePerk)
				removeChild(this.tapePerk);

			this.tapePerk = new TapeSelectableView(6, 6, 0, 15, 20, 20, 40, 40, true, true);
			this.tapePerk.x = 90;
			this.tapePerk.y = 15;
			var data:TapeDataSelectable = new TapeDataSelectable(TapePerkSelectableElement);
			data.setData(perkIds);
			this.tapePerk.setData(data);
			this.tapePerk.addEventListener(TapeElementEvent.SELECTED, onSelect);
			addChild(this.tapePerk);

			var currentId:int = ClothesManager.getPackageExtraSkill(this.packageId);
			if (currentId != 0)
				for each (var tapeElement:TapeSelectableObject in this.tapePerk.getData().objects)
				{
					if (tapeElement.id != currentId)
						continue;
					this.tapePerk.select(tapeElement);
					(tapeElement as TapePerkSelectableElement).active = true;
					break;
				}

			this.tapePerk.scrollDotted.buttonLeft.visible = false;
			this.tapePerk.scrollDotted.buttonLeft = (this.back as DialogExtraPerkBack).buttonPrev;
			this.tapePerk.scrollDotted.buttonLeft.addEventListener(MouseEvent.CLICK, this.tapePerk.scrollDotted.onScroll);

			this.tapePerk.scrollDotted.buttonRight.visible = false;
			this.tapePerk.scrollDotted.buttonRight = (this.back as DialogExtraPerkBack).buttonNext;
			this.tapePerk.scrollDotted.buttonRight.addEventListener(MouseEvent.CLICK, this.tapePerk.scrollDotted.onScroll);
		}

		private function onChange(e:GameEvent):void
		{
			this.tapePerk.select(this.tapePerk.lastSticked);

			for each (var tapeElement:TapePerkSelectableElement in this.tapePerk.getData().objects)
				tapeElement.updateIcon();
		}

		private function onSelect(e:TapeElementEvent):void
		{
			if (this.tapePerk.lastSticked == null)
				return;

			this.fieldTitle.text = PerkClothesFactory.getName(this.tapePerk.lastSticked.id);
			this.fieldText.text = PerkClothesFactory.getDescription(this.tapePerk.lastSticked.id);

			if (this.imagePerk)
				removeChild(this.imagePerk);
			this.imagePerk = PerkClothesFactory.getNewImage(this.tapePerk.lastSticked.id);
			this.imagePerk.width = this.imagePerk.height = 95;
			this.imagePerk.x = int(620 + this.imagePerk.width * 0.5);
			this.imagePerk.y = int(77 + this.imagePerk.height * 0.5);
			addChild(this.imagePerk);

			var packageId:int = OutfitData.perkToPackage(this.tapePerk.lastSticked.id);
			var baseId:int = OutfitData.getBaseSkin(packageId);
			var isBought:Boolean = ClothesManager.haveItem(baseId, ClothesManager.KIND_PACKAGES) && ClothesManager.haveItem(packageId, ClothesManager.KIND_PACKAGES);
			var isBlock:Boolean = !ClothesManager.haveItem(baseId, ClothesManager.KIND_PACKAGES) && ClothesManager.haveItem(packageId, ClothesManager.KIND_PACKAGES);

			this.buttonUse.visible = isBought;
			this.buttonBuy.visible = !isBought;
			this.spriteBuy.visible = !isBought;

			if (isBlock)
				packageId = baseId;

			if (this.buttonBuy.visible)
			{
				this.buttonBuy.clear();
				this.buttonBuy.field.text = gls("Купить за {0}", GameConfig.getPackageCoinsPrice(packageId)) + " - ";
				this.buttonBuy.redraw();
				this.buttonBuy.x = 520 + int((290 - this.buttonBuy.width) * 0.5);
				FieldUtils.replaceSign(this.buttonBuy.field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonBuy.field.x, -3, false, false);
			}

			if (this.spriteBuy.visible)
			{
				if (this.imagePackage)
					this.spriteBuy.removeChild(this.imagePackage);
				this.imagePackage = new TapeWardrobeSkinElement(packageId);
				this.imagePackage.x = 115;
				this.imagePackage.y = 20;
				this.spriteBuy.addChild(this.imagePackage);
			}
		}

		private function select(e:MouseEvent):void
		{
			Connection.sendData(PacketClient.CLOTHES_SET_SLOT, this.packageId, this.tapePerk.lastSticked.id);
			hide();
		}

		private function buy(e:MouseEvent):void
		{
			var packageId:int = OutfitData.perkToPackage(this.tapePerk.lastSticked.id);
			var baseId:int = OutfitData.getBaseSkin(packageId);

			if (!ClothesManager.haveItem(baseId, ClothesManager.KIND_PACKAGES) && ClothesManager.haveItem(packageId, ClothesManager.KIND_PACKAGES))
				packageId = baseId;

			if (OutfitData.isBaseSkin(packageId))
				Game.buyWithoutPay(PacketClient.BUY_PACKAGE, GameConfig.getPackageCoinsPrice(packageId), 0, Game.selfId, packageId);
			else if (ClothesManager.getPackageActive(OutfitData.getBaseSkin(packageId)))
				Game.buyWithoutPay(PacketClient.BUY_SKIN, GameConfig.getPackageCoinsPrice(packageId), 0, Game.selfId, packageId);
			else
				DialogSkinInfo.show(packageId);
		}
	}
}