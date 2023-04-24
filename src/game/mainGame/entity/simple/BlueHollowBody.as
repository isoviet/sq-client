package game.mainGame.entity.simple
{
	import flash.display.DisplayObject;

	import sensors.events.DetectHeroEvent;

	public class BlueHollowBody extends HollowBody
	{
		public function BlueHollowBody():void
		{
			super();
			this.type = Hero.TEAM_BLUE;
		}

		override protected function get hollowIcon():DisplayObject
		{
			return new HollowBlue();
		}

		override protected function onHeroDetected(e:DetectHeroEvent):void
		{
			if (e.hero.team != this.type && e.hero.team != Hero.TEAM_NONE)
				return;

			super.onHeroDetected(e);
		}
	}
}