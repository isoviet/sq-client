package landing.game.mainGame.entity.joints
{
	public class JointToBodyMotor extends JointToBody
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