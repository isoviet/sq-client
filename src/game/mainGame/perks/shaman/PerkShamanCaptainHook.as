package game.mainGame.perks.shaman
{
	import game.mainGame.entity.magic.HarpoonBodyCat;

	public class PerkShamanCaptainHook extends PerkShamanCast
	{
		static public const ROPE_SHRINK_FACTOR:Number = 40;

		public function PerkShamanCaptainHook(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_CAPTAIN_HOOK;
		}

		override protected function initCastObject():void
		{
			var hook:HarpoonBodyCat = new HarpoonBodyCat();
			hook.maxVelocity += hook.maxVelocity * countBonus() / 100;
			if (this.isMaxLevel)
				hook.ropeShrinkFactor *= (1 + ROPE_SHRINK_FACTOR / 100);

			this.castObject = hook;
		}
	}
}