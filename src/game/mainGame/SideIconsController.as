package game.mainGame
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

    public class SideIconsController extends StarlingAdapterSprite implements IUpdate, IDispose
	{
		private var icons:Dictionary = new Dictionary(true);

		public var rectangle:Rectangle = new Rectangle(0, 40, Config.GAME_WIDTH, Config.GAME_HEIGHT - 40);
		private var _map: GameMap;

		public function SideIconsController(map: GameMap, rectangle:Rectangle = null):void
		{
			_map = map;
			this.rectangle = rectangle ? rectangle : this.rectangle;
			EnterFrameManager.addListener(update);
		}

		public function get gameMap(): GameMap
		{
			return _map;
		}

		public function register(object:ISideObject):void
		{
			this.icons[object] = new SideIcon(object, this);
			addChildStarling(this.icons[object]);

			if (!(object is Hero && (object as Hero).id == Game.selfId))
				this.addChildStarling(this.icons[object]);
		}

		public function remove(object:ISideObject):void
		{
			if (!(object in this.icons) || !containsStarling(this.icons[object]))
				return;

			removeChildStarling(this.icons[object]);
			this.icons[object].dispose();
			delete this.icons[object];
		}

		public function update(timeStep:Number = 0):void
		{
			for each (var icon:SideIcon in this.icons)
				icon.update(timeStep);
		}

		public function dispose():void
		{
			clear();
			EnterFrameManager.removeListener(update);
		}

		private function clear():void
		{
			for each (var icon:SideIcon in this.icons)
				icon.dispose();
			this.icons = new Dictionary(true);
		}
	}
}