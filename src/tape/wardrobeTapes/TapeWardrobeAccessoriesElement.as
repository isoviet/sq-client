package tape.wardrobeTapes
{
	import tape.TapeSelectableObject;
	import views.PackageImageLoader;

	public class TapeWardrobeAccessoriesElement extends TapeSelectableObject
	{
		static private const BUTTON_WIDTH:int = 60;
		static private const BUTTON_HEIGHT:int = 60;

		protected var icon:PackageImageLoader;

		public function TapeWardrobeAccessoriesElement(itemId:int):void
		{
			super(itemId);
		}

		public function get item():Object
		{
			return ClothesData.getPackageItem(this.id);
		}

		override protected function init():void
		{
			super.init();

			this.backSelected = new ElementPackageBackSelected();
			this.backSelected.width = BUTTON_WIDTH;
			this.backSelected.height = BUTTON_HEIGHT;
			addChild(this.backSelected);

			this.back = new ElementPackageBack();
			this.back.width = BUTTON_WIDTH;
			this.back.height = BUTTON_HEIGHT;
			addChild(this.back);

			this.icon = new PackageImageLoader(this.id);
			this.icon.x = 1;
			this.icon.y = 50;
			addChild(this.icon);
		}
	}
}