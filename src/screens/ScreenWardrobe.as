package screens
{
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import buttons.ButtonFooterTab;
	import buttons.ButtonScreenshot;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import dialogs.Dialog;
	import dialogs.DialogShop;
	import events.ButtonTabEvent;
	import events.GameEvent;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;
	import loaders.RuntimeLoader;
	import loaders.ScreensLoader;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import tape.TapeData;
	import tape.TapeDataSelectable;
	import tape.TapeSelectableObject;
	import tape.TapeView;
	import tape.events.TapeElementEvent;
	import tape.perksTapes.TapePerkElement;
	import tape.perksTapes.TapePerkExtraElement;
	import tape.wardrobeTapes.TapeWardrobeAccessoriesView;
	import tape.wardrobeTapes.TapeWardrobeClothesElement;
	import tape.wardrobeTapes.TapeWardrobeData;
	import tape.wardrobeTapes.TapeWardrobeView;
	import views.AccessoriesView;
	import views.ProfileHero;

	import utils.GuardUtil;

	public class ScreenWardrobe extends Screen
	{
		static public const FORMATS:Array = [new TextFormat(GameField.PLAKAT_FONT, 18, 0x857653),
			new TextFormat(GameField.PLAKAT_FONT, 18, 0x857653),
			new TextFormat(GameField.PLAKAT_FONT, 18, 0x857653)];

		static public const FORMATS_SMALL:Array = [new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF),
			new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFD341),
			new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFD341)];

		static private var _instance:ScreenWardrobe;
		static private var item_id:int = -1;
		static private var item_kind:int = -1;

		static private var cache:Object = {};
		static private var types:Array = null;
		static private var accessoryType:int = 0;
		static private var accessoryСache:Object = {};

		private var inited:Boolean = false;

		private var isShaman:Boolean = false;

		private var buttonGroup:ButtonTabGroup = null;
		private var buttonPackagesGroup:ButtonTabGroup = null;

		private var buttonPackages:ButtonTab = null;
		private var buttonsAccessories:Vector.<ButtonTab> = new <ButtonTab>[];

		private var tapePackageSquirrel:TapeWardrobeView = null;
		private var tapePackageShaman:TapeWardrobeView = null;

		private var tapesAccessories:Vector.<TapeWardrobeAccessoriesView> = new <TapeWardrobeAccessoriesView>[];

		private var tapePerks:TapeView = null;

		private var imageLackItem:SimpleButton = null;
		private var imageClosedItem:SimpleButton = null;

		private var accessoriesView:AccessoriesView = null;

		private var buttonDress:ButtonBase = null;
		private var buttonUndress:ButtonBase = null;
		private var buttonBuy:ButtonBase = null;
		private var buttonDetails:SimpleButton = null;

		private var fieldCaption:GameField = null;

		public var hero:ProfileHero = null;

		public function ScreenWardrobe():void
		{
			_instance = this;

			super();

			ClothesManager.addEventListener(GameEvent.CLOTHES_HERO_CHANGE, updateHero);
			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, update);
			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, updateAccessories);
		}

		static public function get instance():ScreenWardrobe
		{
			return _instance;
		}

		static public function tryOn(kind:int, id:int):void
		{
			if (!_instance || !_instance.inited)
				return;
			_instance.tryOn(kind, id);
		}

		override public function firstShow():void
		{
			show();
		}

		override public function show():void
		{
			super.show();

			if (!ScreensLoader.loaded)
				return;

			if (!this.inited)
			{
				init();

				this.inited = true;

				update();
				updateAccessories();

				this.hero.shaman = this.isShaman;
				this.hero.view = this.isShaman ? OutfitData.OWNER_SHAMAN : OutfitData.getScratsByArray(ClothesManager.wornPackages);
				this.hero.setClothes(ClothesManager.wornPackages, ClothesManager.wornAccessories);

				this.tapePackageSquirrel.selectSelf();
				this.tapePackageShaman.selectSelf();
				this.imageLackItem.visible = false;
			}

			GuardUtil.checkId();
		}

		override public function hide():void
		{
			super.hide();

			ScreenProfile.updateHero();
		}

		private function init():void
		{
			addChild(new ScreenWardrobeBackground);

			var field:GameField = new GameField(gls("Гардероб"), 0, 5, new TextFormat(GameField.PLAKAT_FONT, 21, 0xFFCC00));
			field.x = int((Config.GAME_WIDTH - field.textWidth) * 0.5);
			field.filters = Dialog.FILTERS_CAPTION;
			addChild(field);

			var buttonExit:ButtonCross = new ButtonCross();
			buttonExit.x = 870;
			buttonExit.y = 10;
			buttonExit.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				GameSounds.play(SoundConstants.BUTTON_CLICK);
				Screens.show(Screens.screenToComeback);
			});
			addChild(buttonExit);

			var screenshotButton:ButtonScreenshot = new ButtonScreenshot(true);
			screenshotButton.x = 840;
			screenshotButton.y = 10;
			addChild(screenshotButton);

			var spriteBack:Sprite = new Sprite();
			spriteBack.y = 480;
			spriteBack.graphics.beginFill(0x000000, 0.5);
			spriteBack.graphics.drawRect(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT - spriteBack.y);
			addChild(spriteBack);

			field = new GameField(gls("Магия"), 70, 125, new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFEFBD, null, null, null, null, null, "center"), 170);
			field.filters = [new GlowFilter(0x3F1710, 1.0, 4, 4, 8),
				new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)];
			addChild(field);

			field = new GameField(gls("Аксессуары"), 665, 125, new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFEFBD, null, null, null, null, null, "center"), 170);
			field.filters = [new GlowFilter(0x3F1710, 1.0, 4, 4, 8),
				new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)];
			addChild(field);

			this.buttonGroup = new ButtonTabGroup();
			this.buttonGroup.y = 45;
			var button:ButtonTab = new ButtonTab(new ButtonFooterTab(gls("Белка"), FORMATS, ButtonWardrobeSquirrel, 15));
			button.addEventListener(ButtonTabEvent.SELECT, selectSquirrel);
			this.buttonGroup.insert(button);

			button = new ButtonTab(new ButtonFooterTab(gls("Шаман"), FORMATS, ButtonWardrobeShaman, 15));
			button.x = 450;
			button.addEventListener(ButtonTabEvent.SELECT, selectShaman);
			this.buttonGroup.insert(button);
			addChild(this.buttonGroup);

			this.fieldCaption = new GameField("", 300, 120, new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFEFBD, null, null, null, null, null, "center"), 300);
			this.fieldCaption.filters = [new GlowFilter(0x3F1710, 1.0, 4, 4, 8),
				new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)];
			addChild(this.fieldCaption);

			this.tapePackageSquirrel = new TapeWardrobeView();
			this.tapePackageSquirrel.x = 20;
			this.tapePackageSquirrel.y = 490;
			this.tapePackageSquirrel.addEventListener(TapeElementEvent.SELECTED, onPackageSelect);
			this.tapePackageSquirrel.addEventListener(TapeWardrobeView.SELECT_SKIN, onSkinSelect);
			addChild(this.tapePackageSquirrel);

			this.tapePackageShaman = new TapeWardrobeView();
			this.tapePackageShaman.x = 20;
			this.tapePackageShaman.y = 490;
			this.tapePackageShaman.addEventListener(TapeElementEvent.SELECTED, onPackageSelect);
			this.tapePackageShaman.addEventListener(TapeWardrobeView.SELECT_SKIN, onSkinSelect);

			this.buttonPackagesGroup = new ButtonTabGroup();
			this.buttonPackagesGroup.y = 455;
			this.buttonPackages = new ButtonTab(new ButtonFooterTab(gls("Костюмы"), FORMATS_SMALL, ButtonWardrobePackages, 3));
			this.buttonPackages.addEventListener(ButtonTabEvent.SELECT, selectPackages);
			this.buttonPackagesGroup.insert(this.buttonPackages, [this.tapePackageSquirrel, this.tapePackageShaman]);

			this.tapePerks = new TapeView(2, 5, 0, 0, 95, 59, 0, 0);
			this.tapePerks.x = 85;
			this.tapePerks.y = 170;
			addChild(this.tapePerks);

			var lastX:int = this.buttonPackages.x + this.buttonPackages.width + 22;
			types = [OutfitData.ACCESSORY_CLOAK, OutfitData.ACCESSORY_GLASSES, OutfitData.ACCESSORY_HANDS, OutfitData.ACCESSORY_NECK, OutfitData.ACCESSORY_TAIL, OutfitData.ACCESSORY_HAIRBAND];
			var buttonClasses:Array = [ButtonWardrobeCloak, ButtonWardrobeGlass, ButtonWardrobeHands, ButtonWardrobeNeck, ButtonWardrobeTail, ButtonWardrobeHair];
			var names:Array = [gls("Плащи"), gls("Очки"), gls("Аксессуары в руки"),
				gls("Ожерелья"), gls("Аксессуары на хвост"), gls("Аксессуары на голову")];
			for (var i:int = 0; i < buttonClasses.length; i++)
			{
				var tapeAccessories:TapeWardrobeAccessoriesView = new TapeWardrobeAccessoriesView(types[i]);
				tapeAccessories.x = 140;
				tapeAccessories.y = 490;
				addChild(tapeAccessories);

				this.tapesAccessories.push(tapeAccessories);

				var buttonTab:ButtonTab = new ButtonTab(new buttonClasses[i]);
				buttonTab.x = lastX;
				buttonTab.y = 15;
				buttonTab.addEventListener(ButtonTabEvent.SELECT, selectAccessories);
				this.buttonPackagesGroup.insert(buttonTab, tapeAccessories);
				this.buttonsAccessories.push(buttonTab);

				new Status(this.buttonsAccessories[i], names[i]);

				lastX = buttonTab.x + buttonTab.width + 2;
			}
			addChild(this.buttonPackagesGroup);

			this.hero = new ProfileHero();
			this.hero.x = 450;
			this.hero.y = 360;
			addChild(this.hero);

			this.imageLackItem = Config.isRus ? new ButtonWardrobeLackSkin() : new ButtonWardrobeLackSkinEn();
			this.imageLackItem.x = 450;
			this.imageLackItem.y = 300;
			this.imageLackItem.visible = false;
			this.imageLackItem.addEventListener(MouseEvent.CLICK, showShop);
			addChild(this.imageLackItem);

			this.imageClosedItem = Config.isRus ? new ButtonWardrobeClosedSkin() : new ButtonWardrobeClosedSkinEn();
			this.imageClosedItem.x = 450;
			this.imageClosedItem.y = 300;
			this.imageClosedItem.visible = false;
			this.imageClosedItem.addEventListener(MouseEvent.CLICK, showShop);
			addChild(this.imageClosedItem);

			this.accessoriesView = new AccessoriesView(accessoriesCallback);
			this.accessoriesView.x = 660;
			this.accessoriesView.y = 175;
			addChild(this.accessoriesView);

			this.buttonDress = new ButtonBase(gls("Надеть"), 80);
			this.buttonDress.x = 410;
			this.buttonDress.y = 150;
			this.buttonDress.visible = false;
			this.buttonDress.addEventListener(MouseEvent.CLICK, onDress);
			this.buttonDress.setBlue();
			addChild(this.buttonDress);

			this.buttonUndress = new ButtonBase(gls("Снять"), 80);
			this.buttonUndress.x = 410;
			this.buttonUndress.y = 150;
			this.buttonUndress.visible = false;
			this.buttonUndress.addEventListener(MouseEvent.CLICK, onDress);
			this.buttonUndress.setRed();
			addChild(this.buttonUndress);

			this.buttonBuy = new ButtonBase(gls("Купить"), 80);
			this.buttonBuy.x = 410;
			this.buttonBuy.y = 150;
			this.buttonBuy.visible = false;
			this.buttonBuy.addEventListener(MouseEvent.CLICK, showShop);
			addChild(this.buttonBuy);

			this.buttonDetails = new ButtonShowMore();
			this.buttonDetails.x = 600;
			this.buttonDetails.y = 135;
			this.buttonDetails.width = this.buttonDetails.height = 28;
			this.buttonDetails.visible = false;
			this.buttonDetails.addEventListener(MouseEvent.CLICK, showShop);
			addChild(this.buttonDetails);

			CONFIG::release {return;}
			//Game.stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{createImagePackage(packid)});
		}

		private function accessoriesCallback(type:int):void
		{
			this.buttonsAccessories[type].dispatchEvent(new ButtonTabEvent(ButtonTabEvent.SELECT, this.buttonsAccessories[type]));
		}

		private function onSkinSelect(e:Event):void
		{
			if (!e.currentTarget.parent)
				return;
			ScreenWardrobe.tryOn(ClothesManager.KIND_PACKAGES, (e.currentTarget as TapeWardrobeView).selectId);
		}

		private function onDress(e:MouseEvent):void
		{
			if (item_id == -1 || item_kind == -1)
				return;
			ClothesManager.tryOn(item_kind, item_id);
		}

		private function onPackageSelect(e:TapeElementEvent):void
		{
			if (!e.currentTarget.parent)
				return;
			this.tapePerks.visible = e.element != null;
			if (e.element == null)
				return;

			var outfitId:int = (e.element as TapeSelectableObject).id;
			var data:TapeData = new TapeData(TapePerkElement);
			data.setData(OutfitData.getPerksByOutfit(outfitId).filter(OutfitData.filterPerkBuyableOrSelf));

			var extras:Array = OutfitData.getExtraPerksSkinByOutfit(outfitId);
			for (var i:int = 0; i < extras.length; i++)
			{
				if (!ClothesManager.haveItem(extras[i], ClothesManager.KIND_PACKAGES))
					continue;
				data.addObject(new TapePerkExtraElement(extras[i]));
			}
			this.tapePerks.setData(data);
		}

		private function selectSquirrel(e:ButtonTabEvent):void
		{
			this.isShaman = false;

			for (var i:int = 0; i < this.buttonsAccessories.length; i++)
				this.buttonsAccessories[i].visible = true;
			if (contains(this.tapePackageShaman))
				removeChild(this.tapePackageShaman);
			addChild(this.tapePackageSquirrel);

			updateHero();
		}

		private function selectShaman(e:ButtonTabEvent):void
		{
			this.isShaman = true;

			for (var i:int = 0; i < this.buttonsAccessories.length; i++)
				this.buttonsAccessories[i].visible = false;
			if (this.buttonsAccessories.indexOf(this.buttonPackagesGroup.selected) != -1)
				this.buttonPackagesGroup.setSelected(this.buttonPackages);
			addChild(this.tapePackageShaman);
			if (contains(this.tapePackageSquirrel))
				removeChild(this.tapePackageSquirrel);

			updateHero();
		}

		private function selectPackages(e:ButtonTabEvent):void
		{
			cache[item_kind] = item_id;

			updateHero();

			item_kind = -1;
			item_id = -1;
			if (ClothesManager.KIND_PACKAGES in cache)
			{
				item_kind = ClothesManager.KIND_PACKAGES;
				item_id = cache[item_kind];

				tryOn(item_kind, item_id);
			}
		}

		private function selectAccessories(e:ButtonTabEvent):void
		{
			var index:int = this.buttonsAccessories.indexOf(e.button);
			var type:int = types[index];

			accessoryType = type;

			cache[item_kind] = item_id;

			updateHero();

			item_kind = -1;
			item_id = -1;
			if (ClothesManager.KIND_ACCESORIES in cache)
			{
				if (!(accessoryType in accessoryСache))
					return;
				item_kind = ClothesManager.KIND_ACCESORIES;
				item_id = accessoryСache[accessoryType];

				tryOn(item_kind, item_id);
			}
		}

		private function update(e:GameEvent = null):void
		{
			if (!this.inited)
				return;

			var tapePackageData:TapeWardrobeData = new TapeWardrobeData();
			tapePackageData.setData(ClothesManager.outfitIds.filter(function(item:int, index:int, parentArray:Array):Boolean
			{
				if (index || parentArray) {/*unused*/}
				var owner:int = GameConfig.getOutfitCharacter(item);
				return owner == OutfitData.CHARACTER_SQUIRREL;
			}));
			this.tapePackageSquirrel.setData(tapePackageData);

			tapePackageData = new TapeWardrobeData();
			tapePackageData.setData(ClothesManager.outfitIds.filter((function(item:int, index:int, parentArray:Array):Boolean
			{
				if (index || parentArray) {/*unused*/}
				var owner:int = GameConfig.getOutfitCharacter(item);
				return owner == OutfitData.CHARACTER_SHAMAN;
			})));
			this.tapePackageShaman.setData(tapePackageData);
		}

		private function updateHero(e:GameEvent = null):void
		{
			if (!this.inited)
				return;
			this.hero.shaman = this.isShaman;
			this.hero.view = this.isShaman ? OutfitData.OWNER_SHAMAN : OutfitData.getScratsByArray(ClothesManager.wornPackages);

			this.hero.setClothes(ClothesManager.wornPackages, ClothesManager.wornAccessories);
			if (this.isShaman)
				this.tapePackageShaman.select(this.tapePackageShaman.lastSticked);
			else
				this.tapePackageSquirrel.select(this.tapePackageSquirrel.lastSticked);

			this.imageLackItem.visible = false;
			this.imageClosedItem.visible = false;

			var needBuy:Boolean = !ClothesManager.haveItem(item_id, item_kind);
			this.buttonDress.visible = !needBuy && !ClothesManager.isWornItem(item_id, item_kind);
			this.buttonUndress.visible = !needBuy && ClothesManager.isWornItem(item_id, item_kind);
		}

		private function updateAccessories(e:GameEvent = null):void
		{
			if (!this.inited)
				return;
			for (var i:int = 0; i < types.length; i++)
			{
				var data:TapeDataSelectable = new TapeDataSelectable(TapeWardrobeClothesElement);
				data.setData(ClothesManager.accessoriesIds.filter(function(item:int, index:int, parentArray:Array):Boolean
				{
					if (index || parentArray) {/*unused*/}
					var type:int = GameConfig.getAccessoryType(item);
					return type == types[i];
				}));
				tapesAccessories[i].setData(data);
			}
		}

		private function showShop(e:MouseEvent):void
		{
			RuntimeLoader.load(function():void
			{
				DialogShop.instance.show();
				if (item_kind == ClothesManager.KIND_PACKAGES)
					DialogShop.selectOutfit(OutfitData.packageToOutfit(item_id), item_id);
			});
		}

		private function tryOn(kind:int, id:int):void
		{
			var wornPackages:Array = ClothesManager.wornPackages.slice();
			var wornAccessories:Array = ClothesManager.wornAccessories.slice();
			item_kind = kind;
			item_id = id;

			if (item_kind == ClothesManager.KIND_ACCESORIES)
				accessoryСache[GameConfig.getAccessoryType(item_id)] = item_id;

			var array:Array = item_kind == ClothesManager.KIND_PACKAGES ? wornPackages : wornAccessories;
			var replaced:Boolean = false;
			for (var i:int = 0; i < array.length; i++)
			{
				if (item_kind == ClothesManager.KIND_PACKAGES)
				{
					var a:int = GameConfig.getOutfitCharacter(OutfitData.packageToOutfit(array[i]));
					var b:int = GameConfig.getOutfitCharacter(OutfitData.packageToOutfit(id));
				}
				else
				{
					a = GameConfig.getAccessoryType(wornAccessories[i]);
					b = GameConfig.getAccessoryType(id);
				}
				if (a != b)
					continue;
				array[i] = id;
				replaced = true
			}
			if (!replaced)
				array.push(id);
			if (item_kind == ClothesManager.KIND_PACKAGES)
				this.fieldCaption.text = ClothesData.getPackageTitleById(item_id);
			else
				this.fieldCaption.text = ClothesData.getTitleById(item_id);

			this.hero.shaman = this.isShaman;
			this.hero.view = this.isShaman ? OutfitData.OWNER_SHAMAN : OutfitData.getScratsByArray(wornPackages);
			this.hero.setClothes(wornPackages, wornAccessories);

			this.imageClosedItem.visible = false;
			this.imageLackItem.visible = false;

			if (item_kind == ClothesManager.KIND_PACKAGES)
			{
				var baseId:int = OutfitData.getBaseSkin(item_id);
				if (!ClothesManager.getPackageActive(baseId))
				{
					this.imageClosedItem.visible = (baseId != item_id) && ClothesManager.haveItem(item_id, item_kind);
					this.imageLackItem.visible = (baseId == item_id) || !ClothesManager.haveItem(item_id, item_kind);

					this.buttonDress.visible = false;
					this.buttonUndress.visible = false;
					this.buttonDetails.visible = true;
					this.buttonBuy.visible = false;
					return;
				}
			}

			var needBuy:Boolean = !ClothesManager.haveItem(item_id, item_kind);
			this.buttonDress.visible = !needBuy && !ClothesManager.isWornItem(item_id, item_kind);
			this.buttonUndress.visible = !needBuy && ClothesManager.isWornItem(item_id, item_kind);
			this.buttonDetails.visible = !needBuy && item_kind == ClothesManager.KIND_PACKAGES && GameConfig.getPackageCoinsPrice(item_id) > 0;
			this.buttonBuy.visible = needBuy;
		}

		/*TODO используется для создание картинки комлекта "с белкой"*/
		static private var packid:int = 168;
		static private var isPack:Boolean = false;

		private function createImagePackage(id:int):void
		{
			var bitmap:BitmapData = new BitmapData(312, 222, true, 0);

			this.hero.enableUpdate = true;
			if (isPack)
			{
				this.hero.view = OutfitData.getOwnerById(id);
				this.hero.setClothes([id], GameConfig.getPackageAccessories(id));
			}
			else
				this.hero.setClothes([], [id]);
			this.hero.enableUpdate = false;
			bitmap.draw(this.hero, new Matrix(1.2, 0, 0, 1.2, 151, 216));
			if (isPack)
				NewsImageGenerator.save(bitmap, "ImagePackage" + id, false);
			else
				NewsImageGenerator.save(bitmap, "ImageAccessories" + id, false);
			packid++;
		}
	}
}