package clans
{
	import clans.PerkTotems;

	public class PerkTotemHighJump extends PerkTotems
	{
		public function PerkTotemHighJump(hero:Hero, bonus:int)
		{
			super(hero, bonus);
			this.totemId = TotemsData.HIGH_JUMP;
		}
	}
}