package game.mainGame.gameSchool
{
	import game.mainGame.SquirrelCollection;
	import game.mainGame.gameBattleNet.HeroBattle;
	import game.mainGame.gameSchool.SquirrelGameSchool;

	public class SquirrelGameSchoolBattle extends SquirrelGameSchool
	{
		public function SquirrelGameSchoolBattle():void
		{
			super();
		}

		override protected function init():void
		{
			this.cast = new CastBattle(this);
			this.map = new GameMapSchool(this);
			this.squirrels = new SquirrelCollection();
			this.squirrels.heroClass = HeroBattle;
		}
	}
}