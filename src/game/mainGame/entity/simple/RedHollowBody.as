package game.mainGame.entity.simple
{
	import flash.display.DisplayObject;

	import sensors.events.DetectHeroEvent;

	public class RedHollowBody extends HollowBody
	{
		public function RedHollowBody():void
		{
			super();
			this.type = Hero.TEAM_RED;
		}

		override protected function get hollowIcon():DisplayObject
		{
			return new HollowRed();
		}

		override protected function onHeroDetected(e:DetectHeroEvent):void
		{
			if (e.hero.team != this.type && e.hero.team != Hero.TEAM_NONE)
				return;

			super.onHeroDetected(e);
		}
	}
}