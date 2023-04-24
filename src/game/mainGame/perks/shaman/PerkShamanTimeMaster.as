package game.mainGame.perks.shaman
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.perks.ICounted;
	import screens.ScreenGame;

	import by.blooddy.crypto.serialization.JSON;

	import com.greensock.TweenMax;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundCommand;
	import protocol.packages.server.PacketRoundHollow;

	public class PerkShamanTimeMaster extends PerkShamanActive implements ICounted
	{
		static private const RADIUS:Number = 100 / Game.PIXELS_TO_METRE;

		private var timer:Timer = new Timer(250);
		private var timeChecks:Array = [];

		private var squirrelsCount:int = 0;
		private var newPositions:Object = {};

		private var view:MovieClip = null;

		private var delayTimer:Timer = new Timer(60 * 10, 100);

		public function PerkShamanTimeMaster(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_TIME_MASTER;

			if (!this.hero.isSelf || ScreenGame.roundTime < 0)
				return;

			startTimer();
		}

		override public function dispose():void
		{
			if (this.hero)
			{
				this.hero.removeEventListener(SquirrelEvent.SHAMAN, backToNormal);
				this.hero.removeEventListener(SquirrelEvent.LEAVE, backToNormal);
				this.hero.removeEventListener(SquirrelEvent.DIE, backToNormal);
				if (this.hero.isSelf)
					stopTimer();
			}

			if (this.view)
				this.view.removeEventListener(Event.CHANGE, onComplete);

			this.delayTimer.stop();

			super.dispose();
		}

		override public function reset():void
		{
			this.timeChecks.splice(0);
			super.reset();
		}

		override public function resetRound():void
		{
			this.delayTimer.reset();
			this.timeChecks.splice(0);
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
		{
			this.timeChecks.splice(0);
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused || this.hero.isDead || this.hero.inHollow)
			{
				this.active = false;
				return;
			}

			super.activate();

			this.hero.game.paused = true;

			this.hero.addEventListener(SquirrelEvent.SHAMAN, backToNormal);
			this.hero.addEventListener(SquirrelEvent.LEAVE, backToNormal);
			this.hero.addEventListener(SquirrelEvent.DIE, backToNormal);

			this.view = new ChronosPerkView();
			this.view.addEventListener(Event.CHANGE, onComplete);
			this.view.y = - Hero.Y_POSITION_COEF;
			this.hero.heroView.addChild(this.view);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.hero)
			{
				this.hero.removeEventListener(SquirrelEvent.SHAMAN, backToNormal);
				this.hero.removeEventListener(SquirrelEvent.LEAVE, backToNormal);
				this.hero.removeEventListener(SquirrelEvent.DIE, backToNormal);
				if (this.hero.game)
					this.hero.game.paused = false;
			}

			if (!this.view)
				return;

			this.view.removeEventListener(Event.CHANGE, onComplete);

			if (this.view.parent)
				this.view.parent.removeChild(this.view);
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoomRound.PACKET_ID, PacketRoundCommand.PACKET_ID,
				PacketRoundHollow.PACKET_ID]);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (this.hero == null)
				return;

			switch (packet.packetId)
			{
				case PacketRoomRound.PACKET_ID:
					if ((packet as PacketRoomRound).type != PacketServer.ROUND_START)
						return;

					if (!this.hero.isSelf)
						return;

					startTimer();
					break;
				case PacketRoundHollow.PACKET_ID:
					if ((packet as PacketRoundHollow).playerId != this.hero.id)
						return;
					this.active = false;
					return;
				case PacketRoundCommand.PACKET_ID:
					var data:Object = (packet as PacketRoundCommand).dataJson;

					if (!('timeMaster' in data))
						return;

					if (!this.hero || data['timeMaster'][0] != this.hero.id)
						return;

					if (!this.active)
						return;

					this.newPositions = {};
					this.squirrelsCount = 0;
					tweenSquirrels(data['timeMaster'][1]);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function onComplete(e:Event):void
		{
			this.view.removeEventListener(Event.COMPLETE, onComplete);
			if (this.view.parent)
				this.view.parent.removeChild(this.view);

			flashback();
		}

		private function startTimer():void
		{
			if (this.timer.running)
				return;

			this.timer.addEventListener(TimerEvent.TIMER, checkSquirrels);
			this.timer.reset();
			this.timer.start();

			this.timeChecks.splice(0);
		}

		private function stopTimer():void
		{
			if (!this.timer.running)
				return;

			this.timeChecks.splice(0);
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER, checkSquirrels);
		}

		private function checkSquirrels(e:TimerEvent):void
		{
			if (this.hero.game && this.hero.game.paused)
				return;

			if (this.timeChecks.length == int(countBonus() * 1000 / this.timer.delay))
				this.timeChecks.shift();

			var positions:Object = {};

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (hero && !hero.isDead)
					positions[hero.id] = {'pos': hero.position.Copy(), 'vel': hero.velocity.Copy(), 'angle': hero.angle};
			}
			this.timeChecks.push(positions);
		}

		private function backToNormal(e:SquirrelEvent):void
		{
			this.active = false;
		}

		private function flashback():void
		{
			if (this.timeChecks.length == 0)
				deactivate();

			if (this.hero.isSelf && (this.timeChecks.length == 0) || !this.hero || !this.hero.game)
			{
				this.active = false;
				return;
			}

			if (!this.hero.isSelf)
				return;

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'timeMaster': [this.hero.id, this.timeChecks.shift()]}));
		}

		private function tweenSquirrels(positions:Object):void
		{
			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (!checkHero(hero) || !(hero.id in positions))
					continue;

				if (!this.isMaxLevel && hero.id != this.hero.id)
					continue;

				if (this.isMaxLevel && !checkDistance(hero))
					continue;

				this.squirrelsCount++;
				this.newPositions[hero.id] = {'pos': new b2Vec2(positions[hero.id]['pos'].x, positions[hero.id]['pos'].y), 'vel': new b2Vec2(positions[hero.id]['vel'].x, positions[hero.id]['vel'].y), 'angle': positions[hero.id]['angle']};

				TweenMax.to(hero, 1, {'x': positions[hero.id]['pos'].x * Game.PIXELS_TO_METRE, 'y': positions[hero.id]['pos'].y * Game.PIXELS_TO_METRE, 'rotation': positions[hero.id]['angle'] * Game.R2D, 'onComplete': onCompleteTween});
			}

			if (this.squirrelsCount == 0)
				this.active = false;
		}

		private function onCompleteTween():void
		{
			if (--this.squirrelsCount != 0)
				return;

			if (this.hero && this.hero.game && this.hero.game.squirrels.players)
			{
				for (var heroId:String in this.newPositions)
				{
					var squirrel:Hero = this.hero.game.squirrels.get(int(heroId));
					if (!checkHero(squirrel))
						continue;

					squirrel.position = this.newPositions[heroId]['pos'];
					squirrel.velocity = this.newPositions[heroId]['vel'];
					squirrel.angle = this.newPositions[heroId]['angle'];
				}
			}

			this.active = false;

			this.delayTimer.reset();
			this.delayTimer.start();
		}

		private function checkHero(hero:Hero):Boolean
		{
			return hero && hero.isExist && !hero.isDead && !hero.inHollow && !hero.hover;
		}

		private function checkDistance(hero:Hero):Boolean
		{
			var distance:b2Vec2 = this.hero.position.Copy();
			distance.Subtract(hero.position);

			return distance.Length() <= RADIUS;
		}
	}
}