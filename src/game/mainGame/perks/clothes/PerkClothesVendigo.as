package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import chat.ChatDeadServiceMessage;
	import game.gameData.CollectionManager;
	import screens.ScreenGame;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundElement;
	import protocol.packages.server.PacketRoundSkill;
	import protocol.packages.server.PacketRoundSkillAction;

	public class PerkClothesVendigo extends PerkClothes
	{
		private var victimView:MovieClip = null;
		private var transformIn:MovieClip = null;
		private var transformOut:MovieClip = null;
		private var isTransform:Boolean = false;
		private var victim:Hero;
		private var alternativeView:AlternativeView;

		public function PerkClothesVendigo(hero:Hero):void
		{
			super(hero);

			this.transformIn = new VendigoTransformIn();
			this.transformOut = new VendigoTransformOut();

			this.activateSound = "vendigo";
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override public function get totalCooldown():Number
		{
			return 60;
		}

		override public function get available():Boolean
		{
			return super.available && (CollectionManager.currentCollectionId == -1);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.active && this.isSelf)
				onUpdate();
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundElement.PACKET_ID, PacketRoundSkillAction.PACKET_ID]);
		}

		override protected function activate():void
		{
			super.activate();

			if (this.isTransform || !this.hero)
				return;

			this.isTransform = true;

			this.hero.changeView(this.transformIn, true);
			this.transformIn.addEventListener(Event.CHANGE, onTransformIn);
			this.transformIn.gotoAndPlay(0);

			this.hero.jumpVelocity += 9;
			this.hero.runSpeed *= 1.5;

			this.alternativeView = new AlternativeView(["VendigoTransformRun", "VendigoTransformStand"]);
			this.alternativeView.name = "Vendigo";
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.transformIn)
			{
				this.transformIn.removeEventListener(Event.CHANGE, onTransformIn);
				this.transformIn.gotoAndStop(0);
			}

			if (this.hero)
				this.hero.isVendigo = false;
			if (this.victim)
				this.victim.isVictim = false;

			if (this.hero && this.hero.id == Game.selfId)
				Connection.sendData(PacketClient.ROUND_SKILL, this.code, false, 0, "");

			if (this.victim && this.victim.heroView.contains(this.victimView))
				this.victim.heroView.removeChild(this.victimView);
			this.victim = null;
			this.victimView = null;

			if (!this.hero)
				return;

			this.isTransform = false;

			this.hero.changeView(this.transformOut, true);
			this.transformOut.addEventListener(Event.CHANGE, onTransformOut);
			this.transformOut.gotoAndPlay(0);

			this.hero.jumpVelocity -= 9;
			this.hero.runSpeed /= 1.5;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (!this.hero)
				return;
			switch (packet.packetId)
			{
				case PacketRoundElement.PACKET_ID:
					if (Game.selfId != this.hero.id)
						return;
					if (this.hero.id != (packet as PacketRoundElement).playerId)
						return;
					this.active = false;
					break;
				case PacketRoundDie.PACKET_ID:
					var die: PacketRoundDie = packet as PacketRoundDie;
					if (this.victim != null && this.victim.id == die.playerId)
					{
						if (Game.selfId == this.hero.id)
							removeCollection();
						Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, this.victim.id);
					}
					if (this.hero.id == die.playerId)
						this.active = false;
					break;
				case PacketRoomLeave.PACKET_ID:
					var leave:PacketRoomLeave = packet as PacketRoomLeave;
					if (this.victim != null && this.victim.id == leave.playerId)
					{
						if (Game.selfId == this.hero.id)
							removeCollection();
						Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, this.victim.id);
					}
					if (this.hero.id == leave.playerId)
						this.active = false;
					break;
				case PacketRoundSkill.PACKET_ID:
					var skill: PacketRoundSkill = packet as PacketRoundSkill;
					if (skill.state == PacketServer.SKILL_ERROR)
					{
						if (Game.selfId == skill.playerId)
							ScreenGame.sendMessage(this.hero.id, gls("Магия недоступна. Для тебя ещё нет подходящей цели."), ChatDeadServiceMessage.VENDIGO_PERK);
						return;
					}
					if (this.hero.id != skill.playerId || this.code != skill.type)
						return;
					this.active = skill.state == PacketServer.SKILL_ACTIVATE;
					dispatchEvent(new Event("STATE_CHANGED"));

					if (skill.state != PacketServer.SKILL_ACTIVATE)
						return;
					this.victim = this.hero.game.squirrels.get(skill.targetId);
					if (this.victim == null)
						this.active = false;
					else
					{
						if (Game.selfId == skill.targetId)
						{
							ScreenGame.sendMessage(this.hero.id, gls("Игрок {0} охотится за тобой!", this.hero.playerName), ChatDeadServiceMessage.VENDIGO_PERK);
							this.hero.isVendigo = true;
						}
						else if (Game.selfId == skill.playerId)
						{
							ScreenGame.sendMessage(this.hero.id, gls("Ты начал охоту за игроком {0}", this.victim.playerName), ChatDeadServiceMessage.VENDIGO_PERK);
							this.victim.isVictim = true;
						}
						this.victimView = new VendigoVictimView();
						this.victimView.visible = Game.selfId == skill.playerId || Game.selfId == skill.targetId;
						this.victimView.y = - Hero.Y_POSITION_COEF - 55;
						this.victim.heroView.addChild(this.victimView);
					}
					break;
				case PacketRoundSkillAction.PACKET_ID:
					var action: PacketRoundSkillAction= packet as PacketRoundSkillAction;
					if (this.hero.id != action.playerId || this.code != action.type || this.victim == null || this.victim.id != action.targetId)
						return;

					removeCollection();

					this.active = false;
					break;
			}
		}

		private function removeCollection():void
		{
			if (this.victim.id == Game.selfId)
			{
				CollectionManager.currentCollectionId = -1;
				this.hero.game.squirrels.selfCollected = false;
			}
			this.victim.heroView.hideCollectionAnimation();
		}

		protected function onTransformIn(e:Event):void
		{
			this.transformIn.removeEventListener(Event.CHANGE, onTransformIn);
			this.transformIn.gotoAndStop(0);

			if (!this.hero)
				return;
			this.hero.changeView(this.alternativeView);
		}

		protected function onTransformOut(e:Event):void
		{
			this.transformOut.removeEventListener(Event.CHANGE, onTransformOut);
			this.transformOut.gotoAndStop(0);

			if (!this.hero)
				return;
			this.hero.changeView();
		}

		private function onUpdate():void
		{
			if (this.hero && this.victim && this.active)
			{
				var pos:b2Vec2 = this.victim.position.Copy();
				pos.Subtract(this.hero.position);
				if (pos.Length() < 4)
				{
					removeCollection();
					Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, this.victim.id);
					this.active = false;
				}
			}
		}
	}
}