package tape.shopTapes
{
	import tape.TapeSelectableObject;
	import views.PackageImageLoader;

	public class TapeShopSkinElement extends TapeSelectableObject
	{
		protected var icon:PackageImageLoader;

		public function TapeShopSkinElement(itemId:int):void
		{
			super(itemId);
		}

		override protected function init():void
		{
			super.init();

			this.backSelected = new ElementPackageLargeBackSelected();
			this.backSelected.width = 55;
			this.backSelected.height = 55;
			this.backSelected.visible = false;
			addChild(this.backSelected);

			this.back = new ElementPackageLargeBack();
			this.back.width = 55;
			this.back.height = 55;
			addChild(this.back);

			this.icon = new PackageImageLoader(this.id);
			this.icon.scaleX = this.icon.scaleY = 0.2;
			this.icon.x = int((this.back.width - this.icon.width) * 0.5);
			this.icon.y = int((this.back.height - this.icon.height) * 0.5);
			addChild(this.icon);
		}
	}
}