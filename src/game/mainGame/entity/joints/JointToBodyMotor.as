package game.mainGame.entity.joints
{
	import game.mainGame.entity.IMotor;

	public class JointToBodyMotor extends JointToBody implements IMotor
	{
		public function JointToBodyMotor():void
		{
			super();

			this.motorEnabled = true;
			this.motorSpeed = -1;
			this.motorTorque = 100000000;
		}
	}
}