package game.mainGame.entity.simple
{
	import flash.events.Event;

	import game.gameData.CollectionsData;
	import screens.ScreenLearning;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	public class LearningCollectionElement extends Element
	{
		public function LearningCollectionElement():void
		{
			super(CollectionsData.getIconClass(0));

			this.view.play();
		}

		override protected function onHeroDetected(e:DetectHeroEvent):void
		{
			if (e.hero.id != Game.selfId)
				return;

			var soundIndex:int = Math.random() * SoundConstants.ACORN_SOUNDS.length;
			GameSounds.play(SoundConstants.ACORN_SOUNDS[soundIndex]);

			dispatchEvent(new Event(ScreenLearning.EVENT_COLLECT));
			destroy();
		}
	}
}