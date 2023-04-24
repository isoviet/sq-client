package game.mainGame.entity.simple
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.joints.JointPoint;

	import utils.starling.StarlingAdapterSprite;

	public class HolePoint extends JointPoint
	{
		static private const TRIGGER_OFFSET:Number = 2;
		private var hole:HoleView = new HoleView();

		public function HolePoint(parent:IGameObject):void
		{
			super(parent, new StarlingAdapterSprite(this.hole));
		}

		public function get arrow(): StarlingAdapterSprite
		{
			var tmp: StarlingAdapterSprite;
			if (this.hole.arrow) {
				return new StarlingAdapterSprite(this.hole.arrow);
			} else {
				tmp = new StarlingAdapterSprite();
				return tmp;
			}
		}

		public function get direction():b2Vec2
		{
			return new b2Vec2(-Math.cos(this.angle), -Math.sin(this.angle));
		}

		public function get triggerPosition():b2Vec2
		{
			var result:b2Vec2 = this.direction;
			result.Multiply(TRIGGER_OFFSET);
			result.Add(this.position);
			return result;
		}
	}
}