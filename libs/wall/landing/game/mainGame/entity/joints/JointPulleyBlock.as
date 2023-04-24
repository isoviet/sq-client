package landing.game.mainGame.entity.joints
{
	import landing.game.mainGame.entity.IGameObject;

	public class JointPulleyBlock extends JointPoint
	{
		public function JointPulleyBlock(parentObject:IGameObject):void
		{
			super(parentObject, new PulleyBlock);
		}
	}
}