package game.mainGame.entity.joints
{
	import game.mainGame.entity.IMotor;

	public class JointToWorldMotor extends JointRevolute implements IMotor
	{
		public function JointToWorldMotor():void
		{
			super();

			this.toWorld = true;
			this.motorEnabled = true;
			this.motorTorque = 100000000;
			this.motorSpeed = -1;
		}
	}
}