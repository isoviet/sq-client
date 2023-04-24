package landing.game.mainGame.gameLending
{
	import events.MovieClipPlayCompleteEvent;
	import landing.game.mainGame.SquirrelCollection;
	import landing.game.mainGame.SquirrelGame;

	public class SquirrelCollectionLending extends SquirrelCollection
	{
		public function SquirrelCollectionLending(game:SquirrelGame):void
		{
			super(game);
		}

		override public function add(id:int):void
		{
			this.players[id] = new wHero(id, this.game.world, 0, 0, false, false);
			this.players[id].addEventListener(MovieClipPlayCompleteEvent.DEATH, onSelfLearningDie, false, 0, true);
			addChildAt(this.players[id], 0);

			setController(id);
		}

		private function onSelfLearningDie(e:MovieClipPlayCompleteEvent):void
		{
			var self:wHero = this.players[WallShadow.SELF_ID];
			if (self == null)
				return;

			remove(WallShadow.SELF_ID);

			dispatchEvent(new MovieClipPlayCompleteEvent(MovieClipPlayCompleteEvent.DEATH));
		}
	}
}