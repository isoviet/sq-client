package game.mainGame.entity.simple
{
	public class PortalBlueDirected extends PortalBlue
	{
		public function PortalBlueDirected():void
		{
			super(new PortalArrowBlue());
			super.useDirection = true;
		}
	}
}