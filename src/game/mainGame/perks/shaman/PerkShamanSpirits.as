package game.mainGame.perks.shaman
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.entity.simple.GameBody;

	public class PerkShamanSpirits extends PerkShamanActive
	{
		private var timer:Timer = new Timer(10, 100);

		private var ghostBodies:Array = [];

		public function PerkShamanSpirits(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_SPIRITS;

			this.timer.delay = countBonus() * 10;
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}

		override public function dispose():void
		{
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
			this.timer.stop();

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
			return super.available && !this.active;
		}

		override protected function activate():void
		{
			if (!this.hero || !this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			deactivateOtherPerks();

			var bodies:Array = this.hero.game.map.get(GameBody, true);
			for each (var body:GameBody in bodies)
			{
				if (!body || !body.ghost)
					continue;

				body.ghost = false;
				body.setFilter(!this.isMaxLevel ? GameBody.GHOST_FILTER : []);
				this.ghostBodies.push(body);
			}

			if (!this.buff)
				this.buff = createBuff(0.5);

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (!(hero && hero.isExist))
					continue;

				hero.heroView.showActiveAura();
				hero.addBuff(this.buff, this.timer);
			}

			this.timer.reset();
			this.timer.start();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (!(hero && hero.isExist))
					continue;

				hero.removeBuff(this.buff, this.timer);
			}

			for each (var body:GameBody in this.ghostBodies)
			{
				if (!body )
					continue;

				body.ghost = true;
			}

			this.ghostBodies.splice(0);
		}

		private function deactivateOtherPerks():void
		{
			if (!this.hero || !this.hero.game)
				return;

			var squirrels:Object = this.hero.game.squirrels.players;
			for each (var hero:Hero in squirrels)
			{
				if (!hero || hero.isDead || hero.inHollow || !hero.shaman)
					continue;

				for (var i:int = 0; i < hero.perksShaman.length; i++)
				{
					if ((hero.perksShaman[i] is PerkShamanSpirits) && (hero.perksShaman[i] != this) && hero.perksShaman[i].active)
						hero.perksShaman[i].active = false;
				}
			}
		}

		private function onComplete(e:TimerEvent):void
		{
			this.active = false;
		}
	}
}