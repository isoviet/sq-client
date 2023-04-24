package game.mainGame.gameQuests
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.gameNet.GameMapNet;

	public class ObjectRain extends QuestObject
	{
		static private const MIN_TIME:int = 10;
		static private const MAX_TIME:int = 15;

		private var explode:MovieClip = null;
		private var time:Number = 0;

		public var count:int = 0;

		public function ObjectRain(hero:Hero):void
		{
			super(hero);

			this.view = new ObjectRainView();
			this.view.x = this.view.y = -30;
			addChild(this.view);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.hero || !this.hero.game || !this.hero.game.map)
				return;

			if (this.time <= 0)
			{
				this.time = MIN_TIME + Math.random() * (MAX_TIME - MIN_TIME);
				this.position = (this.hero.game.map as GameMapNet).getFreePosition(2, 2, 1)[0];
			}
			this.time -= timeStep;

			var pos:b2Vec2 = this.hero.position.Copy();
			pos.Subtract(this.position);

			if (pos.Length() >= 4)
				return;
			this.count++;
			this.time = 0;

			this.explode = new QuestItemExplode();
			this.explode.y = -20;
			this.explode.addEventListener(Event.CHANGE, onChange);
			this.hero.addView(this.explode, true);
		}

		private function onChange(e:Event):void
		{
			if (!this.explode)
				return;
			this.explode.removeEventListener(Event.CHANGE, onChange);
			this.explode = null;
			if (this.hero)
				this.hero.changeView();
		}
	}
}