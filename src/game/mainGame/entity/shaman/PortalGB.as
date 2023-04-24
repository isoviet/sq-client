package game.mainGame.entity.shaman
{
	import Box2D.Dynamics.b2World;

	import game.mainGame.gameTwoShamansNet.GameMapTwoShamansNet;

	public class PortalGB extends LifetimePortal
	{
		public function PortalGB():void
		{
			super(new PortalGreen(), new PortalArrowBlue(), new PortalBluePlumage());
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			(world.userData.map as GameMapTwoShamansNet).blueShamanPortals.portalC = this.sensor;
		}

		override public function dispose():void
		{
			super.dispose();
			if (this.game)
				(this.game.map as GameMapTwoShamansNet).blueShamanPortals.portalC = null;
		}
	}
}