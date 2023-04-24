package game.mainGame.entity.joints
{
	import game.mainGame.entity.view.StickyView;

	public class JointHoney extends JointSticky
	{
		public function JointHoney()
		{
			super();

			this.jointView = new StickyView(HunnyEnd, HunnyMiddle);
		}
	}
}