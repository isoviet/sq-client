package game.mainGame.gameLearning
{
	import controllers.ControllerHeroLocal;
	import controllers.ControllerHeroRemote;
	import game.mainGame.SquirrelCollection;
	import game.mainGame.SquirrelGame;

	public class SquirrelCollectionLearning extends SquirrelCollection
	{
		public function SquirrelCollectionLearning():void
		{
			super();

			this.heroClass = HeroLearning;
		}

		override public function add(id:int):void
		{
			if (id in super.players)
				return;

			Logger.add("SquirrelCollection.add: " + id);
			this.players[id] = new this.heroClass(id, SquirrelGame.instance.world, 0, 0);
			addChild(this.players[id]);
			addChildStarling(this.players[id]);

			if (Game.selfId in this.players)
			{
				addChild(this.players[Game.selfId]);
				addChildStarling(this.players[Game.selfId]);
			}

			setController(id);
		}

		override protected function setController(id:int):void
		{
			if (id == Game.selfId)
				new ControllerHeroLocal(this.players[id], true);
			else
				new ControllerHeroRemote(this.players[id], id);
		}
	}
}