package game.mainGame.entity.joints
{
	import game.mainGame.entity.IMotor;

	public class JointToWorldMotorCCW extends JointRevolute implements IMotor
	{
		public function JointToWorldMotorCCW():void
		{
			super();

			this.toWorld = true;
			this.motorEnabled = true;
			this.motorTorque = 100000000;
			this.motorSpeed = 1;
		}
	}
}