package landing.game.mainGame.entity.joints
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.GameMap;
	import landing.game.mainGame.IDispose;
	import landing.game.mainGame.ISerialize;
	import landing.game.mainGame.IUpdate;
	import landing.game.mainGame.SquirrelGame;
	import landing.game.mainGame.entity.IComplexEditorObject;
	import landing.game.mainGame.entity.IGameObject;
	import landing.game.mainGame.entity.IUnselectable;
	import landing.game.mainGame.entity.simple.GameBody;
	import landing.game.mainGame.entity.view.SpringView;
	import landing.game.mainGame.gameEditor.Selection;

	import utils.IndexUtil;

	public class JointDistance extends Sprite implements IJoint, IComplexEditorObject, IGameObject, ISerialize, IDispose, IUpdate, IUnselectable
	{
		private var anchor0:JointPoint = null;
		private var anchor1:JointPoint = null;

		private var body0:GameBody = null;
		private var body1:GameBody = null;
		private var queryBodyResult:Array = null;

		private var jointDef:b2DistanceJointDef = null;
		private var body0Id:int = -1;
		private var body1Id:int = -1;

		private var joint:b2Joint = null;

		private var world:b2World = null;
		private var view:DisplayObject = new SpringJointView();
		private var spring:SpringView = new SpringView();

		public var damping:Number = 0;
		public var frequency:Number = 1;

		public function JointDistance():void
		{
			addChild(view);

			this.anchor0 = new JointPoint(this, new PinUnlimited);
			this.anchor1 = new JointPoint(this, new PinUnlimited);
		}

		public function onAddedToMap(map:GameMap):void
		{
			while (this.numChildren > 0)
				removeChildAt(0);

			addChild(this.spring);

			map.add(this.anchor0);
			map.add(this.anchor1);

			if (this.anchor0.position.x != 0 || this.anchor0.position.y != 0)
				return;

			var pos:b2Vec2 = this.position.Copy();
			pos.Add(new b2Vec2(-31.5 / WallShadow.PIXELS_TO_METRE, 0));
			this.anchor0.position = pos;

			pos.Add(new b2Vec2(63 / WallShadow.PIXELS_TO_METRE, 0));
			this.anchor1.position = pos;

			update();
		}

		public function onRemovedFromMap(map:GameMap):void
		{
			map.remove(this.anchor0);
			this.anchor0.dispose();

			map.remove(this.anchor1);
			this.anchor1.dispose();
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
			super.rotation = 0;
		}

		public function build(world:b2World):void
		{
			while (this.numChildren > 0)
				removeChildAt(0);

			addChild(this.spring);
			update();

			this.spring.initLength();
			this.world = world;

			if (this.body0Id == -1)
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
				this.body0.addChild(this.anchor0);
			if (this.body1 != null)
				this.body1.addChild(this.anchor1);
		}

		public function serialize():*
		{
			var result:Array = new Array();

			result.push([this.position.x, this.position.y]);
			result.push([this.anchor0.position.x, this.anchor0.position.y]);
			result.push([this.anchor1.position.x, this.anchor1.position.y]);
			result.push([this.frequency, this.damping]);

			if (this.jointDef != null)
				result.push([this.body0 ? this.body0.id : -1, this.body1 ? this.body1.id : -1, [this.jointDef.localAnchorA.x, this.jointDef.localAnchorA.y], [this.jointDef.localAnchorB.y, this.jointDef.localAnchorB.y], this.jointDef.length]);
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

		public function dispose():void
		{
			this.graphics.clear();

			if (this.parent != null)
				this.parent.removeChild(this);

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
			start.Multiply(WallShadow.PIXELS_TO_METRE);

			var end:b2Vec2 = this.joint ? this.joint.GetAnchorB(): this.anchor1.position;
			end.Multiply(WallShadow.PIXELS_TO_METRE);

			var center:b2Vec2 = new b2Vec2((start.x + end.x) / 2, (start.y + end.y) / 2);
			this.x = center.x;
			this.y = center.y;

			start.Subtract(center);
			end.Subtract(center);

			this.spring.start = new Point(start.x, start.y);
			this.spring.end = new Point(end.x, end.y);
		}

		public function onSelect(selection:Selection):void
		{
			selection.add(this.anchor0);
			selection.add(this.anchor1);
		}

		private function findBody0(world:b2World, position:b2Vec2):void
		{
			this.queryBodyResult = new Array();

			world.QueryPoint(queryBody0, position);
			this.body0 = (IndexUtil.getMaxIndex(queryBodyResult, this.anchor0.parent.getChildIndex(this.anchor0)) as GameBody);

			this.queryBodyResult = null;
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
			this.queryBodyResult = new Array();

			world.QueryPoint(queryBody1, position);
			this.body1 = (IndexUtil.getMaxIndex(queryBodyResult, this.anchor1.parent.getChildIndex(this.anchor1)) as GameBody);

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