package dialogs.bank
{
	import dialogs.DialogBank;
	import game.gameData.BundleManager;
	import game.gameData.BundleModel;

	import com.api.Services;

	import utils.StringUtil;

	public class DialogBankOK extends DialogBank
	{
		override public function buy(coins:int):void
		{
			super.buy(coins);
			Services.buy(getPayment(coins), {'currency_name': "монеты", 'description': coins + " " + StringUtil.word("монет", coins), 'service_id': TYPE_COINS});
		}

		override public function bundleBuy(id:int):void
		{
			super.bundleBuy(id);

			var bundle:BundleModel = BundleManager.getBundleById(id);
			Services.buy(getPayment(bundle.price), {'currency_name': bundle.name, 'description': bundle.name, 'service_id': bundle.offerId});
		}

		override protected function getPayment(coins:int):Number
		{
			return coins;
		}
	}
}