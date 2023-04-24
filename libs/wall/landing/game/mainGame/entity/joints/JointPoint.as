package landing.game.mainGame.entity.joints
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.GameMap;
	import landing.game.mainGame.IDispose;
	import landing.game.mainGame.IUpdate;
	import landing.game.mainGame.entity.IComplexEditorObject;
	import landing.game.mainGame.entity.IGameObject;
	import landing.game.mainGame.gameEditor.Selection;

	public class JointPoint extends Sprite implements IGameObject, IDispose, IComplexEditorObject
	{
		private var removed:Boolean = false;

		protected var view:DisplayObject = new PinLimited();

		public var parentObject:IGameObject = null;

		public var doUpdate:Boolean = true;

		public function JointPoint(parentObject:IGameObject, view:DisplayObject = null):void
		{
			this.parentObject = parentObject;
			if (view != null)
				this.view = view;
			addChild(this.view);
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / WallShadow.PIXELS_TO_METRE, this.y / WallShadow.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * WallShadow.PIXELS_TO_METRE;
			this.y = value.y * WallShadow.PIXELS_TO_METRE;
		}

		override public function get y():Number
		{
			return super.y;
		}

		override public function set y(value:Number):void
		{
			super.y = value;

			if (this.parentObject is IUpdate && doUpdate)
				(this.parentObject as IUpdate).update();
		}

		override public function get x():Number
		{
			return super.x;
		}

		override public function set x(value:Number):void
		{
			super.x = value;

			if (this.parentObject is IUpdate && doUpdate)
				(this.parentObject as IUpdate).update();
		}

		public function get angle():Number
		{
			return this.rotation * (Math.PI / 180);
		}

		public function set angle(value:Number):void
		{
			this.rotation = value / (Math.PI / 180);
		}

		public function build(world:b2World):void
		{}

		public function dispose():void
		{
			if (this.parent == null)
				return;
			this.parent.removeChild(this);
		}

		public function onAddedToMap(map:GameMap):void
		{}

		public function onRemovedFromMap(map:GameMap):void
		{
			if (this.removed)
				return;
			this.removed = true;

			map.remove(this.parentObject);
		}

		public function onSelect(selection:Selection):void
		{}
	}
}