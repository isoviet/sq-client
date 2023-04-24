package game.mainGame.entity.water
{
	import Box2D.Common.Math.b2Vec2;

	public class BubbleData
	{
		public var pos:b2Vec2 = new b2Vec2();
		public var vel:b2Vec2 = new b2Vec2();
		public var vel2:b2Vec2 = new b2Vec2();
		public var scale:Number = 10;

		public function BubbleData():void
		{}

		public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			this.pos.Add(vel);
			this.pos.Add(vel2);
			this.vel2.x = Math.random() > 0.9 ? -this.vel2.x : this.vel2.x;
		}
	}
}