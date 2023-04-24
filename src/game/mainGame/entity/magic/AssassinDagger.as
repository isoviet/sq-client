package game.mainGame.entity.magic
{
	import game.mainGame.entity.simple.Missile;

	public class AssassinDagger extends Missile
	{
		public function AssassinDagger():void
		{
			super();
		}

		override protected function init():void
		{
			originBranchView = new AssassinDaggerView();

			super.init();
		}
	}
}