package game.mainGame.gameSchool
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.Cast;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IShootBattle;
	import game.mainGame.entity.simple.GameBody;

	public class CastBattle extends Cast
	{
		static private const CAST_TIME:int = 25;

		private var timerReload:Timer = new Timer(300, 1);

		public function CastBattle(game:SquirrelGame):void
		{
			super(game);
			this.timer.delay = CAST_TIME;
			if (this.castHint.parentStarling)
				this.castHint.removeFromParent();
		}

		override protected function onCastComplete(e:TimerEvent = null):void
		{
			if (this.castObject is IShootBattle)
			{
				this.timerReload.delay = (this.castObject as IShootBattle).reloadTime;
				this.timerReload.reset();
				this.timerReload.start();
			}

			var itemClass:Class = EntityFactory.getEntity(EntityFactory.getId(this.castObject));
			super.onCastComplete(e);

			if (itemClass != null)
				this.castObject = new itemClass();
		}

		override protected function buildCasted():void
		{
			super.buildCasted();
			(this.castObject as GameBody).playerId = Game.selfId;
		}
	}
}