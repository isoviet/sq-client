package game.mainGame.entity.joints
{
	import game.mainGame.ISaveInvert;

	public class JointToWorldFixed extends JointToWorld implements ISaveInvert
	{
		public function JointToWorldFixed():void
		{
			super();

			this.limited = true;
		}
	}
}