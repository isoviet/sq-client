package game.mainGame.entity.joints
{
	import flash.display.Shape;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2LineJoint;
	import Box2D.Dynamics.Joints.b2LineJointDef;
	import Box2D.Dynamics.Joints.b2PrismaticJoint;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import game.mainGame.GameMap;
	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IUnselectable;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.gameEditor.Selection;

	import interfaces.IDispose;

	import utils.IndexUtil;
	import utils.starling.StarlingAdapterSprite;

	public class JointPrismatic extends StarlingAdapterSprite implements IJoint, IComplexEditorObject, IGameObject, ISerialize, IDispose, IUpdate, IUnselectable, IEditorDebugDraw
	{
		private var anchor0:JointPoint = null;
		private var axis:JointAxis = null;

		private var body0:GameBody = null;
		private var body1:GameBody = null;
		private var queryBodyResult:Array = null;

		private var useLinearJoint:Boolean = false;

		private var jointDef:* = null;
		private var body0Id:int = -1;
		private var body1Id:int = -1;

		private var joint:b2Joint = null;

		private var world:b2World = null;
		private var view:StarlingAdapterSprite = new StarlingAdapterSprite(new PinLimited());

		private var _motorSpeed:Number = 0;
		private var _motorForce:Number = 0;
		private var _motorEnabled:Boolean = false;

		private var _limited:Boolean = false;
		private var _maxLimit:Number = 0;
		private var _minLimit:Number = 0;

		public var flipFlop:Boolean = false;
		public var graphicsLayer: StarlingAdapterSprite = new StarlingAdapterSprite();

		public function JointPrismatic():void {
			this.anchor0 = new JointPoint(this);
			this.axis = new JointAxis(this);
			view.alignPivot();
			initPreView();
		}

		public function onAddedToMap(map:GameMap):void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0, false);

			addChildStarling(graphicsLayer);

			map.add(this.anchor0);
			map.add(this.axis);

			if (this.anchor0.position.x != 0 || this.anchor0.position.y != 0)
				return;

			initJoint();
			update();
		}

		private function initPreView(): void {
			this.view.x = -10 * Game.PIXELS_TO_METRE;
			addChildStarling(graphicsLayer);

			var graph: Shape = new Shape();
			graph.graphics.lineStyle(4, this.fixedRotation ? 0xFF4646 : 0xFEFE3F);
			graph.graphics.moveTo(this.view.x, this.view.y);
			graph.graphics.lineTo(this.anchor0.x, this.anchor0.y);
			graph.graphics.endFill();
			graphicsLayer.addChildStarling(new StarlingAdapterSprite(graph));
			addChildStarling(this.view);
			addChildStarling(this.anchor0);
			addChildStarling(this.axis);
		}

		private function initJoint(): void {
			var pos:b2Vec2 = this.position.Copy();
			pos.Add(new b2Vec2(-5, 0));
			this.anchor0.position = pos;

			pos.Add(new b2Vec2(10, 0));
			this.axis.position = pos;
		}

		public function onRemovedFromMap(map:GameMap):void {
			map.remove(this.anchor0);
			map.remove(this.axis);
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
			this.anchor0.visible = false;
			this.axis.visible = false;

			while (this.numChildren > 0)
				removeChildStarlingAt(0, false);

			this.world = world;

			if (this.jointDef == null)
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
				this.body0.addChildStarling(this.anchor0);

			if (this.body1 != null)
				this.body1.addChildStarling(this.axis);
		}

		public function serialize():*
		{
			var result:Array = [];

			result.push([this.position.x, this.position.y]);
			result.push([this.anchor0.position.x, this.anchor0.position.y]);
			result.push([this.axis.position.x, this.axis.position.y, this.axis.angle]);
			result.push(this.useLinearJoint);
			result.push([this.limited, this.minLimit, this.maxLimit]);
			result.push([this.motorEnabled, this.motorSpeed, this.motorForce, this.flipFlop]);

			if (this.jointDef != null)
				result.push([this.body0 ? this.body0.id : -1, this.body1 ? this.body1.id : -1, [this.jointDef.localAnchorA.x, this.jointDef.localAnchorA.y], [this.jointDef.localAnchorB.x, this.jointDef.localAnchorB.y], [this.jointDef.localAxisA.x, this.jointDef.localAxisA.y], this.jointDef is b2PrismaticJointDef ? this.jointDef.referenceAngle : 0]);
			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.anchor0.position = new b2Vec2(data[1][0], data[1][1]);
			this.axis.position = new b2Vec2(data[2][0], data[2][1]);
			this.axis.angle = data[2][2];
			this.useLinearJoint = Boolean(data[3]);
			this.limited = Boolean(data[4][0]);
			this.minLimit = data[4][1];
			this.maxLimit = data[4][2];

			this.motorEnabled = Boolean(data[5][0]);
			this.motorSpeed = data[5][1];
			this.motorForce = data[5][2];
			this.flipFlop = Boolean(data[5][3]);

			if (!(6 in data))
				return;

			this.body0Id = data[6][0];
			this.body1Id = data[6][1];
			this.jointDef = this.useLinearJoint ? new b2LineJointDef() : new b2PrismaticJointDef();
			this.jointDef.localAnchorA = new b2Vec2(data[6][2][0], data[6][2][1]);
			this.jointDef.localAnchorB = new b2Vec2(data[6][3][0], data[6][3][1]);
			this.jointDef.localAxisA = new b2Vec2(data[6][4][0], data[6][4][1]);
			if (!this.useLinearJoint)
				this.jointDef.referenceAngle = data[6][5];
		}

		public function dispose():void
		{
			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			if (this.parentStarling != null)
				this.parentStarling.removeChildStarling(this);

			this.removeFromParent();
			view.removeFromParent();

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

			var tmpJoint:* = this.joint;
			if (this.flipFlop && tmpJoint != null)
			{
				if (tmpJoint.GetJointTranslation() > tmpJoint.GetUpperLimit())
					tmpJoint.SetMotorSpeed(-Math.abs(tmpJoint.GetMotorSpeed()));
				if (tmpJoint.GetJointTranslation() < tmpJoint.GetLowerLimit())
					tmpJoint.SetMotorSpeed(Math.abs(tmpJoint.GetMotorSpeed()));
			}

			var start:b2Vec2 = this.joint ? this.joint.GetAnchorA(): this.anchor0.position;
			start.Multiply(Game.PIXELS_TO_METRE);

			var end:b2Vec2 = this.joint ? this.joint.GetAnchorB(): this.axis.position;
			end.Multiply(Game.PIXELS_TO_METRE);

			var center:b2Vec2 = new b2Vec2((start.x + end.x) / 2, (start.y + end.y) / 2);
			this.x = center.x;
			this.y = center.y;

			start.Subtract(center);
			end.Subtract(center);

			if (timeStep == 0)
			{
				if (graphicsLayer) {
					while (graphicsLayer.numChildren > 0) {
						graphicsLayer.removeChildStarlingAt(0);
					}
				}

				var graph: Shape = new Shape();
				graph.graphics.lineStyle(4, this.fixedRotation ? 0xFF4646 : 0xFEFE3F);
				graph.graphics.moveTo(start.x, start.y);
				graph.graphics.lineTo(end.x, end.y);
				graph.graphics.endFill();
				graphicsLayer.addChildStarling(new StarlingAdapterSprite(graph));
			}
		}

		public function onSelect(selection:Selection):void
		{
			selection.add(this.anchor0);
			selection.add(this.axis);
		}

		public function set showDebug(value:Boolean):void
		{
			this.visible = value;
		}

		public function get motorSpeed():Number
		{
			return _motorSpeed;
		}

		public function set motorSpeed(value:Number):void
		{
			_motorSpeed = value;
			setMotor();
		}

		public function get motorForce():Number
		{
			return _motorForce;
		}

		public function set motorForce(value:Number):void
		{
			_motorForce = value;
			setMotor();
		}

		public function get motorEnabled():Boolean
		{
			return _motorEnabled;
		}

		public function set motorEnabled(value:Boolean):void
		{
			_motorEnabled = value;
			setMotor();
		}

		public function get limited():Boolean
		{
			return _limited;
		}

		public function set limited(value:Boolean):void
		{
			_limited = value;
			setLimits();
		}

		public function get maxLimit():Number
		{
			return _maxLimit;
		}

		public function set maxLimit(value:Number):void
		{
			_maxLimit = value;
			setLimits();
		}

		public function get minLimit():Number
		{
			return _minLimit;
		}

		public function set minLimit(value:Number):void
		{
			_minLimit = value;
			setLimits();
		}

		private function setMotor():void
		{
			if (this.joint == null)
				return;

			if (this.joint is b2PrismaticJoint)
			{
				(this.joint as b2PrismaticJoint).EnableMotor(this.motorEnabled);
				(this.joint as b2PrismaticJoint).SetMotorSpeed(this.motorSpeed);
				(this.joint as b2PrismaticJoint).SetMaxMotorForce(this.motorForce);
			}

			if (this.joint is b2LineJoint)
			{
				(this.joint as b2LineJoint).EnableMotor(this.motorEnabled);
				(this.joint as b2LineJoint).SetMotorSpeed(this.motorSpeed);
				(this.joint as b2LineJoint).SetMaxMotorForce(this.motorForce);
			}
		}

		private function setLimits():void
		{
			if (this.joint == null)
				return;

			if (this.joint is b2PrismaticJoint)
			{
				(this.joint as b2PrismaticJoint).SetLimits(this.minLimit, this.maxLimit);
				(this.joint as b2PrismaticJoint).EnableLimit(this.limited);
			}

			if (this.joint is b2LineJoint)
			{
				(this.joint as b2LineJoint).SetLimits(this.minLimit, this.maxLimit);
				(this.joint as b2LineJoint).EnableLimit(this.limited);
			}
		}

		private function findBody0(world:b2World, position:b2Vec2):void
		{
			this.queryBodyResult = [];

			world.QueryPoint(queryBody0, position);
			this.body0 = (IndexUtil.getMaxIndex(queryBodyResult, this.anchor0.parentStarling.getChildStarlingIndex(this.anchor0)) as GameBody);

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
			this.queryBodyResult = [];

			world.QueryPoint(queryBody1, position);
			this.body1 = (IndexUtil.getMaxIndex(queryBodyResult, this.axis.parentStarling.getChildStarlingIndex(this.axis)) as GameBody);

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