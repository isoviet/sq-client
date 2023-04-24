package game.mainGame.entity.simple
{
	public class PortalRBDirected extends PortalRB
	{
		public function PortalRBDirected():void
		{
			super(new PortalArrowRed());
			super.useDirection = true;
		}
	}
}