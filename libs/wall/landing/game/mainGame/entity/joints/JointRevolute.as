package landing.game.mainGame.entity.joints
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import game.mainGame.entity.editor.ButtonSensor;
	import game.mainGame.entity.editor.ClickButton;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.IDispose;
	import landing.game.mainGame.ISerialize;
	import landing.game.mainGame.IUpdate;
	import landing.game.mainGame.SquirrelGame;
	import landing.game.mainGame.entity.IGameObject;
	import landing.game.mainGame.entity.simple.GameBody;

	import utils.IndexUtil;

	public class JointRevolute extends Sprite implements IGameObject, IDispose, IJoint, ISerialize, IUpdate
	{
		private var _toWorld:Boolean;
		private var _motorSpeed:Number = 0;
		private var _motorTorque:Number = 0;
		private var _motorEnabled:Boolean;
		private var _limited:Boolean;
		private var _maxLimit:Number = 0;
		private var _minLimit:Number = 0;

		private var queryBodyResult:Array = null;

		private var toBodyView:DisplayObject = new JointDot();
		private var limitedSprite:DisplayObject = new PinLimited();
		private var unlimitedSprite:DisplayObject = new PinUnlimited();
		private var motorIcon:DisplayObject = new MotorIcon();

		private var jointDef:b2RevoluteJointDef = null;
		private var bodyAId:int = -1;
		private var bodyBId:int = -1;

		private var world:b2World = null;

		protected var joint:b2RevoluteJoint = null;
		protected var gameBody:GameBody = null;
		protected var toBody:GameBody = null;

		public var flipFlop:Boolean;

		public function JointRevolute():void
		{
			addChild(this.limitedSprite);
			addChild(this.unlimitedSprite);
			addChild(this.toBodyView);
			addChild(this.motorIcon);

			this.toWorld = false;
			this.limited = false;
			this.motorEnabled = false;
		}

		public function set body(value:GameBody):void
		{
			if (this.parent != null && this.gameBody)
				this.parent.removeChild(this);

			this.gameBody = value;
			if (value == null)
				return;

			value.addChild(this);
		}

		public function get body():GameBody
		{
			return this.gameBody;
		}

		public function get position():b2Vec2
		{
			if (this.body == null || this.body.body == null)
				return new b2Vec2(this.x / WallShadow.PIXELS_TO_METRE, this.y / WallShadow.PIXELS_TO_METRE);

			return this.body.position;
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * WallShadow.PIXELS_TO_METRE;
			this.y = value.y * WallShadow.PIXELS_TO_METRE;
		}

		public function set toWorld(value:Boolean):void
		{
			this._toWorld = value;
			this.toBodyView.visible = !value;
		}

		public function get toWorld():Boolean
		{
			return this._toWorld;
		}

		public function set limited(value:Boolean):void
		{
			this._limited = value;
			this.limitedSprite.visible = value;
			this.unlimitedSprite.visible = !value;

			setLimits();
		}

		public function get limited():Boolean
		{
			return this._limited;
		}

		public function get maxLimit():Number
		{
			return this._maxLimit;
		}

		public function set maxLimit(value:Number):void
		{
			this._maxLimit = value;
			setLimits();
		}

		public function get minLimit():Number
		{
			return this._minLimit;
		}

		public function set minLimit(value:Number):void
		{
			this._minLimit = value;
			setLimits();
		}

		public function set motorSpeed(value:Number):void
		{
			this._motorSpeed = value;
			this.motorIcon.scaleX = Math.abs(this.motorIcon.scaleX) * (-value / Math.abs(value));

			setMotor();
		}

		public function get motorSpeed():Number
		{
			return this._motorSpeed;
		}

		public function set motorTorque(value:Number):void
		{
			this._motorTorque = value;
			setMotor();
		}

		public function get motorTorque():Number
		{
			return this._motorTorque;
		}

		public function set motorEnabled(value:Boolean):void
		{
			this._motorEnabled = value;
			this.motorIcon.visible = value;

			setMotor();
		}

		public function get motorEnabled():Boolean
		{
			return this._motorEnabled;
		}

		private function setMotor():void
		{
			if (this.joint == null)
				return;

			this.joint.EnableMotor(this.motorSpeed != 0 && this.motorTorque != 0 && this.motorEnabled);
			this.joint.SetMotorSpeed(this.motorSpeed);
			this.joint.SetMaxMotorTorque(this.motorTorque);
		}

		public function build(world:b2World):void
		{
			this.world = world;

			var anchor:b2Vec2 = this.globalPosition;

			if (this.bodyAId == -1)
			{
				if (this.gameBody == null)
					findMainBody(world, anchor);
				if (this.toBody == null && !this.toWorld)
					findToBody(world, anchor);
			}
			else
			{
				this.toBody = (this.world.userData as SquirrelGame).map.getObject(this.bodyBId) as GameBody;
				this.body = (this.world.userData as SquirrelGame).map.getObject(this.bodyAId) as GameBody;
			}

			if (this.gameBody == null || (this.toBody == null && !this.toWorld))
			{
				this.visible = false;
				return;
			}

			if (this.jointDef != null)
			{
				this.jointDef.bodyA = this.gameBody.body;
				this.jointDef.bodyB = (this.toWorld ? world.GetGroundBody() : this.toBody.body);
			}
			else
			{
				this.jointDef = new b2RevoluteJointDef();
				this.jointDef.Initialize(this.gameBody.body, (this.toWorld ? world.GetGroundBody() : this.toBody.body), anchor);
			}

			this.jointDef.collideConnected = false;
			this.jointDef.userData = this;

			this.position = this.jointDef.localAnchorA;

			this.joint = world.CreateJoint(this.jointDef) as b2RevoluteJoint;

			this.visible = (this.joint != null) && !(this.toBody is ButtonSensor || this.toBody is ClickButton || this.body is ButtonSensor || this.body is ClickButton);

			setLimits();
			setMotor();
		}

		public function serialize():*
		{
			var result:Array = [this.position.x, this.position.y];

			if (this.joint != null && this.jointDef != null)
				result.push([this.gameBody.id, [this.jointDef.localAnchorA.x, this.jointDef.localAnchorA.y], this.toBody ? this.toBody.id : -1, [this.jointDef.localAnchorB.x, this.jointDef.localAnchorB.y], this.jointDef.referenceAngle]);
			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0], data[1]);

			if (!(2 in data))
				return;

			this.jointDef = new b2RevoluteJointDef();
			this.bodyAId = data[2][0];
			this.jointDef.localAnchorA = new b2Vec2(data[2][1][0], data[2][1][1]);

			this.bodyBId = data[2][2];
			this.jointDef.localAnchorB = new b2Vec2(data[2][3][0], data[2][3][1]);

			this.jointDef.referenceAngle = data[2][4];
		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{}

		public function dispose():void
		{
			if (this.parent != null)
				this.parent.removeChild(this);

			this.toBody = null;
			this.body = null;

			if (this.joint == null)
				return;

			this.joint.SetUserData(null);
			this.world.DestroyJoint(this.joint);
			this.joint = null;
		}

		public function update(timeStep:Number = 0):void
		{
			if (!this.flipFlop || this.joint == null)
				return;

			if (this.joint.GetJointAngle() > this.joint.GetUpperLimit())
				this.joint.SetMotorSpeed(-Math.abs(this.joint.GetMotorSpeed()));
			if (this.joint.GetJointAngle() < this.joint.GetLowerLimit())
				this.joint.SetMotorSpeed(Math.abs(this.joint.GetMotorSpeed()));
		}

		private function findMainBody(world:b2World, position:b2Vec2):void
		{
			this.queryBodyResult = new Array();

			world.QueryPoint(queryMainBody, position);
			this.body = (IndexUtil.getMaxIndex(queryBodyResult, this.parent.getChildIndex(this)) as GameBody);

			this.queryBodyResult = null;
		}

		private function queryMainBody(fixture:b2Fixture):Boolean
		{
			var queryBody:b2Body = fixture.GetBody();
			if (queryBody.GetUserData() is GameBody && queryBody.GetUserData() != this.toBody)
				this.queryBodyResult.push(queryBody.GetUserData());
			return true;
		}

		private function findToBody(world:b2World, position:b2Vec2):void
		{
			this.queryBodyResult = new Array();

			world.QueryPoint(queryToBody, position);
			this.toBody = (IndexUtil.getMaxIndex(queryBodyResult, (this.gameBody == null ? this.parent : this.gameBody.parent).getChildIndex((this.gameBody == null ? this : this.parent))) as GameBody);

			this.queryBodyResult = null;
		}

		private function queryToBody(fixture:b2Fixture):Boolean
		{
			var queryBody:b2Body = fixture.GetBody();
			if (queryBody.GetUserData() is GameBody && queryBody.GetUserData() != this.gameBody)
				this.queryBodyResult.push(queryBody.GetUserData());
			return true;
		}

		private function get globalPosition():b2Vec2
		{
			if (this.gameBody == null || this.gameBody.body == null)
				return this.position;

			var pos:Point = Game.gameSprite.globalToLocal(localToGlobal(new Point(0, 0)));
			return new b2Vec2(pos.x / WallShadow.PIXELS_TO_METRE, pos.y / WallShadow.PIXELS_TO_METRE);
		}

		private function setLimits():void
		{
			if (this.joint == null)
				return;

			this.joint.EnableLimit(this.limited);
			this.joint.SetLimits(this.minLimit, this.maxLimit);
		}
	}
}