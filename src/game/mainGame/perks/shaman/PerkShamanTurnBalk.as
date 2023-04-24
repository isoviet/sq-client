package game.mainGame.perks.shaman
{
	import game.mainGame.entity.shaman.OneWayBalk;

	public class PerkShamanTurnBalk extends PerkShamanActive
	{
		public function PerkShamanTurnBalk(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_TURN_BALK;
		}

		override protected function activate():void
		{
			if (!this.hero || !this.hero.game || !turnOneWayBalks())
			{
				this.active = false;
				return;
			}

			super.activate();
			this.active = false;
		}

		private function turnOneWayBalks():Boolean
		{
			if (!this.hero.game)
				return false;

			var oneWayBalks:Array = this.hero.game.map.get(OneWayBalk);
			if (oneWayBalks.length == 0)
				return false;

			var turnedBalk:Boolean = false;
			for each (var balk:OneWayBalk in oneWayBalks)
			{
				if (balk.playerId != this.hero.id)
					continue;

				balk.turn();
				turnedBalk = true;
			}

			return turnedBalk;
		}
	}
}