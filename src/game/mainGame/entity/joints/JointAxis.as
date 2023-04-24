package game.mainGame.entity.joints
{
	import flash.display.Shape;

	import game.mainGame.entity.IGameObject;

	import utils.starling.StarlingAdapterSprite;

	public class JointAxis extends JointPoint
	{
		public function JointAxis(parentObject:IGameObject):void
		{
			super(parentObject);
			var graph: Shape = new Shape();

			graph.graphics.clear();
			graph.graphics.lineStyle(2);
			graph.graphics.lineTo(50, 0);

			addChildStarling(new StarlingAdapterSprite(graph));
		}
	}
}