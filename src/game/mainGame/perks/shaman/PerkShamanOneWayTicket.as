package game.mainGame.perks.shaman
{
	import flash.events.Event;

	import game.mainGame.Cast;
	import game.mainGame.entity.shaman.OneWayBalk;

	public class PerkShamanOneWayTicket extends PerkShamanCast
	{
		static private const LIFE_TIME:int = 15 * 1000;

		private var useCount:int = 0;

		public function PerkShamanOneWayTicket(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_ONE_WAY_TICKET;
			this.useCount = countBonus();

			if (!this.isMaxLevel)
				return;

			this.hero.perksShaman.push(new PerkShamanTurnBalk(this.hero, [0, 0]));
		}

		override public function get available():Boolean
		{
			return super.available && this.useCount > 0;
		}

		override public function resetRound():void
		{
			super.resetRound();

			this.useCount = countBonus();
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override protected function initCastObject():void
		{
			var balk:OneWayBalk = new OneWayBalk();
			balk.aging = !this.isMaxLevel;
			if (balk.aging)
				balk.lifeTime = LIFE_TIME;

			this.castObject = balk;
		}

		override protected function onCast(result:String):void
		{
			if (this.hero.game.cast.castObject != this.castObject)
				return;

			super.onCast(result);

			if (result != Cast.CAST_COMPLETE)
				return;

			this.useCount--;
		}
	}
}