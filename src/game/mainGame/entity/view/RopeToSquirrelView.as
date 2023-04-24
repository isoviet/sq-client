package game.mainGame.entity.view
{
	public class RopeToSquirrelView extends JointBaseView
	{
		public function RopeToSquirrelView():void
		{
			super(new RopeToSquirrelStart(), new RopeToSquirrelEnd(), new RopeToSquirrelMiddle(), 69.9);
		}
	}
}