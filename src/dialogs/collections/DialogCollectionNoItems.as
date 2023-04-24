package dialogs.collections
{
	import dialogs.Dialog;

	public class DialogCollectionNoItems extends Dialog
	{
		static private var _instance:DialogCollectionNoItems = null;

		public function DialogCollectionNoItems():void
		{
			super(gls("К сожалению, у вас нет нужных\n другу предметов"));
			init();
		}

		static public function show():void
		{
			if (_instance == null)
				_instance = new DialogCollectionNoItems();

			_instance.show();
		}

		private function init():void
		{
			var image:NoCollectionItemsImg = new NoCollectionItemsImg();
			image.x = 35;
			addChild(image);

			place();

			this.width = 400;
			this.height = 300;

			this.buttonClose.width = this.buttonClose.height = 20;
			this.buttonClose.x -= 3;
		}
	}
}