package landing.game.mainGame.entity.joints
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2LineJointDef;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
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
	import landing.game.mainGame.gameEditor.Selection;

	import utils.IndexUtil;

	public class JointPrismatic extends Sprite implements IJoint, IComplexEditorObject, IGameObject, ISerialize, IDispose, IUpdate, IUnselectable
	{

		private var anchor0:JointPoint = null;
		private var axis:JointPoint = null;

		private var body0:GameBody = null;
		private var body1:GameBody = null;
		private var queryBodyResult:Array = null;

		private var useLinearJoint:Boolean = false;

		private var jointDef:* = null;
		private var body0Id:int = -1;
		private var body1Id:int = -1;

		private var joint:b2Joint = null;

		private var world:b2World = null;
		private var view:DisplayObject = new PinUnlimited();

		public var motorSpeed:Number = 0;
		public var motorForce:Number = 0;
		public var motorEnabled:Boolean = false;
		public var flipFlop:Boolean = false;
		public var limited:Boolean = false;
		public var maxLimit:Number = 0;
		public var minLimit:Number = 0;

		public function JointPrismatic():void
		{
			addChild(this.view);

			this.anchor0 = new JointPoint(this);
			this.axis = new JointAxis(this);
		}

		public function onAddedToMap(map:GameMap):void
		{
			while (this.numChildren > 0)
				removeChildAt(0);

			map.add(this.anchor0);
			map.add(this.axis);

			if (this.anchor0.position.x != 0 || this.anchor0.position.y != 0)
				return;

			var pos:b2Vec2 = this.position.Copy();
			pos.Add(new b2Vec2(-5, 0));
			this.anchor0.position = pos;

			pos.Add(new b2Vec2(10, 0));
			this.axis.position = pos;

			update();
		}

		public function onRemovedFromMap(map:GameMap):void
		{
			map.remove(this.anchor0);
			this.anchor0.dispose();

			map.remove(this.axis);
			this.axis.dispose();
		}

		public function get fixedRotation():Boolean
		{
			return !this.useLinearJoint;
		}

		public function set fixedRotation(value:Boolean):void
		{
			this.useLinearJoint = !value;
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
			this.anchor0.visible = false;
			this.axis.visible = false;

			while (this.numChildren > 0)
				removeChildAt(0);
			this.world = world;

			if (this.body0Id == -1)
			{
				if (this.body0 == null)
					findBody0(world, this.anchor0.position);
				if (this.body1 == null)
					findBody1(world, this.axis.position);
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
				this.jointDef = this.useLinearJoint ? new b2LineJointDef() : new b2PrismaticJointDef();
				this.jointDef.Initialize(bBody0, bBody1, this.axis.position, new b2Vec2(Math.cos(this.axis.angle), Math.sin(this.axis.angle)));
			}

			this.jointDef.enableMotor = this.motorEnabled;
			this.jointDef.motorSpeed = this.motorSpeed;
			this.jointDef.maxMotorForce = this.motorForce;
			this.jointDef.enableLimit = this.limited;
			this.jointDef.lowerTranslation = this.minLimit;
			this.jointDef.upperTranslation = this.maxLimit;

			this.joint = world.CreateJoint(this.jointDef);

			this.anchor0.position = this.jointDef.localAnchorA;
			this.axis.position = this.jointDef.localAnchorB;

			if (this.body0 != null)
				this.body0.addChild(this.anchor0);
			if (this.body1 != null)
				this.body1.addChild(this.axis);
		}

		public function serialize():*
		{
			var result:Array = new Array();

			result.push([this.position.x, this.position.y]);
			result.push([this.anchor0.position.x, this.anchor0.position.y]);
			result.push([this.axis.position.x, this.axis.position.y, this.axis.angle]);
			result.push(this.useLinearJoint);
			result.push([this.limited, this.minLimit, this.maxLimit]);
			result.push([this.motorEnabled, this.motorSpeed, this.motorForce, this.flipFlop]);

			if (this.jointDef != null)
				result.push([this.body0 ? this.body0.id : -1, this.body1 ? this.body1.id : -1, [this.jointDef.localAnchorA.x, this.jointDef.localAnchorA.y], [this.jointDef.localAnchorB.x, this.jointDef.localAnchorB.y], [this.jointDef.localAxisA.x, this.jointDef.localAxisA.y], this.jointDef.referenceAngle]);
			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.anchor0.position = new b2Vec2(data[1][0], data[1][1]);
			this.axis.position = new b2Vec2(data[2][0], data[2][1]);
			this.axis.angle = data[2][2];
			this.useLinearJoint = data[3];
			this.limited = data[4][0];
			this.minLimit = data[4][1];
			this.maxLimit = data[4][2];

			this.motorEnabled = data[5][0];
			this.motorSpeed = data[5][1];
			this.motorForce = data[5][2];
			this.flipFlop = data[5][3];

			if (!(6 in data))
				return;

			this.body0Id = data[6][0];
			this.body1Id = data[6][1];
			this.jointDef = this.useLinearJoint ? new b2LineJointDef() : new b2PrismaticJointDef();
			this.jointDef.localAnchorA = new b2Vec2(data[6][2][0], data[6][2][1]);
			this.jointDef.localAnchorB = new b2Vec2(data[6][3][0], data[6][3][1]);
			this.jointDef.localAxisA = new b2Vec2(data[6][4][0], data[6][4][1]);
			this.jointDef.referenceAngle = data[6][5];
		}

		public function dispose():void
		{
			this.graphics.clear();

			if (this.parent != null)
				this.parent.removeChild(this);

			if (this.anchor0 != null)
				this.anchor0.dispose();
			this.anchor0 = null;

			if (this.axis != null)
				this.axis.dispose();
			this.axis = null;

			if (this.joint != null)
				this.world.DestroyJoint(this.joint);
			this.joint = null;
		}

		public function update(timeStep:Number = 0):void
		{
			this.rotation = 0;
			this.graphics.clear();

			var tmpJoint:* = this.joint;
			if (this.flipFlop && tmpJoint != null)
			{
				if (tmpJoint.GetJointTranslation() > tmpJoint.GetUpperLimit())
					tmpJoint.SetMotorSpeed(-Math.abs(tmpJoint.GetMotorSpeed()));
				if (tmpJoint.GetJointTranslation() < tmpJoint.GetLowerLimit())
					tmpJoint.SetMotorSpeed(Math.abs(tmpJoint.GetMotorSpeed()));
			}

			var start:b2Vec2 = this.joint ? this.joint.GetAnchorA(): this.anchor0.position;
			start.Multiply(WallShadow.PIXELS_TO_METRE);

			var end:b2Vec2 = this.joint ? this.joint.GetAnchorB(): this.axis.position;
			end.Multiply(WallShadow.PIXELS_TO_METRE);

			var center:b2Vec2 = new b2Vec2((start.x + end.x) / 2, (start.y + end.y) / 2);
			this.x = center.x;
			this.y = center.y;

			start.Subtract(center);
			end.Subtract(center);

			this.graphics.lineStyle(4, 0xC0C0C0);
			this.graphics.moveTo(start.x, start.y);
			this.graphics.lineTo(end.x, end.y);
		}

		public function onSelect(selection:Selection):void
		{
			selection.add(this.anchor0);
			selection.add(this.axis);
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
			this.body1 = (IndexUtil.getMaxIndex(queryBodyResult, this.axis.parent.getChildIndex(this.axis)) as GameBody);

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