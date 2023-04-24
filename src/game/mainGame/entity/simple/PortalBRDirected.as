package game.mainGame.entity.simple
{
	public class PortalBRDirected extends PortalBR
	{
		public function PortalBRDirected():void
		{
			super(new PortalArrowBlue());
			super.useDirection = true;
		}
	}
}