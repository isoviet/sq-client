package buttons
{
	import flash.display.Sprite;

	public class ButtonMultiple extends Sprite
	{
		protected var buttonsArray:Array = [];
		private var currentState:int;

		public function ButtonMultiple(buttonsArray:Array, state:int = 0):void
		{
			this.buttonsArray = buttonsArray.slice();
			init(state);
		}

		public function setState(state:int):void
		{
			this.buttonsArray[this.currentState].visible = false;
			this.buttonsArray[state].visible = true;
			this.currentState = state;
		}

		private function init(state:int):void
		{
			for (var i:int = 0; i < this.buttonsArray.length; i++)
			{
				this.buttonsArray[i].visible = false;
				this.buttonsArray[i].name = i.toString();
				addChild(this.buttonsArray[i]);
			}

			setState(state);
		}
	}
}