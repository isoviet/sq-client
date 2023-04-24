package landing.game.mainGame.entity.joints
{
	import landing.game.mainGame.entity.IGameObject;

	public class JointAxis extends JointPoint
	{
		public function JointAxis(parentObject:IGameObject):void
		{
			super(parentObject);

			this.graphics.clear();
			this.graphics.lineStyle(2);
			this.graphics.lineTo(50, 0);
		}
	}
}