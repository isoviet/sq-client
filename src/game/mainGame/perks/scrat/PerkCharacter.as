package game.mainGame.perks.scrat
{
	import game.mainGame.perks.Perk;
	import game.mainGame.perks.clothes.ITransformation;

	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundHero;

	public class PerkCharacter extends Perk
	{
		public function PerkCharacter(hero:Hero):void
		{
			super(hero);
		}

		override protected function get packets():Array
		{
			return [PacketRoundHero.PACKET_ID];
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			var pktHero: PacketRoundHero = packet as PacketRoundHero;

			if (!this.hero || (pktHero.playerId != this.hero.id))
				return;
			if (pktHero.keycode == this.code)
				this.active = true;

			if (pktHero.keycode == -this.code)
				this.active = false;
		}

		override public function get available():Boolean
		{
			for (var i:int = 0; i < this.hero.perkController.perksClothes.length; i++)
			{
				if ((this.hero.perkController.perksClothes[i] is ITransformation) && this.hero.perkController.perksClothes[i].active)
					return false;
			}

			return super.available && this.hero.isScrat;
		}
	}
}