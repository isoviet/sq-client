package tape.wardrobeTapes
{
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import tape.TapeSelectableObject;
	import views.PackageImageLoader;
	import views.widgets.RibbonEdgeView;

	public class TapeWardrobeElement extends TapeSelectableObject
	{
		static private const BUTTON_WIDTH:int = 110;
		static private const BUTTON_HEIGHT:int = 115;

		static private const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 10, 0x663300, true, null, null, null, null, "center");

		protected var icon:PackageImageLoader;
		protected var ribbonEdgeView:RibbonEdgeView = null;

		protected var _hideRibbons:Boolean = false;

		public function TapeWardrobeElement(itemId:int):void
		{
			super(itemId);

			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, checkState);
			ClothesManager.addEventListener(GameEvent.CLOTHES_HERO_CHANGE, checkState);
		}

		protected function get packageId():int
		{
			return GameConfig.getOutfitPackages(this.id)[0];
		}

		override protected function init():void
		{
			super.init();

			this.backSelected = new ElementPackageBackSelectedGreen();
			this.backSelected.width = BUTTON_WIDTH;
			this.backSelected.height = BUTTON_HEIGHT;
			addChild(this.backSelected);

			this.back = new ElementPackageBack();
			this.back.width = BUTTON_WIDTH;
			this.back.height = BUTTON_HEIGHT;
			addChild(this.back);

			this.icon = new PackageImageLoader(this.packageId);
			this.icon.scaleX = this.icon.scaleY = 0.4;
			this.icon.x = int((BUTTON_WIDTH - this.icon.width) * 0.5);
			this.icon.y = BUTTON_HEIGHT - this.icon.height - 5;
			addChild(this.icon);

			var field:GameField = new GameField(ClothesData.getPackageTitleById(this.packageId), 0, 5, FORMAT);
			field.width = BUTTON_WIDTH;
			field.wordWrap = true;
			addChild(field);

			checkState();
		}

		public function set hideRibbons(value:Boolean):void
		{
			if (this._hideRibbons == value)
				return;
			this._hideRibbons = value;

			if (!this.ribbonEdgeView)
				return;
			if (!value)
				addChild(this.ribbonEdgeView);
			else if (contains(this.ribbonEdgeView))
				removeChild(this.ribbonEdgeView);
		}

		public function get hideRibbons():Boolean
		{
			return this._hideRibbons;
		}

		private function checkState(e:GameEvent = null):void
		{
			var isWorn:Boolean = false;
			var packages:Array = GameConfig.getOutfitPackages(this.id);
			for (var i:int = 0; i < packages.length; i++)
				isWorn = isWorn || ClothesManager.isPackageWorn(packages[i]);

			var isClosed:Boolean = !ClothesManager.getPackageActive(this.packageId);

			if (this.ribbonEdgeView)
			{
				this.ribbonEdgeView.visible = isClosed || isWorn;
				this.ribbonEdgeView.type = isClosed ? RibbonEdgeView.SKIN_CLOSED : RibbonEdgeView.SKIN_WEARED;
			}
			else
			{
				if (!isClosed && !isWorn)
					return;
				this.ribbonEdgeView = new RibbonEdgeView(isClosed ? RibbonEdgeView.SKIN_CLOSED : RibbonEdgeView.SKIN_WEARED);
				this.ribbonEdgeView.x = 5;
				this.ribbonEdgeView.y = 98;
				if (!this.hideRibbons)
					addChild(this.ribbonEdgeView);
			}
		}
	}
}