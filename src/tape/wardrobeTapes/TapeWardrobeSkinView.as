package tape.wardrobeTapes
{
	import flash.events.MouseEvent;

	import game.gameData.ClothesManager;
	import tape.TapeData;
	import tape.TapeSelectableObject;
	import tape.TapeSelectableView;
	import tape.events.TapeElementEvent;

	public class TapeWardrobeSkinView extends TapeSelectableView
	{
		protected var baseSkin:TapeSelectableObject = null;
		protected var selectedSelf:Boolean = true;

		public function TapeWardrobeSkinView(objectSize:int, offset:int, margin:int = 5, selectedSelf:Boolean = true)
		{
			super(2, 1, 5, margin, offset, 0, objectSize, objectSize, true, false, true);
			this.pageSelection = true;
			this.selectedSelf = selectedSelf;
		}

		override public function setData(data:TapeData):void
		{
			if (data.objects.length == 0)
			{
				super.setData(data);
				return;
			}

			if (this.baseSkin)
			{
				this.baseSkin.removeEventListener(MouseEvent.CLICK, onBaseClick);
				removeChild(this.baseSkin);
			}

			this.baseSkin = data.objects.shift() as TapeSelectableObject;
			this.baseSkin.scaleX = this.baseSkin.scaleY = 1.2;
			this.baseSkin.x = -this.baseSkin.width + this.leftMargin - this.offsetX;
			this.baseSkin.addEventListener(MouseEvent.CLICK, onBaseClick);
			addChild(this.baseSkin);

			super.setData(data);
			if (this.selectedSelf)
				for (var i:int = 0; i < data.objects.length; i++)
				{
					if (ClothesManager.wornPackages.indexOf((data.objects[i] as TapeSelectableObject).id) == -1)
						continue;
					select(data.objects[i] as TapeSelectableObject);
					return;
				}

			select(this.baseSkin);
		}

		override protected function gotoPage(index:int, direction:int):void
		{
			var page:int = this.currentPage;

			if(index > 1 && index > page && index - 1 != this.data.objects.length)
				super.gotoPage(index-1, direction);
			else if(index < page)
				super.gotoPage(index, direction);

			if (this.pageSelection && this.data.objects.length > index)
				select(this.data.objects[index] as TapeSelectableObject);
		}

		override protected function onStickElement(e:TapeElementEvent):void
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				if(this.data.objects[i] == (e.element as TapeSelectableObject))
				{
					this.scrollDotted.setSelected(i);
					break;
				}
			}

			select(e.element as TapeSelectableObject);
		}

		override protected function get dotSize():int
		{
			return 20;
		}

		private function onBaseClick(e:MouseEvent):void
		{
			deselect();
			select(this.baseSkin);
		}
	}
}