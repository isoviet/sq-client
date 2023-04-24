package dialogs.bank
{
	import dialogs.DialogBank;
	import game.gameData.BundleManager;
	import game.gameData.BundleModel;

	import com.api.Services;

	public class DialogBankVK extends DialogBank
	{
		static public const RATE_BY_COINS:int = 7;

		override public function buy(coins:int):void
		{
			super.buy(coins);

			var double:int = 0;
			if (DiscountManager.haveDouble(coins))
				double = 1;

			Services.buy(getPayment(coins), {'type': "item", 'item': "coins_" + coins + "_" + double.toString()});
		}

		override public function bundleBuy(id:int):void
		{
			super.bundleBuy(id);

			var bundle:BundleModel = BundleManager.getBundleById(id);
			Services.buy(getPayment(bundle.price), {'type': "item", 'item': bundle.nameSocialImage});
		}

		override protected function getPayment(coins:int):Number
		{
			return int(coins / 7);
		}
	}
}