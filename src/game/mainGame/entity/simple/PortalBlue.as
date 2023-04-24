package game.mainGame.entity.simple
{
	import flash.display.DisplayObjectContainer;

	import Box2D.Dynamics.b2World;

	public class PortalBlue extends Portal
	{
		public function PortalBlue(arrow: DisplayObjectContainer = null):void
		{
			super(new PortalB(), arrow);
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			world.userData.map.portals.portalA = this.sensor;
		}

		override public function dispose():void
		{
			super.dispose();
			if (this.game)
				this.game.map.portals.portalA = null;
		}
	}
}