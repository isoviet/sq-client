package game.mainGame.entity.joints
{
	import game.mainGame.ISaveInvert;

	public class JointToWorld extends JointRevolute implements ISaveInvert
	{
		public function JointToWorld():void
		{
			super();

			this.toWorld = true;
		}
	}
}