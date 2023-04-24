package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.perks.Perk;
	import game.mainGame.perks.mana.PerkFactory;
	import screens.ScreenGame;
	import views.ClothesImageLoader;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;
	import protocol.packages.server.PacketRoundSkillAction;

	public class PerkClothesWizard extends PerkClothes
	{
		static private const STOLEN_PERKS_CONSTRAINT:int = 3;
		static private const PERKS_TO_STEAL:Array = [0, 1, 2, 3, 4, 5, 6, 9];

		private var view:MovieClip;
		private var heroesInAura:Array = [];
		private var stolenPerks:Array = [];

		public function PerkClothesWizard(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override public function get activeTime():Number
		{
			return 30;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.heroView.running && !this.hero.heroView.fly && !this.active && !this.hero.wizard;
		}

		override public function dispose():void
		{
			if (this.view)
				this.view.removeEventListener(Event.CHANGE, onCompleteView);

			if (this.hero)
				this.hero.wizard = false;

			this.heroesInAura.splice(0);

			super.dispose();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.hero || !this.hero.wizard || !this.hero.game || this.stolenPerks.length >= STOLEN_PERKS_CONSTRAINT || this.hero.isDead || this.hero.shaman)
				return;

			var auraPos:Point = this.hero.globalToLocal(this.hero.game.localToGlobal(new Point(this.hero.heroView.aura.x, this.hero.heroView.aura.y))).add(new Point(this.hero.x, this.hero.y));

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (hero.isHare || hero.id == this.hero.id)
					continue;

				var lenght:Number = auraPos.add(new Point(this.hero.heroView.aura.width / 2, this.hero.heroView.aura.width / 2)).subtract(new Point(hero.x, hero.y)).length;

				var index:int = this.heroesInAura.indexOf(hero.id);

				if (hero.isDead || lenght >= this.hero.heroView.aura.width / 2)
				{
					if (index != -1)
						this.heroesInAura.splice(index, 1);
					continue;
				}

				if (index == -1)
					this.heroesInAura.push(hero.id);
			}
		}

		override protected function activate():void
		{
			if (!this.hero || !this.hero.game || this.hero.game.paused)
			{
				this._active = false;
				return;
			}

			super.activate();

			this.view = new WizardAnimation();
			this.view.x = -114;
			this.view.y = -120 - Hero.Y_POSITION_COEF / 2;
			this.view.addEventListener(Event.CHANGE, onCompleteView);
			this.hero.addChild(this.view);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;

			this.heroesInAura.splice(0);
			this.stolenPerks.splice(0);

			this.hero.wizard = false;
			this.hero.removeBuff(this.buff);
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundSkillAction.PACKET_ID]);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (!this.hero || this.hero.isDead || this.hero.shaman)
				return;

			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var skill: PacketRoundSkill = packet as PacketRoundSkill;

					if (skill.state == PacketServer.SKILL_ERROR)
						break;
					if (skill.type == this.code && skill.playerId == this.hero.id)
					{
						this.active = skill.state == PacketServer.SKILL_ACTIVATE;
						return;
					}

					if ((skill.playerId != this.hero.id) && (this.hero.id == Game.selfId) && (this.heroesInAura.indexOf(skill.playerId) != -1) && (PERKS_TO_STEAL.indexOf(skill.type) != -1) && (skill.state == PacketServer.SKILL_ACTIVATE) && (this.stolenPerks.length < STOLEN_PERKS_CONSTRAINT))
					{
						if (skill.state <= 0 && (skill.state == 1))
							return;

						if (!selfPerkActivated(skill.type))
							Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, skill.playerId, skill.type);
						return;
					}

					if (skill.playerId == this.hero.id && this.hero.id == Game.selfId && this.stolenPerks.indexOf(skill.type) != -1 && skill.state != PacketServer.SKILL_ACTIVATE)
					{
						this.stolenPerks.splice(this.stolenPerks.indexOf(skill.type), 1);
						return;
					}
					break;
				case PacketRoundSkillAction.PACKET_ID:
					var action: PacketRoundSkillAction = packet as PacketRoundSkillAction;
					if (action.type != this.code)
						return;

					if (!this.hero || !this.hero.game  || !this.hero.game.squirrels || this.hero.isDead || !this.hero.player)
						return;

					if (this.hero.id != action.playerId)
						return;

					if (this.hero.id == Game.selfId)
						this.stolenPerks.push(action.data);

					var victim:Hero = this.hero.game.squirrels.get(action.targetId);
					if (victim && victim.player)
						ScreenGame.sendMessage(this.hero.id, gls("Волшебник {0} получил магию «{1}» от игрока {2}", this.hero.player.nameOrig.toString(), PerkFactory.getName(action.data), victim.player.nameOrig.toString()), ChatDeadServiceMessage.BLOCK);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		protected function onCompleteView(e:Event):void
		{
			this.view.removeEventListener(Event.CHANGE, onCompleteView);
			if (!this.hero)
				return;

			if (this.hero.contains(this.view))
				this.hero.removeChild(this.view);

			if (this.hero.id != Game.selfId)
				return;

			this.hero.wizard = true;
			if (!this.buff)
				this.buff = new BuffRadialView(new ClothesImageLoader(201), 0.5, 0, gls("Аура кражи магии"));
			this.hero.addBuff(this.buff);
		}

		private function selfPerkActivated(perkId:int):Boolean
		{
			for each (var perk:Perk in this.hero.perkController.perksMana)
				if (perk.active && (perk is PerkFactory.getPerkClass(perkId)))
					return true;
			return false;
		}
	}
}