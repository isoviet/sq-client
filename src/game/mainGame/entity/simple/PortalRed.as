package game.mainGame.entity.simple
{
	import flash.display.DisplayObjectContainer;

	import Box2D.Dynamics.b2World;

	public class PortalRed extends Portal
	{
		public function PortalRed(arrow: DisplayObjectContainer = null):void
		{
			super(new PortalA, arrow);
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			world.userData.map.portals.portalB = this.sensor;
		}

		override public function dispose():void
		{
			super.dispose();
			if (this.game)
				this.game.map.portals.portalB = null;
		}
	}
}