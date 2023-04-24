package game.mainGame.entity.simple
{
	public class PortalRedDirected extends PortalRed
	{
		public function PortalRedDirected():void
		{
			super(new PortalArrowRed());
			super.useDirection = true;
		}
	}
}