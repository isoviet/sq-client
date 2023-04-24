package dialogs.bank
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import dialogs.DialogBank;
	import game.gameData.BundleManager;
	import game.gameData.BundleModel;

	import com.api.Services;

	import protocol.Connection;
	import protocol.PacketClient;

	public class DialogBankSA extends DialogBank
	{
		private var refillTimer:Timer = new Timer(5 * 1000, 30);

		override public function buy(coins:int):void
		{
			super.buy(coins);
			Services.buy(coins, {});

			this.refillTimer.addEventListener(TimerEvent.TIMER, refill);

			this.refillTimer.reset();
			this.refillTimer.start();
		}

		override public function bundleBuy(id:int):void
		{
			super.bundleBuy(id);

			var bundle:BundleModel = BundleManager.getBundleById(id);
			Services.buy(convertBundlePrice(bundle.price), {'type': bundle.offerId, 'description': bundle.name});
		}

		override protected function getPayment(coins:int):Number
		{
			return coins;
		}

		private function convertBundlePrice(value:Number):int
		{
			if (Config.isRus)
				return value;
			return value / 0.033;
		}

		private function refill(e:TimerEvent):void
		{
			Connection.sendData(PacketClient.REFILL);
		}
	}
}