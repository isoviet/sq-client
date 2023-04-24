package game.mainGame.perks.clothes
{
	import chat.ChatDeadServiceMessage;
	import game.mainGame.behaviours.StateDeath;
	import screens.ScreenGame;
	import sounds.GameSounds;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesDeath extends PerkClothesSelective
	{
		protected var state:StateDeath = null;
		protected var curseHero:Hero = null;
		protected var haveFreeRespawn:Boolean = false;

		public function PerkClothesDeath(hero:Hero):void
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return 5;
		}

		override public function get available():Boolean
		{
			return super.available && this.curseHero == null && !this.haveFreeRespawn;
		}

		override public function resetRound():void
		{
			super.resetRound();

			this.state = null;
			this.curseHero = null;
			this.haveFreeRespawn = false;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (this.hero == null)
				return;
			switch (packet.packetId)
			{
				case PacketRoomLeave.PACKET_ID:
					var roomLeave:PacketRoomLeave = packet as PacketRoomLeave;
					if (this.curseHero && this.curseHero.id == roomLeave.playerId)
						this.curseHero = null;
					super.onPacket(packet);
					break;
				case PacketRoundSkill.PACKET_ID:
					var roundSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (roundSkill.state == PacketServer.SKILL_ERROR)
						return;
					if (roundSkill.type != this.code || roundSkill.playerId != this.hero.id)
						return;
					if (roundSkill.state == PacketServer.SKILL_ACTIVATE)
					{
						this.curseHero = this.hero.game.squirrels.get(roundSkill.targetId);
						if (this.curseHero)
						{
							GameSounds.play("Death_curse");
							this.state = new StateDeath(0);
							this.curseHero.behaviourController.addState(this.state);
							ScreenGame.sendMessage(this.hero.id, gls("Душа «{0}» принадлежит Смерти {1}", this.curseHero.player.nameOrig.toString(), this.hero.player.nameOrig.toString()), ChatDeadServiceMessage.BLOCK);
						}
					}
					this.active = roundSkill.state == PacketServer.SKILL_ACTIVATE;
					break;
				case PacketRoundDie.PACKET_ID:
					var roundDie:PacketRoundDie = packet as PacketRoundDie;
					if (this.curseHero && roundDie.playerId == this.curseHero.id)
					{
						this.haveFreeRespawn = true;
						this.curseHero.behaviourController.removeState(this.state);
						this.curseHero = null;
						this.state = null;

						GameSounds.play(Config.isRus ? "Death_kill" : "kiss");

						if (this.isSelf && this.hero.isDead)
						{
							this.haveFreeRespawn = false;
							Connection.sendData(PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_DEATH);
						}
						return;
					}
					if (roundDie.playerId == this.hero.id && this.isSelf && this.haveFreeRespawn)
					{
						this.haveFreeRespawn = false;
						Connection.sendData(PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_DEATH);
						return;
					}
					super.onPacket(packet);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		override protected function checkHero(hero:Hero):Boolean
		{
			return this.hero.id != hero.id && !hero.shaman && !hero.isDead && !hero.inHollow && hero.behaviourController.getState(StateDeath) == null;
		}
	}
}