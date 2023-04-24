package game.mainGame.entity.simple
{
	public class PortalBBDirected extends PortalBB
	{
		public function PortalBBDirected():void
		{
			super(new PortalArrowBlue());
			super.useDirection = true;
		}
	}
}