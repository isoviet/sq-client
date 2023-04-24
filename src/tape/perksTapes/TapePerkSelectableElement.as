package tape.perksTapes
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	import game.gameData.ClothesManager;
	import game.gameData.OutfitData;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import tape.TapeSelectableObject;

	public class TapePerkSelectableElement extends TapeSelectableObject
	{
		private var icon:DisplayObject = null;
		private var frameCurrent:DisplayObject = null;

		//TODO don't forget about elapsed time of temp. packages
		public function TapePerkSelectableElement(itemId:int)
		{
			super(itemId);
		}

		public function set active(value:Boolean):void
		{
			if (value && !this.frameCurrent)
				this.frameCurrent = new PerkExtraCurrentFrame();

			if (this.frameCurrent)
			{
				this.frameCurrent.visible = value;
				if (value)
					this.backSelected.visible = false;
				this.frameCurrent.x = -10;
				this.frameCurrent.y = -8;
				addChild(this.frameCurrent);
			}
		}

		public function updateIcon():void
		{
			if (this.icon)
				removeChild(this.icon);
			this.icon = null;

			var packageId:int = OutfitData.perkToPackage(this.id);
			var baseId:int = OutfitData.getBaseSkin(packageId);
			if (!ClothesManager.haveItem(packageId, ClothesManager.KIND_PACKAGES) || !ClothesManager.haveItem(baseId, ClothesManager.KIND_PACKAGES))
			{
				this.icon = new ImageIconCoins();
				this.icon.scaleX = this.icon.scaleY = 0.8;
			}
			else if (ClothesManager.getPackageTime(baseId) != 0)
				this.icon = new ImageIconTime();

			if (this.icon)
			{
				this.icon.x = this.icon.y = 25;
				addChild(this.icon);
			}
		}

		override protected function init():void
		{
			super.init();

			var image:DisplayObject = PerkClothesFactory.getNewImage(this.id);
			image.x = image.y = 20;
			addChild(image);

			updateIcon();

			this.back = new MovieClip();
			addChild(this.back);

			this.backSelected = new PerkExtraSelectedFrame();
			this.backSelected.x -= 10;
			this.backSelected.y -= 8;
			this.backSelected.visible = false;
			addChild(this.backSelected);
		}
	}
}