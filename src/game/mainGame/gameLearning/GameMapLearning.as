package game.mainGame.gameLearning
{
	import flash.display.DisplayObject;

	import game.mainGame.GameMap;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import screens.ScreenLearning;

	import utils.InstanceCounter;
	import utils.starling.IStarlingAdapter;

	public class GameMapLearning extends GameMap
	{
		public function GameMapLearning(game:SquirrelGame):void
		{
			super(game);
		}

		override protected function onHollow(e:HollowEvent):void
		{
			super.onHollow(e);

//			e.player.inHollow = true;

			if (e.player.id == Game.selfId)
				ScreenLearning.onComplete();
		}

		override public function add(object:* = null):void
		{
			InstanceCounter.onCreate(object);
			super.objects.push(object);

			if (object is DisplayObject && object.parent == null)
				addChild(object);

			if (object is IStarlingAdapter && object.parentStarling == null)
				addChildStarling(object);

			if (object is IComplexEditorObject)
				(object as IComplexEditorObject).onAddedToMap(this);
		}

		override protected function onRespawnPoint(e:SquirrelEvent):void
		{
			super.onRespawnPoint(e);

			TrainingCounter.next();
		}
	}
}