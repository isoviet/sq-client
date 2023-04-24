package game.mainGame.perks.shaman
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Vec2;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundCommand;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundRespawn;

	import utils.Animation;

	public class PerkShamanHeavensGate extends PerkShamanActive
	{
		static private const GATE_SPEED:int = 5;

		static private var bonuses:Object = {};

		private var timer:Timer = new Timer(100, 100);

		private var gateSprite:Sprite = null;

		private var heroId:int;

		public function PerkShamanHeavensGate(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_HEAVENS_GATE;

			this.heroId = this.hero.id;

			this.timer.delay = countBonus() * 10;
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}

		static private function getPerformer():int
		{
			var maxBonus:Number = 0;
			var perfomerId:int;

			for (var id:String in bonuses)
			{
				if (bonuses[id] > maxBonus)
				{
					maxBonus = bonuses[id];
					perfomerId = int(id);
				}
			}

			return perfomerId;
		}

		override public function get available():Boolean
		{
			return super.available && !this.active && !this.hero.heroView.running && !this.hero.heroView.fly && !this.hero.game.paused && this.activationCount < 2;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override public function dispose():void
		{
			removeGates();

			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			super.dispose();
		}

		override public function reset():void
		{
			this.timer.reset();

			super.reset();
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.buff)
				this.buff = createBuff(0.5);

			this.hero.addBuff(this.buff, this.timer);

			bonuses[this.heroId] = countBonus();

			if (!this.hero.isSelf || !this.hero.shaman)
				return;

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'heavensGate': [this.hero.id, this.hero.x, this.hero.y]}));
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.hero)
				this.hero.removeBuff(this.buff, this.timer);

			delete bonuses[this.heroId];

			removeGates();
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundCommand.PACKET_ID, PacketRoundDie.PACKET_ID,
				PacketRoundRespawn.PACKET_ID]);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (!this.hero || !this.hero.game || !this.hero.game.squirrels || !this.hero.game.map)
				return;
			Logger.add('PerkShamanHeavensGate: packet.type:' + packet.packetId);
			switch (packet.packetId)
			{
				case PacketRoundCommand.PACKET_ID:
					Logger.add('PerkShamanHeavensGate:  PacketRoundCommand.PACKET_ID');
					var data:Object = (packet as PacketRoundCommand).dataJson;
					if (!data)
						return;

					if (!('heavensGate' in data))
						return;

					if (data['heavensGate'][0] != this.hero.id)
						return;

					this.gateSprite = new Sprite();
					this.gateSprite.x = data['heavensGate'][1];
					this.gateSprite.y = data['heavensGate'][2];
					this.gateSprite.rotation = this.hero.rotation;
					this.hero.game.map.userBottomSprite.addChild(this.gateSprite);

					var gate:Animation = new Animation(new HeavensGate);
					gate.x = -47;
					gate.y = -55;
					gate.play();
					gate.loop = false;
					this.gateSprite.addChild(gate);

					this.timer.reset();
					this.timer.start();

					if (!this.isMaxLevel)
						return;

					EnterFrameManager.addListener(moveGates);
					break;
				case PacketRoundDie.PACKET_ID:
					var die: PacketRoundDie = packet as PacketRoundDie;

					Logger.add('PerkShamanHeavensGate: PacketRoundDie.PACKET_ID');
					if (!this.active)
						return;

					if (die.playerId == this.hero.id)
						return;

					var hero:Hero = this.hero.game.squirrels.get(die.playerId);
					if (!hero || !hero.isSelf)
						return;

					setTimeout(Connection.sendData, 100, PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_HEAVENS_GATE);
					break;
				case PacketRoundRespawn.PACKET_ID:
					var respawn: PacketRoundRespawn = packet as PacketRoundRespawn;

					Logger.add('PerkShamanHeavensGate:  PacketRoundRespawn.PACKET_ID');
					if (respawn.respawnType != PacketServer.RESPAWN_HEAVENS_GATE)
						return;

					if (respawn.status == PacketServer.RESPAWN_FAIL)
						return;

					if (!this.active || getPerformer() != this.heroId)
						return;

					var respawnHero:Hero = this.hero.game.squirrels.get(respawn.playerId);
					if (!respawnHero || !respawnHero.isDead || respawnHero.healedByDeath || respawnHero.healedByPerk || !this.gateSprite)
						return;

					setTimeout(respawnHero.teleportTo, 0, (new b2Vec2(this.gateSprite.x / Game.PIXELS_TO_METRE, this.gateSprite.y / Game.PIXELS_TO_METRE)));
					break;
				default:
					Logger.add('PerkShamanHeavensGate:  default');
					super.onPacket(packet);
					break;
			}
		}

		private function onComplete(e:TimerEvent):void
		{
			this.active = false;
		}

		private function moveGates():void
		{
			if (!this.hero || !this.hero.isExist || this.hero.inHollow)
				return;

			var direction:Point = this.hero.parent.globalToLocal(this.hero.localToGlobal(new Point(this.hero.heroView.direction ? 70 : -70, 0))).subtract(new Point(this.gateSprite.x, this.gateSprite.y));

			if (direction.length < GATE_SPEED)
				return;

			direction.normalize(direction.length < 3 * GATE_SPEED ? direction.length / 2 : GATE_SPEED);

			this.gateSprite.x += direction.x;
			this.gateSprite.y += direction.y;
			this.gateSprite.rotation = this.hero.rotation;
		}

		private function removeGates():void
		{
			if (this.gateSprite && this.gateSprite.parent)
				this.gateSprite.parent.removeChild(this.gateSprite);

			EnterFrameManager.removeListener(moveGates);
		}
	}
}