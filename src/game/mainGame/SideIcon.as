package game.mainGame
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import interfaces.IDispose;

	import utils.GeomUtil;
	import utils.starling.StarlingAdapterSprite;

	public class SideIcon extends StarlingAdapterSprite implements IUpdate, IDispose
	{
		private var object:ISideObject;
		private var controller:SideIconsController;
		private var icon:StarlingAdapterSprite;

		public function SideIcon(object:ISideObject, controller:SideIconsController):void
		{
			super();
			this.object = object;
			this.controller = controller;

			this.icon = object.sideIcon;
			addChildStarling(this.icon);

			update();
		}

		public function update(timeStep:Number = 0):void
		{
			if (!this.object && this.object.showIcon)
				return;

			var showIcon:Boolean = this.object.showIcon;

			if (!showIcon && !this.visible)
				return;

			var rect: Rectangle = StarlingAdapterSprite(this.object).boundsStarling();
			rect.x += this.controller.gameMap.x;
			rect.y += this.controller.gameMap.y;

			this.visible = showIcon && !rect.intersects(this.controller.rectangle);

			if (!this.visible)
				return;

			this.x = rect.x + rect.width / 2;
			this.y = rect.y + rect.height / 2;

			this.x = Math.max(Math.min(this.x, this.controller.rectangle.width), this.controller.rectangle.x);
			this.y = Math.max(Math.min(this.y, this.controller.rectangle.height), this.controller.rectangle.y);
			this.icon.rotation =  GeomUtil.getAngle(new Point(this.x, this.y), new Point(rect.x + rect.width / 2, rect.y + rect.height / 2));
		}

		public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			this.removeFromParent();

			this.object = null;
			this.controller = null;
		}
	}
}