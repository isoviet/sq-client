package tape.wardrobeTapes
{
	import tape.TapeSelectableObject;
	import views.PackageImageLoader;

	public class TapeWardrobeSkinElement extends TapeSelectableObject
	{
		protected var icon:PackageImageLoader;

		//protected var buttonBuy:ButtonBase = null;
		//protected var ribbonEdgeView:RibbonEdgeView = null;

		public function TapeWardrobeSkinElement(itemId:int):void
		{
			super(itemId);
		}

		override protected function init():void
		{
			super.init();

			this.backSelected = new ElementPackageLargeBackSelected();
			this.backSelected.width = 60;
			this.backSelected.height = 60;
			this.backSelected.visible = false;
			addChild(this.backSelected);

			this.back = new ElementPackageLargeBack();
			this.back.width = 60;
			this.back.height = 60;
			addChild(this.back);

			this.icon = new PackageImageLoader(this.id);
			this.icon.scaleX = this.icon.scaleY = 0.3;
			this.icon.x = int((this.back.width - this.icon.width) * 0.5);
			this.icon.y = int((this.back.height - this.icon.height) * 0.5) - 5;
			addChild(this.icon);
		}
	}
}