package views.issuance
{
	import game.gameData.BundleManager;

	import protocol.packages.server.structs.PacketBundlesPackages;

	public class BundleAnimation extends BoxAnimation

	{
		private var packages:Vector.<PacketBundlesPackages> = null;

		public function BundleAnimation(type:int, collections:Vector.<int>, packages:Vector.<PacketBundlesPackages>):void
		{
			super (BundleManager.getBundleById(type).animation);

			this.type = type;
			this.collections = collections;
			this.packages = packages;
		}

		override protected function showBonuses():void
		{
			super.showBonuses();

			switch (this.type)
			{
				case BundleManager.WOODEN:
					showByType(IssuanceBonusView.GOLD, 20);
					showByType(IssuanceBonusView.ENERGY, 250);
					break;
				case BundleManager.SILVER:
					showByType(IssuanceBonusView.GOLD, 80);
					showByType(IssuanceBonusView.ENERGY, 250);
					showByType(IssuanceBonusView.MANA, 250);
					break;
				case BundleManager.GOLDEN:
					showByType(IssuanceBonusView.GOLD, 250);
					showByType(IssuanceBonusView.ENERGY, 1000);
					showByType(IssuanceBonusView.MANA, 1000);
					showByType(IssuanceBonusView.MANAREGEN, 7);
					break;
				case BundleManager.NEWBIE_RICH:
					showByType(IssuanceBonusView.GOLD, 75);
					showByType(IssuanceBonusView.ENERGY, 500);
					showByType(IssuanceBonusView.MANA, 800);
					break;
				case BundleManager.NEWBIE_POOR:
					showByType(IssuanceBonusView.GOLD, 20);
					showByType(IssuanceBonusView.ENERGY, 250);
					showByType(IssuanceBonusView.MANA, 400);
					break;
				case BundleManager.LEGENDARY:
					break;
				case BundleManager.WIZARD:
					showByType(IssuanceBonusView.MANA, 300);
					showByType(IssuanceBonusView.VIP, 7);
					break;
				case BundleManager.COLLECTION:
					break;
				case BundleManager.VETERAN:
					showByType(IssuanceBonusView.ENERGY, 5000);
					showByType(IssuanceBonusView.ITEMS, 15);
					break;
				case BundleManager.CARRIER:
					showByType(IssuanceBonusView.VIP, 7);
					showByType(IssuanceBonusView.EXP, 1000000);
					showByType(IssuanceBonusView.BALLOON, 50);
					break;
				case BundleManager.HOLIDAY_100:
					showHoliday(100);
					break;
				case BundleManager.HOLIDAY_500:
					showHoliday(500);
					break;
				case BundleManager.HOLIDAY_1000:
					showHoliday(1000);
					break;
				case BundleManager.HOLIDAY_1500:
					showHoliday(1500);
					break;
				case BundleManager.HOLIDAY_2000:
					showHoliday(2000);
					break;
			}

			showPackages(packages);
			showCollection(collections);
		}

		protected function showCollection(values:Vector.<int>):void
		{
			for (var i:int = 0; i < values.length; i++)
				new IssuanceBonusView(IssuanceBonusView.COLLECTIONS, this.index, (values[i] + 256) % 256).show(this);
			this.index++;
		}

		protected function showPackages(values:Vector.<PacketBundlesPackages>):void
		{
			for (var i:int = 0; i < values.length; i++)
			{
				new IssuanceBonusView(IssuanceBonusView.PACKAGES, this.index, values[i].id, int(values[i].duration / 60 / 60 / 24)).show(this);
				this.index++;
			}
		}
	}
}