package game.mainGame.gameQuests
{
	import Box2D.Common.Math.b2Vec2;

	import com.greensock.TweenMax;

	public class ObjectFear extends QuestObject
	{
		static private const DISTANCE:Number = 300 / Game.PIXELS_TO_METRE;
		static private const SPEED:Number = 100 / Game.PIXELS_TO_METRE;

		private var point:b2Vec2 = null;
		private var endMove:Boolean = true;

		public function ObjectFear(hero:Hero):void
		{
			super(hero);

			this.view = new ObjectFearView();
			this.view.x = -15;
			this.view.y = -17;
			addChild(this.view);

			this.activated = true;
			this.alpha = 0;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.activated || !this.hero || this.hero.isDead || this.hero.inHollow)
				return;

			if (this.endMove)
			{
				this.endMove = false;

				var pos:b2Vec2 = this.hero.position.Copy();
				var rAngle:Number = Math.random() * 360;
				pos.Add(new b2Vec2(Math.cos(rAngle) * DISTANCE, Math.sin(rAngle) * DISTANCE));

				if (this.view)
					this.view.scaleX = Math.cos(rAngle) > 0 ? 1 : -1;
				this.position = pos;
				TweenMax.to(this, 0.5, {'alpha': 1, 'onComplete': onFadeOut});
			}
			else if (this.point != null)
			{
				pos = this.point.Copy();
				pos.Subtract(this.position);

				var distance:Number = pos.Length();
				if (distance <= SPEED * timeStep)
				{
					this.point = null;
					TweenMax.to(this, 0.5, {'alpha': 0, 'onComplete': onFadeIn});
				}
				var speed:Number = Math.min(SPEED * timeStep, distance);
				var x:Number = this.position.x + speed * pos.x / distance;
				var y:Number = this.position.y + speed * pos.y / distance;
				this.position = new b2Vec2(x, y);

				if (this.view)
					this.view.scaleX = pos.x > 0 ? -1 : 1;
			}

			pos = this.hero.position.Copy();
			pos.Subtract(this.position);

			if (pos.Length() >= 3)
				return;
			this.visible = false;
			this.activated = false;
		}

		private function onFadeIn():void
		{
			this.endMove = true;
		}

		private function onFadeOut():void
		{
			if (!this.hero || !this.hero.position)
				return;
			this.point = new b2Vec2(this.hero.position.x * 2 - this.position.x, this.hero.position.y * 2 - this.position.y);
		}
	}
}