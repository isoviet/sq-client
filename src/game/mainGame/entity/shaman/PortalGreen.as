package game.mainGame.entity.shaman
{
	import Box2D.Dynamics.b2World;

	public class PortalGreen extends LifetimePortal
	{
		public function PortalGreen():void
		{
			super(new PortalGreenImg, new PortalArrowBlue);
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			world.userData.map.portals.portalC = this.sensor;
		}

		override public function dispose():void
		{
			super.dispose();
			if (this.game)
				this.game.map.portals.portalC = null;
		}
	}
}