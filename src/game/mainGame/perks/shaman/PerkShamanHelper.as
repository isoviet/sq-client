package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Timer;

	import Box2D.Common.Math.b2Vec2;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.perks.ICounted;
	import screens.ScreenGame;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterSprite;

	public class PerkShamanHelper extends PerkShamanSelective implements ICounted
	{
		static private const DEFAULT_RADIUS:int = 100 / Game.PIXELS_TO_METRE;

		private var radius:Number = DEFAULT_RADIUS;
		private var heroToTeleport:Hero = null;

		private var radiusView:StarlingAdapterSprite = null;

		private var delayTimer:Timer = new Timer(60 * 10, 100);
		private var selectedHeroEvent: Boolean = false;
		private var _auraSizeDef: Number = 0;

		public function PerkShamanHelper(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_HELPER;
			this.radius *= (1 + countBonus() / 100);
		}

		override protected function onEnded(): void {
			if (selectedHeroEvent)
			{
				onClick();
			}
			else
			{
				super.onEnded();
			}
		}

		override public function dispose():void
		{
			this.heroToTeleport = null;

			this.delayTimer.stop();

			super.dispose();
		}

		override public function resetRound():void
		{
			this.delayTimer.reset();

			super.resetRound();
		}

		override public function get available():Boolean
		{
			return super.available && !this.delayTimer.running;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable || this.delayTimer.running)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		public function get charge():int
		{
			return this.delayTimer.currentCount;
		}

		public function get count():int
		{
			return this.delayTimer.repeatCount;
		}

		public function resetTimer():void
		{}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.radiusView && this.radiusView.parentStarling)
				this.radiusView.parentStarling.removeChildStarling(this.radiusView, false);
		}

		override protected function set selectedHero(heroId:int):void
		{
			if (!this.hero.game)
			{
				this.active = false;
				return;
			}

			this.heroToTeleport = this.hero.game.squirrels.get(heroId);

			if (!this.heroToTeleport || !this.hero.isSelf)
			{
				this.active = false;
				return;
			}

			selectedHeroEvent = true;

			if (!this.radiusView)
			{
				this.radiusView = new StarlingAdapterSprite(new PerkRadius());
				_auraSizeDef = this.radiusView.height;
			}

			this.radiusView.scaleXY(int(this.radius * 2 * Game.PIXELS_TO_METRE) / _auraSizeDef);
			this.radiusView.y = - Hero.Y_POSITION_COEF;

			this.hero.addChildStarling(this.radiusView);
		}

		override protected function onSelectionFinish(selectedHeroesCount:int):void
		{
			if (selectedHeroesCount == 0)
				this.active = false;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundCommand.PACKET_ID:
					var data:Object = (packet as PacketRoundCommand).dataJson;

					if (!('helperTeleport' in data))
					{
						super.onPacket(packet);
						return;
					}

					if (!this.hero || data['helperTeleport'][0] != this.hero.id)
						return;

					if (!this.heroToTeleport || !this.heroToTeleport.isExist || this.heroToTeleport.isDead || this.heroToTeleport.inHollow)
						return;

					this.heroToTeleport.magicTeleportTo(new b2Vec2(data['helperTeleport'][1], data['helperTeleport'][2]));

					this.heroToTeleport.heroView.showActiveAura();
					this.heroToTeleport.heroView.showPerkAnimation(new PerkShamanFactory.perkData[PerkShamanFactory.getClassById(this.code)]['buttonClass'], 1000);
					ScreenGame.sendMessage(this.heroToTeleport.player.id, "", ChatDeadServiceMessage.HELPER_PERK);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		override protected function resetSelection():void
		{
			super.resetSelection();
			this.hero.game.removeEventListener(MouseEvent.CLICK, onClick);
			selectedHeroEvent = false;
		}

		private function onClick():void
		{
			if (!this.hero.game || !this.heroToTeleport)
			{
				this.active = false;
				return;
			}

			var touchPoint:Point = this.hero.game.squirrels.globalToLocal(_globalPos);
			var destination:b2Vec2 = new b2Vec2(touchPoint.x / Game.PIXELS_TO_METRE, touchPoint.y / Game.PIXELS_TO_METRE);

			this.active = false;

			if (!checkDistance(destination))
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'helperTeleport': [this.hero.id, destination.x, destination.y]}));
		}

		private function checkDistance(pos:b2Vec2):Boolean
		{
			var distance:b2Vec2 = this.hero.position.Copy();
			distance.Subtract(pos);

			return distance.Length() < this.radius;
		}
	}
}