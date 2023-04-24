package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import Box2D.Common.Math.b2Vec2;

	public class PerkShamanSpeedy extends PerkShamanActive
	{
		static private const RADIUS:Number = 100 / Game.PIXELS_TO_METRE;

		private var timer:Timer = new Timer(100, 100);

		private var speedyHeroes:Object = {};

		public function PerkShamanSpeedy(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_SPEEDY;

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}

		override public function dispose():void
		{
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			this.active = false;

			super.dispose();
		}

		override public function reset():void
		{
			this.timer.reset();

			super.reset();
		}

		override public function get available():Boolean
		{
			return super.available && !this.timer.running;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override protected function activate():void
		{
			if (!this.hero || !this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			var speedBonus:Number = this.hero.runSpeed * countBonus() / 100;
			this.speedyHeroes[this.hero.id] = speedBonus;
			this.hero.runSpeed += speedBonus;

			if (!this.buff)
				this.buff = createBuff(0.5);

			this.hero.addBuff(this.buff, this.timer);
			this.hero.heroView.showActiveAura();

			this.timer.reset();
			this.timer.start();

			if (!this.isMaxLevel)
				return;

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (!checkHero(hero) || !checkDistance(hero))
					continue;

				speedBonus = hero.runSpeed * countBonus() / 100;
				this.speedyHeroes[hero.id] = speedBonus;
				hero.runSpeed += speedBonus;
				hero.addBuff(this.buff, this.timer);
				hero.heroView.showActiveAura();
			}
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;

			this.hero.removeBuff(this.buff, this.timer);

			this.hero.runSpeed -= this.speedyHeroes[this.hero.id];
			delete this.speedyHeroes[this.hero.id];

			if (!this.isMaxLevel)
				return;

			if (!this.hero.game)
				return;

			for (var id:String in this.speedyHeroes)
			{
				var hero:Hero = this.hero.game.squirrels.get(int(id));
				if (!hero)
					continue;

				hero.runSpeed -= this.speedyHeroes[id];
				hero.removeBuff(this.buff);

				delete this.speedyHeroes[hero.id];
			}

			this.speedyHeroes = {};
		}

		private function onComplete(e:TimerEvent):void
		{
			this.active = false;
		}

		private function checkHero(hero:Hero):Boolean
		{
			return hero && hero.isExist && !hero.isDead && !hero.inHollow && !hero.isHare && !hero.isDragon && (hero.id != this.hero.id);
		}

		private function checkDistance(hero:Hero):Boolean
		{
			var distance:b2Vec2 = this.hero.position.Copy();
			distance.Subtract(hero.position);

			return distance.Length() <= RADIUS;
		}
	}
}