package game.mainGame.perks.clothes
{
	import game.mainGame.behaviours.StateVader;
	import sounds.GameSounds;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesVader extends PerkClothesSelective
	{
		public function PerkClothesVader(hero:Hero):void
		{
			super(hero);

			this.activateSound = "vader";
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (this.hero == null)
				return;
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var roundSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (roundSkill.state == PacketServer.SKILL_ERROR)
						return;
					if (roundSkill.type != this.code || roundSkill.playerId != this.hero.id)
						return;
					if (roundSkill.state == PacketServer.SKILL_ACTIVATE)
					{
						var targetHero:Hero = this.hero.game.squirrels.get(roundSkill.targetId);

						if(roundSkill.targetId == Game.self.id)
							GameSounds.play("vader");

						if (targetHero)
							targetHero.behaviourController.addState(new StateVader(7, 3, 0.1));
					}
					this.active = roundSkill.state == PacketServer.SKILL_ACTIVATE;
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		override protected function checkHero(hero:Hero):Boolean
		{
			return this.hero.id != hero.id && !hero.isDead && !hero.inHollow;
		}
	}
}