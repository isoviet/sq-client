package views.issuance
{
	import protocol.packages.server.PacketBonuses;
	import protocol.packages.server.structs.PacketBonusesItems;
	import protocol.packages.server.structs.PacketBonusesTemporaryPackages;

	public class BonusAnimation extends BoxAnimation
	{
		private var packet:PacketBonuses = null;

		private static const BONUS_BALLOON:int = 18;

		public function BonusAnimation(packet:PacketBonuses)
		{
			this.packet = packet;

			super(MovieBonus);
		}

		override protected function showBonuses():void
		{
			super.showBonuses();

			if(this.packet.manaRegenerationDuration > 0)
				showByType(IssuanceBonusView.MANAREGEN, int(this.packet.manaRegenerationDuration / 60 / 60 / 24));
			if(this.packet.vipDuration > 0)
				showByType(IssuanceBonusView.VIP, int(this.packet.vipDuration / 60 / 60 / 24));
			if(this.packet.energy > 0)
				showByType(IssuanceBonusView.ENERGY, this.packet.energy, -75);
			if(this.packet.experience > 0)
				showByType(IssuanceBonusView.EXP, this.packet.experience);
			if(this.packet.mana > 0)
				showByType(IssuanceBonusView.MANA, this.packet.mana);
			if(this.packet.nuts > 0)
				showByType(IssuanceBonusView.NUTS, this.packet.nuts);

			showItems(this.packet.items);
			showPackages(this.packet.temporaryPackages);
			showCollection(this.packet.collections);
		}

		protected function showCollection(values:Vector.<int>):void
		{
			for (var i:int = 0; i < values.length; i++)
			{
				new IssuanceBonusView(IssuanceBonusView.COLLECTIONS, this.index, (values[i] + 256) % 256).show(this);
				this.index++;
			}
		}

		protected function showPackages(values:Vector.<PacketBonusesTemporaryPackages>):void
		{
			for (var i:int = 0; i < values.length; i++)
			{
				new IssuanceBonusView(IssuanceBonusView.PACKAGES, this.index, values[i].packageId, int(values[i].duration / 60 / 60 / 24)).show(this);
				this.index++;
			}
		}

		protected function showItems(values:Vector.<PacketBonusesItems>):void
		{
			for (var i:int = 0; i < values.length; i++)
			{
				if(values[i].itemId == BONUS_BALLOON)
				{
					new IssuanceBonusView(IssuanceBonusView.BALLOON, this.index, 0, values[i].count, 0, 0).show(this);
					this.index++;
				}
			}
		}
	}
}