package game.mainGame.entity.magic
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.ISideObject;
	import game.mainGame.SideIconView;
	import game.mainGame.behaviours.StateJump;
	import game.mainGame.behaviours.StateSpeed;
	import game.mainGame.behaviours.StateStun;
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import screens.ScreenGame;
	import sounds.GameSounds;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkillAction;

	import utils.starling.StarlingAdapterSprite;

	public class SurpriseBox extends EnergyObject implements ISideObject
	{
		static private const SPEED_UP:int = 0;
		static private const GET_NUT:int = 1;
		static private const SPEED_DOWN:int = 2;
		static private const JUMP_DOWN:int = 3;
		static private const STUN:int = 4;

		static private const AWARD_TYPE:Array =
		[
			{'text': gls("получил ускорение")},
			{'text': gls("получил орех")},
			{'text': gls("стал медленее бегать")},
			{'text': gls("стал ниже прыгать")},
			{'text': gls("отравился веселящим газом")}
		];

		private var viewDeath:MovieClip = null;
		private var effectId:int = -1;

		private var hero:Hero;
		private var owner:Hero;

		private var magicView:MovieClip = null;
		private var gasView:MovieClip = null;

		private var buff:BuffRadialView = null;

		private var activated:Boolean = false;

		private var _isVisible: Boolean = false;

		public function SurpriseBox():void
		{
			this.perkCode = PerkClothesFactory.JOKER;
			this.messageId = ChatDeadServiceMessage.JOKER_SURPRISE_BOX;

			super();
		}

		override protected function get animation():MovieClip
		{
			var view:JokerMagicView = new JokerMagicView();
			view.y = 15;
			return view;
		}

		override protected function get beginAnimation():MovieClip
		{
			var view:JokerMagicBegin = new JokerMagicBegin();
			view.y = 15;
			return view;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkillAction.PACKET_ID:
					var packetAction:PacketRoundSkillAction = packet as PacketRoundSkillAction;
					if (packetAction.type != this.perkCode)
						return;

					if (!this.gameInst || this.activated)
						return;

					if (packetAction.targetId == Game.self.id || packetAction.playerId == Game.self.id)
					{
						if (packetAction.data == STUN)
							GameSounds.play("joker_nothing");
						else
							GameSounds.play("joker_open");
					}

					if (packetAction.targetId != this.playerId)
						return;

					this.sended = true;
					this.activated = true;

					this.hero = this.gameInst.squirrels.get(packetAction.playerId);
					this.owner = this.gameInst.squirrels.get(packetAction.targetId);

					this.view.alpha = 0;
					this.beginView.alpha = 0;

					this.viewDeath = new JokerMagicOpen();
					this.viewDeath.y = 15;
					this.viewDeath.addEventListener(Event.CHANGE, onOpen);
					addChild(this.viewDeath);

					if (packetAction.data >= 0)
						this.effectId = packetAction.data;

					switch (this.effectId)
					{
						case SPEED_UP:
							if (this.hero)
								this.hero.behaviourController.addState(new StateSpeed(5, 0.2));
							if (packetAction.playerId != packetAction.targetId && this.owner)
								this.owner.behaviourController.addState(new StateSpeed(5, 0.2));
							this.magicView = new JokerSpeedUp();

							break;
						case GET_NUT:
							if (this.hero)
								this.hero.setMode(Hero.NUT_MOD);
							if (this.owner)
								this.owner.setMode(Hero.NUT_MOD);
							if ((this.hero && this.hero.id == Game.selfId) || (this.owner && this.owner.id == Game.selfId))
								Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
							this.magicView = new JokerGetNut();
							break;
						case SPEED_DOWN:
							if (this.hero)
								this.hero.behaviourController.addState(new StateSpeed(5, -0.25));
							if (packetAction.playerId != packetAction.targetId && this.owner)
								this.owner.behaviourController.addState(new StateSpeed(5, 0.2));
							this.magicView = new JokerSpeedDown();

							break;
						case JUMP_DOWN:
							if (this.hero)
								this.hero.behaviourController.addState(new StateJump(5, -0.5));
							if (packetAction.playerId != packetAction.targetId && this.owner)
								this.owner.behaviourController.addState(new StateSpeed(5, 0.2));
							this.magicView = new JokerJumpDown();

							break;
						case STUN:
							if (this.hero)
								this.hero.behaviourController.addState(new StateStun(3));
							if (packetAction.playerId != packetAction.targetId && this.owner)
								this.owner.behaviourController.addState(new StateSpeed(5, 0.2));
							this.magicView = new JokerStun();

							break;
						default:
							return;
					}

					ScreenGame.sendMessage(packetAction.playerId, AWARD_TYPE[packetAction.data]['text'], this.messageId);

					if (this.hero)
					{
						this.magicView.addEventListener(Event.CHANGE, onComplete);
						this.magicView.y = -Hero.Y_POSITION_COEF;
						this.hero.heroView.addChild(this.magicView);
					}
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.activated ? 1 : 0]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.activated = data[2][0] != 0;

			this.view.alpha = this.activated ? 0 : 1;
			this.beginView.alpha = this.activated ? 0 : 1;
		}

		private function onCompleteGas(e:Event):void
		{
			this.gasView.removeEventListener(Event.CHANGE, onCompleteGas);

			if (this.gasView && this.gasView.parent)
				this.gasView.parent.removeChild(this.gasView);
			this.gasView = null;
		}

		private function onComplete(e:Event):void
		{
			this.magicView.removeEventListener(Event.CHANGE, onComplete);

			if (this.magicView && this.magicView.parent)
				this.magicView.parent.removeChild(this.magicView);
			this.magicView = null;

			if (!this.gameInst || !this.gameInst.squirrels || !this.gameInst.squirrels.isSynchronizing)
				return;
			this.gameInst.map.destroyObjectSync(this, true);
		}

		private function onOpen(e:Event):void
		{
			if (!this.viewDeath)
				return;
			removeChild(this.viewDeath);
			this.viewDeath.removeEventListener(Event.CHANGE, onOpen);

			this.viewDeath = (this.effectId != SPEED_UP && this.effectId != GET_NUT) ? new JokerMagicDeathNegative() : new JokerMagicDeathPositive();
			this.viewDeath.y = 15;
			this.viewDeath.addEventListener(Event.CHANGE, onDeath);
			addChild(this.viewDeath);
		}

		private function onDeath(e:Event):void
		{
			if (!this.viewDeath)
				return;
			removeChild(this.viewDeath);
			this.viewDeath.removeEventListener(Event.CHANGE, onDeath);
		}

		public function get sideIcon():StarlingAdapterSprite
		{
			return new SideIconView(SideIconView.COLOR_PINK, SideIconView.ICON_SURPRISE_BOX);
		}

		public function get showIcon():Boolean
		{
			return !this.activated;
		}

		public function get isVisible():Boolean
		{
			return _isVisible;
		}

		public function set isVisible(value: Boolean):void
		{
			_isVisible = false;
		}
	}
}