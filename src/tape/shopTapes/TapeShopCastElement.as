package tape.shopTapes
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.text.TextFormat;

	import utils.Rotator;

	public class TapeShopCastElement extends TapeShopElement
	{
		static public const MODIFY_ICON:Array = [
			{'class': Balk1, 'rotate': 30},
			{'class': TrampolineView, 'offsetX': 34, 'offsetY': 13},
			{'class': PortalA, 'offsetX': 30, 'offsetY': 33},
			{'class': PortalB, 'offsetX': 30, 'offsetY': 33},
			{'class': Sight, 'scale': 1.5, 'offsetX': 17, 'offsetY': 18}
		];

		public function TapeShopCastElement(itemId:int):void
		{
			super(itemId);
		}

		override protected function get backWidth():int
		{
			return 110;
		}

		override protected function get backHeight():int
		{
			return 115;
		}

		override protected function initImages():void
		{
			this.backSelected = new ElementPackageBackSelectedGreen();
			this.backSelected.width = backWidth;
			this.backSelected.height = backHeight;
			this.backSelected.visible = false;
			addChild(this.backSelected);

			this.back = new ElementPackageBack();
			this.back.width = this.backWidth;
			this.back.height = this.backHeight;
			addChild(this.back);

			this.fieldTitle = new GameField(this.title, 5, 10, this.titleFormat);
			this.fieldTitle.width = this.backWidth - 10;
			this.fieldTitle.wordWrap = true;
			this.fieldTitle.selectable = false;
			addChild(this.fieldTitle);

			this.fieldTitle.y -= 7;

			this.image = new this.imageClass;
			if (this.image && this.image is MovieClip)
				(this.image as MovieClip).gotoAndStop(0);
			this.image.scaleX = this.image.scaleY = 1;
			this.image.x = int((this.backWidth - this.image.width) * 0.5);
			this.image.y = int((this.backHeight - this.image.height) * 0.5);
			addChild(this.image);

			modifyIcon();
		}

		override protected function get titleFormat():TextFormat
		{
			return new TextFormat(null, 12, 0x663300, true, null, null, null, null, "center");
		}

		override protected function get title():String
		{
			return CastItemsData.getTitle(this.id);
		}

		override protected function get imageClass():Class
		{
			return CastItemsData.getImageClass(this.id);
		}

		private function modifyIcon():void
		{
			for each (var item:Object in MODIFY_ICON)
			{
				if (!(this.image is item['class']))
					continue;

				if ('offsetX' in item)
					this.image.x += item['offsetX'];

				if ('offsetY' in item)
					this.image.y += item['offsetY'];

				if ('scale' in item)
					this.image.scaleX = this.image.scaleY = (this.image.scaleX * item['scale']);

				if ('rotate' in item)
				{
					var rotate:Rotator = new Rotator(this.image, new Point(this.image.x + int(this.image.width / 2), this.image.y + int(this.image.height / 2)));
					rotate.rotateBy(item['rotate']);
				}
			}
		}
	}
}