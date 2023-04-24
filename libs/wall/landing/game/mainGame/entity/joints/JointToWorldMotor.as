package landing.game.mainGame.entity.joints
{
	public class JointToWorldMotor extends JointToWorld
	{
		public function JointToWorldMotor():void
		{
			super();

			this.motorEnabled = true;
			this.motorTorque = 100000000;
			this.motorSpeed = -1;
		}
	}
}