package game.mainGame.entity.joints
{
	public class JointToBodyFixed extends JointToBody
	{
		public function JointToBodyFixed():void
		{
			super();

			this.limited = true;
		}
	}
}