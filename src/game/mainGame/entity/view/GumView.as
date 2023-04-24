package game.mainGame.entity.view
{
	public class GumView extends JointBaseView
	{
		public function GumView():void
		{
			super(new GumStart(), new GumEnd(), new GumMiddle(), 90.50);
		}
	}
}