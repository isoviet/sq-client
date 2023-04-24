package game.mainGame.entity.joints
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import game.mainGame.GameMap;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IUnselectable;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.view.RopeView;
	import game.mainGame.gameEditor.Selection;

	import interfaces.IDispose;

	import utils.IndexUtil;
	import utils.starling.StarlingAdapterSprite;

	public class JointDistance extends StarlingAdapterSprite implements IJoint, IComplexEditorObject, IGameObject, ISerialize, IDispose, IUpdate, IUnselectable
	{
		private var body0:GameBody = null;
		private var body1:GameBody = null;
		private var queryBodyResult:Array = null;

		private var jointDef:b2DistanceJointDef = null;
		private var body0Id:int = -1;
		private var body1Id:int = -1;

		private var joint:b2Joint = null;

		private var world:b2World = null;
		private var view:StarlingAdapterSprite = new StarlingAdapterSprite(new RopeJointView());
		private var spring:RopeView = new RopeView();
		public var damping:Number = 0;
		public var frequency:Number = 1;

		public var anchor0:JointPoint = null;
		public var anchor1:JointPoint = null;

		public var pin0:StarlingAdapterSprite = null;
		public var pin1:StarlingAdapterSprite = null;

		public function JointDistance():void
		{
			addChildStarling(view);
			createJoint();
		}

		private function createJoint(): void {
			pin0 = new StarlingAdapterSprite(new PinUnlimited);
			pin1 = new StarlingAdapterSprite(new PinUnlimited);
			pin0.alignPivot();
			pin1.alignPivot();
			this.anchor0 = new JointPoint(this, new StarlingAdapterSprite(new PinUnlimited));
			this.anchor1 = new JointPoint(this, new StarlingAdapterSprite(new PinUnlimited));
		}

		override public function hitTestObject(obj:DisplayObject):Boolean
		{
			var selectionA:Point = new Point(obj.getRect(this.parentStarling).x, obj.getRect(this.parentStarling).y);
			var selectionB:Point = new Point(obj.getRect(this.parentStarling).x, obj.getRect(this.parentStarling).y + obj.height);
			var selectionC:Point = new Point(obj.getRect(this.parentStarling).x + obj.width, obj.getRect(this.parentStarling).y);
			var selectionD:Point = new Point(obj.getRect(this.parentStarling).x +obj.width, obj.getRect(this.parentStarling).y + obj.height);

			if(this.hitTestPoint(selectionA.x, selectionA.y, true) || (anchor0.x > selectionA.x && anchor0.x < selectionC.x && anchor0.y > selectionA.y && anchor0.y < selectionB.y))
				return true;
			else
			{
				return (Intersection(this.anchor0.x, this.anchor0.y, this.anchor1.x, this.anchor1.y, selectionA.x, selectionA.y, selectionB.x, selectionB.y) ||
				Intersection(this.anchor0.x, this.anchor0.y, this.anchor1.x, this.anchor1.y, selectionA.x, selectionA.y, selectionC.x, selectionC.y) ||
				Intersection(this.anchor0.x, this.anchor0.y, this.anchor1.x, this.anchor1.y, selectionC.x, selectionC.y, selectionD.x, selectionD.y) ||
				Intersection(this.anchor0.x, this.anchor0.y, this.anchor1.x, this.anchor1.y, selectionB.x, selectionB.y, selectionD.x, selectionD.y));
			}
		}

		public function onAddedToMap(map:GameMap):void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0, false);

			addChildStarling(this.spring);
			addChildStarling(pin0);
			addChildStarling(pin1);
			map.add(this.anchor0);
			map.add(this.anchor1);

			if (this.anchor0.position.x != 0 || this.anchor0.position.y != 0)
				return;

			var pos:b2Vec2 = this.position.Copy();
			pos.Add(new b2Vec2(-31.5 / Game.PIXELS_TO_METRE, 0));
			this.anchor0.position = pos;

			pos.Add(new b2Vec2(63 / Game.PIXELS_TO_METRE, 0));
			this.anchor1.position = pos;

			update();
		}

		public function onRemovedFromMap(map:GameMap): void {
			map.remove(this.anchor0);
			map.remove(this.anchor1);
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

		override public function get rotation():Number
		{
			return 0;
		}

		override public function set rotation(value:Number):void
		{
			if (value) {/*unused*/}
			super.rotation = 0;
		}

		public function build(world:b2World):void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0, false);

			addChildStarling(this.spring);
			addChildStarling(pin0);
			addChildStarling(pin1);
			update();

			this.world = world;

			if (this.jointDef == null)
			{
				if (this.body0 == null)
					findBody0(world, this.anchor0.position);
				if (this.body1 == null)
					findBody1(world, this.anchor1.position);
			}
			else
			{
				this.body0 = ((world.userData as SquirrelGame).map.getObject(this.body0Id) as GameBody);
				this.body1 = ((world.userData as SquirrelGame).map.getObject(this.body1Id) as GameBody);
			}

			if (this.body0 == null && this.body1 == null)
				return;

			var bBody0:b2Body = this.body0 ? this.body0.body : world.GetGroundBody();
			var bBody1:b2Body = this.body1 ? this.body1.body : world.GetGroundBody();

			if (this.jointDef != null)
			{
				this.jointDef.bodyA = bBody0;
				this.jointDef.bodyB = bBody1;
			}
			else
			{
				this.jointDef = new b2DistanceJointDef();
				this.jointDef.Initialize(bBody0, bBody1, this.anchor0.position, this.anchor1.position);
			}

			this.jointDef.dampingRatio = this.damping;
			this.jointDef.frequencyHz = this.frequency;
			this.jointDef.collideConnected = true;

			this.joint = world.CreateJoint(this.jointDef);

			this.anchor0.position = this.jointDef.localAnchorA;
			this.anchor1.position = this.jointDef.localAnchorB;

			if (this.body0 != null)
				this.body0.addChildStarling(this.anchor0);

			if (this.body1 != null)
				this.body1.addChildStarling(this.anchor1);
		}

		public function serialize():*
		{
			var result:Array = [];

			result.push([this.position.x, this.position.y]);
			result.push([this.anchor0.position.x, this.anchor0.position.y]);
			result.push([this.anchor1.position.x, this.anchor1.position.y]);
			result.push([this.frequency, this.damping]);

			if (this.jointDef != null)
				result.push([this.body0 ? this.body0.id : -1, this.body1 ? this.body1.id : -1, [this.jointDef.localAnchorA.x, this.jointDef.localAnchorA.y], [this.jointDef.localAnchorB.x, this.jointDef.localAnchorB.y], this.jointDef.length]);
			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.anchor0.position = new b2Vec2(data[1][0], data[1][1]);
			this.anchor1.position = new b2Vec2(data[2][0], data[2][1]);
			this.frequency = data[3][0];
			this.damping = data[3][1];

			if (!(4 in data))
				return;

			this.jointDef = new b2DistanceJointDef();
			this.body0Id = data[4][0];
			this.body1Id = data[4][1];
			this.jointDef.localAnchorA = new b2Vec2(data[4][2][0], data[4][2][1]);
			this.jointDef.localAnchorB = new b2Vec2(data[4][3][0], data[4][3][1]);

			if (4 in data[4])
				this.jointDef.length = data[4][4];
		}

		public function dispose():void {
			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			this.removeFromParent();

			if (this.anchor0 != null)
				this.anchor0.dispose();

			this.anchor0 = null;

			if (this.anchor1 != null)
				this.anchor1.dispose();

			this.anchor1 = null;

			if (this.joint != null)
				this.world.DestroyJoint(this.joint);
			this.joint = null;
		}

		public function update(timeStep:Number = 0):void
		{
			this.rotation = 0;
			var start:b2Vec2 = this.joint ? this.joint.GetAnchorA(): this.anchor0.position;
			start.Multiply(Game.PIXELS_TO_METRE);

			var end:b2Vec2 = this.joint ? this.joint.GetAnchorB(): this.anchor1.position;
			end.Multiply(Game.PIXELS_TO_METRE);

			var center:b2Vec2 = new b2Vec2((start.x + end.x) / 2, (start.y + end.y) / 2);
			this.x = center.x;
			this.y = center.y;

			start.Subtract(center);
			end.Subtract(center);

			this.spring.start = new Point(start.x, start.y);
			this.spring.end = new Point(end.x, end.y);
			pin0.x = start.x;
			pin0.y = start.y;
			pin1.x = end.x;
			pin1.y = end.y;
		}

		public function onSelect(selection:Selection):void
		{
			selection.add(this.anchor0);
			selection.add(this.anchor1);
		}

		private function findBody0(world:b2World, position:b2Vec2):void
		{
			this.queryBodyResult = [];

			world.QueryPoint(queryBody0, position);
			this.body0 = (IndexUtil.getMaxIndex(queryBodyResult, this.anchor0.parentStarling.getChildStarlingIndex(this.anchor0)) as GameBody);

			this.queryBodyResult = null;
		}

		private function Intersection(ax1:int, ay1:int, ax2:int, ay2:int, bx1:int, by1:int, bx2:int, by2:int):Boolean
		{
			var v1:Number = (bx2 - bx1) * (ay1 - by1) - (by2 - by1) * (ax1 - bx1);
			var v2:Number = (bx2 - bx1) * (ay2 - by1) - (by2 - by1) * (ax2 - bx1);
			var v3:Number = (ax2 - ax1) * (by1 - ay1) - (ay2 - ay1) * (bx1 - ax1);
			var v4:Number = (ax2 - ax1) * (by2 - ay1) - (ay2 - ay1) * (bx2 - ax1);
			return ((v1 * v2 <= 0) && (v3 * v4 <= 0));
		}

		private function queryBody0(fixture:b2Fixture):Boolean
		{
			var queryBody:b2Body = fixture.GetBody();
			if (queryBody.GetUserData() is GameBody && queryBody.GetUserData() != this.body1)
				this.queryBodyResult.push(queryBody.GetUserData());
			return true;
		}

		private function findBody1(world:b2World, position:b2Vec2):void
		{
			this.queryBodyResult = [];

			world.QueryPoint(queryBody1, position);
			this.body1 = (IndexUtil.getMaxIndex(queryBodyResult, this.anchor1.parentStarling.getChildStarlingIndex(this.anchor1)) as GameBody);

			this.queryBodyResult = null;
		}

		private function queryBody1(fixture:b2Fixture):Boolean
		{
			var queryBody:b2Body = fixture.GetBody();
			if (queryBody.GetUserData() is GameBody && queryBody.GetUserData() != this.body0)
				this.queryBodyResult.push(queryBody.GetUserData());
			return true;
		}
	}
}