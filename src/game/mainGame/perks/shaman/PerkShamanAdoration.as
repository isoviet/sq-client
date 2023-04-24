package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.utils.Timer;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.perks.ICounted;

	public class PerkShamanAdoration extends PerkShamanActive implements ICounted
	{
		static private const RADIUS:Number = 110 / Game.PIXELS_TO_METRE;

		private var delayTimer:Timer = new Timer(300, 100);

		public function PerkShamanAdoration(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_ADORATION;
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

		override public function dispose():void
		{
			this.delayTimer.stop();

			super.dispose();
		}

		override public function resetRound():void
		{
			this.delayTimer.reset();

			super.resetRound();
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

		override protected function activate():void
		{
			super.activate();

			this.hero.addEventListener(SquirrelEvent.EMOTION, adoreShaman);

			if (!this.buff)
				this.buff = createBuff(0);
			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;

			this.hero.removeEventListener(SquirrelEvent.EMOTION, adoreShaman);

			this.hero.removeBuff(this.buff);
		}

		private function adoreShaman(e:SquirrelEvent):void
		{
			if (!this.hero.game)
				return;

			if (delayTimer.running)
				return;

			var emotionType:int = e.player.heroView.emotionType;

			if (emotionType != Hero.EMOTION_CRY && emotionType != Hero.EMOTION_LAUGH)
				return;

			var useCount:int = countBonus();

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				var distance:b2Vec2 = this.hero.position.Copy();
				distance.Subtract(hero.position);

				if (!checkHero(hero) || (distance.Length() > RADIUS && !this.isMaxLevel))
					continue;

				if (useCount-- == 0)
					break;

				hero.sendSmile(emotionType);
			}

			if (useCount == countBonus() || this.isMaxLevel)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}

		private function checkHero(hero:Hero):Boolean
		{
			return !(!hero || !hero.isExist || hero.isDead || hero.inHollow || hero.isHare || hero.shaman);
		}
	}
}