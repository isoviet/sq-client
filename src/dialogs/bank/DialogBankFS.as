package dialogs.bank
{
	import dialogs.DialogBank;
	import game.gameData.BundleManager;
	import game.gameData.BundleModel;

	import com.api.Services;

	public class DialogBankFS extends DialogBank
	{
		static private function getPaymentCents(coins:int):Number
		{
			return (coins * 100 / 17);
		}

		override public function buy(coins:int):void
		{
			super.buy(coins);

			Services.buy(0, {'itemId': TYPE_COINS, 'name': "монетки", 'priceFmCents': Math.ceil(getPaymentCents(coins)), 'picUrl': Config.API_FS_PRODUCTS_URL + "buyCoins.png", 'amount': coins, 'isDebug': true, 'receiverId': Game.self.nid});
		}

		override public function bundleBuy(id:int):void
		{
			super.bundleBuy(id);

			var bundle:BundleModel = BundleManager.getBundleById(id);
			Services.buy(0, {'itemId': bundle.offerId, 'name': bundle.name, 'priceFmCents': int(getPaymentCents(bundle.price)), 'picUrl': Config.API_FS_PRODUCTS_URL + bundle.nameSocialImage + ".png", 'amount': 1, 'isDebug': true, 'receiverId': Game.self.nid});
		}

		override protected function getPayment(coins:int):Number
		{
			return (coins / 17);
		}
	}
}