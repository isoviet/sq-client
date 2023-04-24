package dialogs.bank
{
	import dialogs.DialogBank;
	import game.gameData.BundleManager;
	import game.gameData.BundleModel;

	import com.api.Services;

	public class DialogBankFB extends DialogBank
	{
		static private var FACTOR:Object = {
			'ru': function(value:int):Number
			{
				return value;
			},
			'en': function(value:int):Number
			{
				return (value * 0.03) - 0.01;
			}
		};

		override public function buy(coins:int):void
		{
			super.buy(coins);

			var product:String = Config.API_FB_PRODUCTS_URL + "coins_" + coins + ".html";
			Services.buy(getPayment(coins), {'amount': 1, 'product': product});
		}

		override public function bundleBuy(id:int):void
		{
			var bundle: BundleModel = BundleManager.getBundleById(id);

			super.bundleBuy(id);

			var product:String = Config.API_FB_PRODUCTS_URL + bundle.nameSocialImage + ".html";
			Services.buy(getPayment(bundle.price), {'amount': 1, 'product': product});
		}

		override protected function getPayment(coins:int):Number
		{
			return FACTOR[Config.LOCALE](coins);
		}
	}
}