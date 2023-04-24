package game.mainGame.entity.shaman
{
	import Box2D.Dynamics.b2World;

	import game.mainGame.gameTwoShamansNet.GameMapTwoShamansNet;

	public class PortalGR extends LifetimePortal
	{
		public function PortalGR():void
		{
			super(new PortalGreen(), new PortalArrowBlue(), new PortalRedPlumage());
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			(world.userData.map as GameMapTwoShamansNet).redShamanPortals.portalC = this.sensor;
		}

		override public function dispose():void
		{
			super.dispose();
			if (this.game)
				(this.game.map as GameMapTwoShamansNet).redShamanPortals.portalC = null;
		}
	}
}