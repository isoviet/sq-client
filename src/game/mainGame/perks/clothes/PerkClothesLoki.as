package game.mainGame.perks.clothes
{
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesLoki extends PerkClothes implements ITransformation
	{
		private var clothesIds:Array = null;

		public function PerkClothesLoki(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
		}

		override public function get target():int
		{
			var ids:Array = GameConfig.getOutfitPackages(OutfitData.squirrel_outfits[int(OutfitData.squirrel_outfits.length * Math.random())]);
			ids.filter(function(item:int, index:int, parent:Array):Boolean
			{
				return GameConfig.getPackageCoinsPrice(item) != 0;
			});
			return ids[int(Math.random() * ids.length)];
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get activeTime():Number
		{
			return 15;
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero || !this.hero.game)
				return;

			transform();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero || !this.hero.game)
				return;

			this.hero.heroView.setClothing(this.hero.player['weared_packages'], this.hero.player['weared_accessories']);
			this.hero.viewChanged = false;

			this.clothesIds = null;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var roundSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (roundSkill.state == PacketServer.SKILL_ERROR)
						return;
					if (roundSkill.type != this.code || roundSkill.playerId != this.hero.id)
						return;
					this.clothesIds = [roundSkill.targetId];
					this.active = roundSkill.state == PacketServer.SKILL_ACTIVATE;
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function transform():void
		{
			if (!this.hero || !this.hero.game || this.clothesIds == null)
				return;

			this.hero.heroView.setClothing(this.clothesIds);
			this.hero.viewChanged = true;
		}
	}
}