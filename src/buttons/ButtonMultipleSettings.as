package buttons
{
	import flash.events.MouseEvent;

	public class ButtonMultipleSettings extends ButtonMultiple
	{
		public function ButtonMultipleSettings(buttonsArray:Array, state:int = 0):void
		{
			super(buttonsArray, state);

			for (var i:int = 0; i < this.buttonsArray.length; i++)
			{
				this.buttonsArray[i].addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					setState(e.currentTarget.name);
				});
			}
		}

		override public function setState(state:int):void
		{
			state = (state + 1) % this.buttonsArray.length;
			super.setState(state);
		}
	}
}