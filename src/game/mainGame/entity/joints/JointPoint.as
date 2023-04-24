package game.mainGame.entity.joints
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.GameMap;
	import game.mainGame.IUpdate;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.gameEditor.Selection;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class JointPoint extends StarlingAdapterSprite implements IGameObject, IDispose, IComplexEditorObject
	{
		private var removed:Boolean = false;

		protected var view:StarlingAdapterSprite = new StarlingAdapterSprite(new PinLimited());

		public var parentObject:IGameObject = null;

		public var doUpdate:Boolean = true;

		public function JointPoint(parentObject:IGameObject, view:StarlingAdapterSprite = null):void
		{
			this.parentObject = parentObject;
			if (view != null)
			{
				this.view.removeFromParent();
				this.view = view;
			}
			this.view.alignPivot();
			addChildStarling(this.view);
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
			return this.rotation * (Game.D2R);
		}

		public function set angle(value:Number):void
		{
			this.rotation = value / (Game.D2R);
		}

		public function build(world:b2World):void
		{}

		public function dispose():void {
			view.removeFromParent();
			while(this.numChildren > 0)
				this.removeChildStarlingAt(0);

			this.removeFromParent();
		}

		public function onAddedToMap(map:GameMap):void {
		}

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