package game.mainGame.entity.cast
{
	import flash.filters.GlowFilter;
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.GameMap;
	import game.mainGame.ISerialize;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.simple.Trap;
	import screens.ScreenStarling;
	import sounds.GameSounds;

	import interfaces.IDispose;

	import starling.events.Touch;
	import starling.events.TouchEvent;

	import utils.IndexUtil;
	import utils.starling.StarlingAdapterSprite;

	public class Hammer extends StarlingAdapterSprite implements IGameObject, ICastTool, IDispose, ISerialize
	{
		private const DESTROY_FILTER:Array = [new GlowFilter(0x00CC00, 1, 5, 5, 50, 1, true, true)];
		private var _destroyObject:Trap = null;
		private var _game:game.mainGame.SquirrelGame;

		public function Hammer():void
		{
			addChildStarling(new StarlingAdapterSprite(new HammerView));
			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onMoveMouse);
		}

		private function onMoveMouse(e: TouchEvent= null):void
		{
			var touch:Touch = e.getTouch(ScreenStarling.instance);

			if (!touch || !this._game || !this._game.map)
				return;

			var localPos:Point = touch.getLocation(ScreenStarling.instance);
			var traps:Array = this._game.map.get(Trap);

			if (traps.length == 0)
				return;

			var array:Array = [];

			if (Hero.self)
				for each (var trap:Trap in traps)
				{
					var point:Point = trap.globalToLocal(localPos);
					if (trap.hitTestPointStarling(point) && !trap.empty)
						array.push(trap);
				}

			this.destroyObject = (IndexUtil.getMaxIndex(array) as Trap);
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{}

		public function build(world:b2World):void
		{
			var map:GameMap = (world.userData as SquirrelGame).map;

			if (this.destroyObject)
				this.destroyObject.commandReleaseHero();

			this.visible = false;
			map.remove(this);

			dispose();
		}

		public function set game(value:SquirrelGame):void
		{
			this._game = value;
		}

		public function onCastStart():void
		{
			GameSounds.play("craft");
		}

		public function onCastCancel():void
		{}

		public function onCastComplete():void
		{}

		public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			this.destroyObject = null;
			this.game = null;

			if (this.parentStarling != null)
				this.parentStarling.removeChildStarling(this);

			this.removeFromParent();
			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onMoveMouse);
		}

		public function serialize():*
		{
			var result:Array = [[this.position.x, this.position.y], this.destroyObject.id];
			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.destroyObject = _game.map.getObject(data[1]) as Trap;
		}

		public function get destroyObject():Trap
		{
			return this._destroyObject;
		}

		public function set destroyObject(value:Trap):void
		{
			if (this._destroyObject == value)
				return;

			if (this._destroyObject)
				this._destroyObject.filters = [];

			if (value)
				value.filters = DESTROY_FILTER;

			this._destroyObject = value;
		}
	}
}