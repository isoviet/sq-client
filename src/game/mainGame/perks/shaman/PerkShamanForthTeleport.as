package game.mainGame.perks.shaman
{
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	public class PerkShamanForthTeleport extends PerkShamanActive
	{
		static private const DISTANCE:Number = 150 / Game.PIXELS_TO_METRE;

		private var useCount:int = 0;

		public function PerkShamanForthTeleport(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_FORTH_TELEPORT;
			this.useCount = countBonus();
		}

		override public function get available():Boolean
		{
			return super.available && (this.activationCount < this.useCount) && (!(this.hero.heroView.running || this.hero.heroView.fly) && !this.isMaxLevel || this.isMaxLevel);
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

			var destination:b2Vec2 = new b2Vec2((this.hero.heroView.direction ? -1 : 1) * DISTANCE, 0);
			destination.MulM(this.hero.body.GetTransform().R);
			destination.Add(this.hero.position.Copy());
			this.hero.magicTeleportTo(destination);

			this.hero.heroView.showActiveAura();
			this.hero.heroView.showPerkAnimation(new PerkShamanFactory.perkData[PerkShamanFactory.getClassById(this.code)]['buttonClass'], 1000);

			this.active = false;
		}
	}
}