package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class PerkClothesBlackCat extends PerkClothes
	{
		private var point:b2Vec2 = null;
		private var effect:ParticlesEffect;

		public function PerkClothesBlackCat(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_TELEPORT;
			this.soundOnlyHimself = true;
		}

		override public function get available():Boolean
		{
			return super.available && (this.point != null);
		}

		override public function resetRound():void
		{
			super.resetRound();

			this.point = null;

			if (!this.effect)
				return;
			this.effect.stop();
			CollectionEffects.instance.removeEffect(this.effect);
			this.effect = null;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.teleportTo(this.point);
			this.point = null;

			if (!this.effect)
				return;
			this.effect.stop();
			CollectionEffects.instance.removeEffect(this.effect);
			this.effect = null;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (this.hero == null)
				return;
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var roundSkill:PacketRoundSkill = packet as PacketRoundSkill;
					switch(roundSkill.type)
					{
						case PerkClothesFactory.CHESHIRE_CAT:
							if (roundSkill.state != PacketServer.SKILL_ACTIVATE)
								return;
							if (roundSkill.playerId != this.hero.id)
								return;
							this.point = this.hero.position.Copy();

							if (!this.effect)
								this.effect = CollectionEffects.instance.getEffectByName(CollectionEffects.EFFECT_BLACK_CAT);
							this.effect.view.visible = true;
							this.effect.view.emitterX = this.hero.x;
							this.effect.view.emitterY = this.hero.y;
							this.effect.start();

							Hero.self.getStarlingView().parent.addChild(this.effect.view);
							break;
						case this.code:
							super.onPacket(packet);
							break;
					}
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}
	}
}