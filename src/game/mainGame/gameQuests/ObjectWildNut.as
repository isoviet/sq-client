package game.mainGame.gameQuests
{
	import Box2D.Common.Math.b2Vec2;

	public class ObjectWildNut extends QuestObject
	{
		public function ObjectWildNut(hero:Hero):void
		{
			super(hero);

			this.view = new ObjectNutView();
			this.view.x = -15;
			this.view.y = -20;
			addChild(this.view);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.activated)
				return;

			var pos:b2Vec2 = this.hero.position.Copy();
			pos.Subtract(this.position);

			if (pos.Length() >= 4)
				return;
			this.activated = true;
			removeChild(this.view);

			this.view = new ObjectNutActiveView();
			this.view.x = -15;
			this.view.y = -20;
			addChild(this.view);
		}
	}
}