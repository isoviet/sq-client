package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import by.blooddy.crypto.serialization.JSON;

	import com.greensock.TweenMax;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesChronos extends PerkClothes
	{
		static private const FLASHBACK_TIME:Number = 3;
		static private const CHECK_TIME:Number = 0.5;

		private var timeDelay:Number = 0;

		private var timeChecks:Array = [];

		private var squirrelsCount:int = 0;
		private var newPositions:Object = {};

		private var view:MovieClip = null;

		public function PerkClothesChronos(hero:Hero):void
		{
			super(hero);

			this.activateSound = "chronos";
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.timeDelay <= 0)
			{
				checkSquirrels();
				this.timeDelay = CHECK_TIME;
			}
			else
				this.timeDelay -= timeStep;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get startCooldown():Number
		{
			return 20;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override public function get json():String
		{
			if (this.active)
				return "";

			if (this.timeChecks.length == 0)
				return "";

			if (this.timeChecks.length < int(FLASHBACK_TIME / CHECK_TIME))
				var answer:Object = this.timeChecks[0];
			else
				answer = this.timeChecks[this.timeChecks.length - int(FLASHBACK_TIME / CHECK_TIME)];
			return by.blooddy.crypto.serialization.JSON.encode(answer);
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.heroView.fly;
		}

		override public function dispose():void
		{
			if (this.view)
				this.view.removeEventListener(Event.CHANGE, onComplete);
			this.hero.game.paused = false;
			super.dispose();
		}

		override public function resetRound():void
		{
			this.timeChecks.splice(0);
			super.resetRound();
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused || this.hero.isDead || this.hero.inHollow)
			{
				this.active = false;
				return;
			}

			super.activate();

			this.view = new ChronosPerkView();
			this.view.addEventListener(Event.CHANGE, onCompleteView);
			this.view.y = -60;
			this.hero.heroView.addChild(this.view);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.game.paused = false;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (this.hero == null)
				return;

			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var roundSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (roundSkill.state == PacketServer.SKILL_ERROR)
						return;
					if (roundSkill.type != this.code || roundSkill.playerId != this.hero.id)
						return;
					this.active = roundSkill.state == PacketServer.SKILL_ACTIVATE;

					if (roundSkill.state != PacketServer.SKILL_ACTIVATE)
						return;
					this.newPositions = {};
					this.squirrelsCount = 0;

					tweenSquirrels(roundSkill.scriptJson);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		protected function onCompleteView(e:Event):void
		{
			this.view.removeEventListener(Event.CHANGE, onCompleteView);

			if (this.view && this.view.parent)
				this.view.parent.removeChild(this.view);
		}

		private function checkSquirrels():void
		{
			if (this.hero.game && this.hero.game.paused)
				return;

			var positions:Object = {};
			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (!hero.isSelf && hero.isSquirrel)
					positions[hero.id] = {'pos': hero.position.Copy(), 'vel': hero.velocity.Copy(), 'angle': hero.angle};
			}
			this.timeChecks.push(positions);
		}

		private function tweenSquirrels(positions:Object):void
		{
			this.hero.game.paused = true;

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (!checkHero(hero) || !(hero.id in positions))
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
		}

		private function checkHero(hero:Hero):Boolean
		{
			return hero && hero.isExist && !hero.shaman && !hero.isDead && !hero.inHollow  && !hero.hover;
		}
	}
}