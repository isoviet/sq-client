package game.mainGame.gameQuests
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import com.greensock.TweenMax;

	public class ObjectImmortality extends QuestObject
	{
		static private const SPEED:Number = -50 / Game.PIXELS_TO_METRE;

		private var explode:MovieClip = null;
		private var distance:Number = 200;

		public function ObjectImmortality(hero:Hero):void
		{
			super(hero);

			this.view = new ObjectImmortalityView();
			addChild(this.view);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.visible || this.activated || !this.hero)
				return;

			var pos:b2Vec2 = this.hero.position.Copy();
			pos.Subtract(this.position);
			if (pos.Length() < 4)
			{
				this.visible = false;
				this.activated = true;

				this.explode = new QuestItemExplode();
				this.explode.y = -20;
				this.explode.addEventListener(Event.CHANGE, onChange);
				this.hero.addView(this.explode, true);
				return;
			}

			if (this.distance <= 0)
				return;
			var y:Number = this.position.y + SPEED * timeStep;
			this.distance += SPEED * timeStep;
			this.position = new b2Vec2(this.position.x, y);

			if (this.distance <= 0)
				TweenMax.to(this, 0.5, {'alpha': 0, 'onComplete': onFade});
		}

		private function onFade():void
		{
			this.visible = false;
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