package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import game.mainGame.entity.magic.MagicianCard;
	import game.mainGame.gameNet.GameMapNet;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;
	import protocol.packages.server.PacketRoundSkillAction;

	public class PerkClothesMagician extends PerkClothes
	{
		private var hatAnimation:MovieClip = null;
		private var allow:Boolean = true;

		public function PerkClothesMagician(hero:Hero):void
		{
			super(hero);

			this.activateSound = "focus";
		}

		override public function get available():Boolean
		{
			return super.available && this.allow && !this.hero.heroView.fly && !this.hero.heroView.running;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.hatAnimation)
				this.hatAnimation.removeEventListener(Event.CHANGE, createCard);
		}

		override public function resetRound():void
		{
			super.resetRound();

			this.allow = true;
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused)
			{
				this._active = false;
				return;
			}

			resetTransformations();

			super.activate();

			this.hatAnimation = new MagicianHatAnimation();
			this.hatAnimation.addEventListener(Event.CHANGE, createCard);
			this.hatAnimation.x = - 20 * this.hatAnimation.scaleX;
			this.hatAnimation.y = - Hero.Y_POSITION_COEF - 110;
			this.hero.heroView.addChild(this.hatAnimation);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var skill:PacketRoundSkill = packet as PacketRoundSkill;
					if (skill.state == PacketServer.SKILL_ERROR || skill.type != this.code || this.hero == null || skill.playerId != this.hero.id)
						return;
					this.active = skill.state == PacketServer.SKILL_ACTIVATE;
					this.allow = false;
					break;
				case PacketRoundSkillAction.PACKET_ID:
					var action: PacketRoundSkillAction = packet as PacketRoundSkillAction;
					if (action.type != this.code)
						return;
					if (action.targetId <= 0 || action.targetId != this.hero.id)
						return;
					this.active = false;
					this.allow = true;
					dispatchEvent(new Event("STATE_CHANGED"));
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundSkillAction.PACKET_ID]);
		}

		private function createCard(e:Event):void
		{
			this.active = false;

			this.hatAnimation.removeEventListener(Event.CHANGE, createCard);

			if (this.hatAnimation && this.hatAnimation.parent)
				this.hatAnimation.parent.removeChild(this.hatAnimation);

			var card:MagicianCard = new MagicianCard();
			card.isMan = true;
			card.perkCode = this.code;
			(this.hero.game.map as GameMapNet).createObject(this.hero.id, card);
		}
	}
}