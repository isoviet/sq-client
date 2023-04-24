package views
{
	import flash.events.MouseEvent;

	import game.gameData.GameConfig;

	import protocol.PacketClient;

	public class ManaComboBoxView extends ComboBoxView
	{
		override protected function buy(e:MouseEvent):void
		{
			super.buy(e);

			Game.buyWithoutPay(PacketClient.BUY_MANA_REGENERATION, GameConfig.getManaRegenerationCoinsPrice(this.value), 0, Game.selfId, this.value);
		}

		override protected function getPrice(value:int):int
		{
			return GameConfig.getManaRegenerationCoinsPrice(value);
		}

		override protected function get names():Array
		{
			return [gls("1д."), gls("7д.")];
		}

		override protected function get discounts():Array
		{
			return [0, 30];
		}
	}
}