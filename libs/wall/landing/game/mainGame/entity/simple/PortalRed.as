package landing.game.mainGame.entity.simple
{
	import flash.display.DisplayObject;

	import Box2D.Dynamics.b2World;

	public class PortalRed extends Portal
	{
		public function PortalRed():void
		{
			var view:DisplayObject = new PortalA();
			view.x = -20;
			view.y = -20;
			addChild(view);
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