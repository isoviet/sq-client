package views.shop
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextFormat;

	import dialogs.Dialog;
	import dialogs.DialogShop;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;
	import tape.TapeData;
	import tape.TapeDataSelectable;
	import tape.TapeObject;
	import tape.TapeSelectableObject;
	import tape.TapeSelectableView;
	import tape.TapeView;
	import tape.events.TapeElementEvent;
	import tape.perksTapes.TapePerkElement;
	import tape.perksTapes.TapePerkExtraElement;
	import tape.shopTapes.TapeShopLargeSkinElement;

	public class OutfitExtendView extends Sprite
	{
		static private const FORMAT:TextFormat = new TextFormat(null, 12, 0x68361B);

		private var _id:int = -1;
		private var selectId:int = -1;

		private var elementView:OutfitElementView = null;

		private var fieldCaption:GameField = null;
		private var fieldText:GameField = null;

		private var perkClothesView:PerkClothesView = null;

		private var tapeSkins:TapeSelectableView = null;
		private var tapePerk:TapeView = null;

		private var imageShopEmpty:DisplayObject = null;
		private var preview:Loader = null;

		private var moviePreload:MovieClip = null;

		private var back:ImageShopDetailsCaption = null;

		public function OutfitExtendView(id:int):void
		{
			this._id = id;
			this.selectId = GameConfig.getOutfitPackages(this.id)[0];

			init();
		}

		public function get id():int
		{
			return this._id;
		}

		public function setSelect(packageId:int):void
		{
			var ids:Vector.<TapeObject> = this.tapeSkins.getData().objects;
			for (var i:int = 0; i < ids.length; i++)
			{
				if ((ids[i] as TapeSelectableObject).id != packageId)
					continue;
				this.tapeSkins.select(ids[i] as TapeSelectableObject);
				return;
			}
		}

		private function init():void
		{
			this.back = new ImageShopDetailsCaption();
			this.back.buttonBack.addEventListener(MouseEvent.CLICK, onBack);
			this.back.x = int((Config.GAME_WIDTH - this.back.width) * 0.5);
			addChild(this.back);

			this.moviePreload = new MoviePreload();
			this.moviePreload.x = 770;
			this.moviePreload.y = 414;
			addChild(this.moviePreload);

			this.preview = new Loader();
			addChild(preview);
			this.preview.scrollRect = new Rectangle(0,0,150,150);
			this.preview.x = 711;
			this.preview.y = 358;

			this.preview.contentLoaderInfo.addEventListener(Event.COMPLETE, onGIFLoadComplete);
			this.preview.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onGIFLoadError);

			var field:GameField = new GameField(ClothesData.getPackageTitleById(GameConfig.getOutfitPackages(this.id)[0]), 0, 15, new TextFormat(GameField.PLAKAT_FONT, 24, 0xFFFFFF));
			field.filters = CloseoutShopView.FILTERS_CAPTION;
			field.x = 450 - int(field.width * 0.5);
			addChild(field);

			this.elementView = new OutfitElementView(this.id, true);
			this.elementView.x = 15;
			this.elementView.y = 85;
			this.elementView.buttonMode = true;
			this.elementView.addEventListener(MouseEvent.CLICK, onBaseClick);
			addChild(this.elementView);

			this.fieldCaption = new GameField("", 250, 335, Dialog.FORMAT_CAPTION_16);
			this.fieldCaption.filters = Dialog.FILTERS_CAPTION;
			addChild(this.fieldCaption);

			this.fieldText = new GameField("", 250, 355, FORMAT, 420);
			addChild(this.fieldText);

			this.perkClothesView = new PerkClothesView();
			this.perkClothesView.x = 270;
			this.perkClothesView.y = 430;
			addChild(this.perkClothesView);

			this.tapeSkins = new TapeSelectableView(3, 1, 5, 12, 10, 0, 200, 215, true, false, true);
			this.tapeSkins.x = 250;
			this.tapeSkins.y = 72;

			var data:TapeDataSelectable = new TapeDataSelectable(TapeShopLargeSkinElement);
			var otherIds:Array = GameConfig.getOutfitPackages(this.id).slice(1);
			data.setData(otherIds.filter(OutfitData.filterBuyable));

			this.tapeSkins.setData(data);
			this.tapeSkins.addEventListener(TapeElementEvent.SELECTED, onSelect);
			addChild(this.tapeSkins);

			this.imageShopEmpty = new ImageShopEmptyClothes();
			this.imageShopEmpty.x = 240;
			this.imageShopEmpty.y = 100;
			this.imageShopEmpty.visible = this.tapeSkins.getData().objects.length == 0;
			addChild(this.imageShopEmpty);

			field = new GameField(gls("Магия костюма"), 0, 545, new TextFormat(GameField.PLAKAT_FONT, 15, 0xFFFFFF));
			field.x = 120 - int(field.textWidth * 0.5);
			field.filters = [new GlowFilter(0x1E709E, 1.0, 4, 4, 8)];
			addChild(field);

			this.tapePerk = new TapeView(int.MAX_VALUE, 1, 0, 0, 10, 0, 50, 50);
			var dataPerk:TapeData = new TapeData(TapePerkElement);
			dataPerk.setData(OutfitData.getPerksByOutfit(this.id).filter(OutfitData.filterPerkBuyableOrSelf));

			var extras:Array = OutfitData.getExtraPerksSkinByOutfit(this.id);
			for (var i:int = 0; i < extras.length; i++)
			{
				if (!ClothesManager.haveItem(extras[i], ClothesManager.KIND_PACKAGES))
					continue;
				dataPerk.addObject(new TapePerkExtraElement(extras[i]));
			}
			this.tapePerk.setData(dataPerk);
			this.tapePerk.x = 260;
			this.tapePerk.y = 535;
			this.tapePerk.scaleX = this.tapePerk.scaleY = 0.8;
			addChild(this.tapePerk);

			this.tapeSkins.deselect();
		}

		private function onGIFLoadError(event:Event):void
		{
			Logger.add("Error load cast preview file");
			this.back.bgPreview.visible = false;
			this.moviePreload.visible = false;
		}

		private function onGIFLoadComplete(event:Event):void
		{
			if(this.moviePreload)
				this.moviePreload.visible = false;
			if(this.back && this.back.bgPreview)
				this.back.bgPreview.visible = true;
		}

		private function onBack(e:MouseEvent):void
		{
			DialogShop.selectTapes();
		}

		private function onBaseClick(e:MouseEvent):void
		{
			this.tapeSkins.deselect();
		}

		private function onSelect(e:TapeElementEvent):void
		{
			if (this.tapeSkins.lastSticked != null)
				this.selectId = this.tapeSkins.lastSticked.id;
			else
				this.selectId = GameConfig.getOutfitPackages(this.id)[0];
			update();
		}

		private function update():void
		{
			this.fieldCaption.text = ClothesData.getPackageTitleById(this.selectId);
			this.fieldText.htmlText = ClothesData.getPackageDescriptionById(this.selectId);

			this.preview.load(new URLRequest(Config.PREVIEWS_CLOTHES_URL + ClothesData.getPreview(this.selectId) + '.swf'));

			if (GameConfig.getPackageSkills(this.selectId).length > 0)
				this.perkClothesView.id = GameConfig.getPackageSkills(this.selectId)[0];
			this.perkClothesView.visible = GameConfig.getPackageSkills(this.selectId).length > 0;
			this.elementView.selected = this.tapeSkins.lastSticked == null;
		}
	}
}