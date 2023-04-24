package clans
{
	import clans.PerkTotems;

	public class PerkTotemSpeed extends PerkTotems
	{
		public function PerkTotemSpeed(hero:Hero, bonus:int)
		{
			super(hero, bonus);
			this.totemId = TotemsData.SPEED;
		}
	}
}