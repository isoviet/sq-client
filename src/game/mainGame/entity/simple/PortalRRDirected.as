package game.mainGame.entity.simple
{
	public class PortalRRDirected extends PortalRR
	{
		public function PortalRRDirected():void
		{
			super(new PortalArrowRed());
			super.useDirection = true;
		}
	}
}