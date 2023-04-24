package game.mainGame.entity.simple
{
	import flash.display.DisplayObjectContainer;

	import Box2D.Dynamics.b2World;

	import game.mainGame.gameTwoShamansNet.GameMapTwoShamansNet;

	public class PortalBB extends Portal
	{
		public function PortalBB(arrow: DisplayObjectContainer = null):void
		{
			super(new PortalB(), arrow, new PortalBluePlumage());
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			(world.userData.map as GameMapTwoShamansNet).blueShamanPortals.portalA = this.sensor;
		}

		override public function dispose():void
		{
			super.dispose();
			if (this.game)
				(this.game.map as GameMapTwoShamansNet).blueShamanPortals.portalA = null;
		}
	}
}