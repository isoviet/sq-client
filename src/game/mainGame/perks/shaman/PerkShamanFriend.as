package game.mainGame.perks.shaman
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.perks.ICounted;
	import screens.ScreenGame;

	public class PerkShamanFriend extends PerkShamanSelective implements ICounted
	{
		static private const MAX_LEVEL_USE_COUNT:int = 2;

		private var timer:Timer = new Timer(100, 100);
		private var delayTimer:Timer = new Timer(150, 100);

		private var selectedHeroBonuses:Object = {};

		public function PerkShamanFriend(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_FRIEND;

			this.selectionsCount = this.isMaxLevel ? MAX_LEVEL_USE_COUNT : 1;
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, backToNormal);
		}

		override public function get available():Boolean
		{
			return super.available && !this.delayTimer.running && !this.timer.running;
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
			backToNormal();

			this.delayTimer.stop();

			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, backToNormal);

			super.dispose();
		}

		override public function reset():void
		{
			this.timer.reset();

			backToNormal();

			this.selectedHeroBonuses = {};

			super.reset();
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

		override protected function set selectedHero(heroId:int):void
		{
			if (!this.hero.game)
				return;

			var hero:Hero = this.hero.game.squirrels.get(heroId);

			if (!hero || hero.isDragon)
				return;

			super.selectedHero = heroId;

			var speedBonus:Number = hero.runSpeed * countBonus() / 100;
			var jumpBonus:int = hero.jumpVelocity * countBonus() / 100;

			this.selectedHeroBonuses[hero.id] = {'speed': speedBonus, 'jump': jumpBonus};

			hero.runSpeed += speedBonus;
			hero.jumpVelocity += jumpBonus;

			if (!this.buff)
				this.buff = createBuff(0.5);

			hero.addBuff(this.buff, this.timer);

			ScreenGame.sendMessage(hero.player.id, "", ChatDeadServiceMessage.FRIEND_PERK);
		}

		override protected function onSelectionFinish(selectedHeroesCount:int):void
		{
			super.onSelectionFinish(selectedHeroesCount);

			if (selectedHeroesCount == 0)
				return;

			this.timer.reset();
			this.timer.start();

			if (!this.hero.isSelf)
				return;

			this.delayTimer.reset();
			this.delayTimer.start();
		}

		private function backToNormal(e:TimerEvent = null):void
		{
			if (!this.hero || !this.hero.game)
				return;

			for (var playerId:String in this.selectedHeroBonuses)
			{
				var player:Hero = this.hero.game.squirrels.get(int(playerId));
				if (!player)
					continue;

				player.runSpeed -= this.selectedHeroBonuses[player.id]['speed'];
				player.jumpVelocity -= this.selectedHeroBonuses[player.id]['jump'];

				player.removeBuff(this.buff, this.timer);
				delete this.selectedHeroBonuses[player.id];
			}
		}
	}
}