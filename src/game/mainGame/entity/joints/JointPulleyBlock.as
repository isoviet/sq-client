package game.mainGame.entity.joints
{
	import game.mainGame.entity.IGameObject;

	import utils.starling.StarlingAdapterSprite;

	public class JointPulleyBlock extends JointPoint
	{
		public function JointPulleyBlock(parentObject:IGameObject):void
		{
			super(parentObject, new StarlingAdapterSprite(new PulleyBlock));
		}
	}
}