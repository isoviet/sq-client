package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.behaviours.StateStun;
	import screens.ScreenGame;
	import sounds.GameSounds;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesStealNuts extends PerkClothes
	{
		public function PerkClothesStealNuts(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override public function get target():int
		{
			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (hero.isDead || hero.isHare || hero.isScrat || !hero.hasNut || hero.id == this.hero.id)
					continue;
				var pos:b2Vec2 = hero.position.Copy();
				pos.Subtract(this.hero.position);
				if (pos.Length() > 9.0)
					continue;
				return hero.id;
			}
			return super.target;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.hasNut && this.target != 0;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var skill: PacketRoundSkill = packet as PacketRoundSkill;

					if (skill.state == PacketServer.SKILL_ERROR)
						break;
					if (skill.type != this.code)
						return;
					if (this.hero.id != skill.playerId)
						return;
					this.active = skill.state == PacketServer.SKILL_ACTIVATE;

					if (skill.targetId > 0)
					{
						if (this.isSelf)
						{
							Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
							this.hero.setMode(Hero.NUT_MOD);
						}
						var stunnedHero:Hero = this.hero.game.squirrels.get(skill.targetId);
						if (skill.targetId == Game.selfId)
						{
							Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_LOST);
							GameSounds.play(SOUND_ACTIVATE);
							stunnedHero.setMode(Hero.NUDE_MOD);
						}
					}
					else
						stunnedHero = this.hero;

					ScreenGame.sendMessage(this.hero.id, "", (skill.targetId > 0) ? ChatDeadServiceMessage.STEAL_NUTS_SUCCESS : ChatDeadServiceMessage.STEAL_NUTS_FAIL);
					stunnedHero.behaviourController.addState(new StateStun(2));
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}
	}
}