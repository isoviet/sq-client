package landing.game.mainGame.entity.simple
{
	import flash.display.DisplayObject;

	import Box2D.Dynamics.b2World;

	public class PortalBlue extends Portal
	{
		public function PortalBlue():void
		{
			var view:DisplayObject = new PortalB();
			view.x = -20;
			view.y = -20;
			addChild(view);
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