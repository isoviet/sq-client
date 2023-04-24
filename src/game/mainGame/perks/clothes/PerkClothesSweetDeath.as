package game.mainGame.perks.clothes
{
	import chat.ChatDeadServiceMessage;
	import game.gameData.CollectionManager;
	import game.mainGame.behaviours.StateSweetDeath;
	import screens.ScreenGame;
	import sounds.GameSounds;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundSkill;
	import protocol.packages.server.PacketRoundSkillAction;

	public class PerkClothesSweetDeath extends PerkClothesSelective
	{
		protected var state:StateSweetDeath = null;
		protected var curseHero:Hero = null;

		public function PerkClothesSweetDeath(hero:Hero):void
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return 5;
		}

		override public function get available():Boolean
		{
			return super.available && this.curseHero == null && (CollectionManager.currentCollectionId == -1);
		}

		override public function resetRound():void
		{
			super.resetRound();

			this.state = null;
			this.curseHero = null;
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundSkillAction.PACKET_ID]);
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
							this.state = new StateSweetDeath(0);
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
						GameSounds.play("SweetDeath_haha");
						if (this.isSelf && CollectionManager.currentCollectionId == -1)
							Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, this.curseHero.id);

						this.curseHero.behaviourController.removeState(this.state);
						this.curseHero = null;
						this.state = null;
						return;
					}
					super.onPacket(packet);
					break;
				case PacketRoundSkillAction.PACKET_ID:
					var roundSkillAction:PacketRoundSkillAction = packet as PacketRoundSkillAction;
					var target:Hero = this.hero.game.squirrels.get(roundSkillAction.targetId);
					if (!target)
						return;
					if (roundSkillAction.targetId == Game.selfId)
					{
						CollectionManager.currentCollectionId = -1;
						this.hero.game.squirrels.selfCollected = false;
						Connection.sendData(PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_DEATH);
						if (target.hasNut)
						{
							Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_LOST);
							target.setMode(Hero.NUDE_MOD);
						}
					}
					target.heroView.hideCollectionAnimation();
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		override protected function checkHero(hero:Hero):Boolean
		{
			return this.hero.id != hero.id && !hero.shaman && !hero.isDead && !hero.inHollow && hero.behaviourController.getState(StateSweetDeath) == null;
		}
	}
}