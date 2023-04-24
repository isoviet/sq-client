package views
{
	import flash.events.MouseEvent;

	import game.gameData.GameConfig;
	import game.gameData.VIPManager;

	public class VIPComboBoxView extends ComboBoxView
	{
		public function VIPComboBoxView():void
		{
			super();
		}

		override protected function buy(e:MouseEvent):void
		{
			super.buy(e);

			VIPManager.buy(this.value);
		}

		override protected function getPrice(value:int):int
		{
			return GameConfig.getVIPCoinsPrice(value);
		}

		override protected function get names():Array
		{
			return [gls("1д."), gls("7д."), gls("30д.")];
		}

		override protected function get discounts():Array
		{
			return [0, 20, 33];
		}
	}
}