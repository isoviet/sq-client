package game.mainGame.perks.clothes
{
	import game.mainGame.entity.magic.EnergyObject;
	import game.mainGame.gameNet.GameMapNet;

	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesEnergyObject extends PerkClothes
	{
		public function PerkClothesEnergyObject(hero:Hero):void
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override protected function activate():void
		{
			super.activate();

			(this.hero.game.map as GameMapNet).createObject(this.hero.id, this.energyObject);
		}

		override protected function get packets():Array
		{
			return [PacketRoundSkill.PACKET_ID];
		}

		protected function get energyObject():EnergyObject
		{
			return null;
		}
	}
}