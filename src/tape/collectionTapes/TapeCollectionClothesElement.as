package tape.collectionTapes
{
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;

	import buttons.ButtonTab;
	import game.gameData.ClothesManager;
	import game.gameData.CollectionsData;
	import game.gameData.OutfitData;

	import utils.FiltersUtil;

	public class TapeCollectionClothesElement extends ButtonTab
	{
		static private const BUTTON_WIDTH:int = 210;
		static private const BUTTON_HEIGHT:int = 280;

		private var _collected:Boolean = false;

		private var icon:MovieClip = null;

		public var elementId:int;

		public function TapeCollectionClothesElement(id:int):void
		{
			super(new ElementPackageBack, new ElementPackageBackSelected, new ElementPackageBackSelected);

			this.elementId = id;

			var caption:GameField = new GameField(CollectionsData.trophyData[this.elementId]['tittle'], 0, 5, new TextFormat(null, 15, 0x663300, true, null, null, null, null, "center"));
			caption.wordWrap = true;
			caption.width = 210;
			addChild(caption);

			this.icon = new (getDefinitionByName(CollectionsData.trophyData[this.elementId]['icon']) as Class)();
			this.icon.scaleX = this.icon.scaleY = 3.3;
			this.icon.x = int((BUTTON_WIDTH - this.icon.width) / 2);
			this.icon.y = int((BUTTON_HEIGHT - this.icon.height) / 2) + 3;
			this.icon.mouseEnabled = false;
			this.icon.mouseChildren = false;
			this.icon.filters = FiltersUtil.GREY_FILTER;
			addChild(this.icon);

			this._collected = true;
			this.collected = false;
		}

		public function update(collected:Boolean):void
		{
			this.collected = collected;
		}

		public function get checkClothes():Boolean
		{
			switch (OutfitData.getOwnerById(CollectionsData.trophyData[elementId]['clothesId']))
			{
				case OutfitData.OWNER_SCRAT:
					if (!ClothesManager.haveScrat)
						return false;
					break;
				case OutfitData.OWNER_SCRATTY:
					if (!ClothesManager.haveScratty)
						return false;
					break;
			}
			return true;
		}

		public function get collected():Boolean
		{
			return this._collected;
		}

		public function set collected(value:Boolean):void
		{
			if (!this.checkClothes)
				return;

			if (this._collected == value)
				return;

			this._collected = value;

			this.icon.filters = this._collected ? [] : FiltersUtil.GREY_FILTER;
		}
	}
}