package game.mainGame.entity.joints
{
	import flash.filters.GlowFilter;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import game.mainGame.Cast;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.entity.cast.ICastTool;
	import game.mainGame.entity.editor.ButtonSensor;
	import game.mainGame.entity.editor.ClickButton;
	import game.mainGame.entity.simple.GameBody;

	import interfaces.IDispose;

	import utils.IndexUtil;
	import utils.WorldQueryUtil;
	import utils.starling.StarlingAdapterSprite;

	public class JointRevolute extends StarlingAdapterSprite implements IGameObject, IDispose, IJoint, ISerialize, IUpdate, ICastTool
	{
		static private const GLOW:GlowFilter = new GlowFilter(0xA2F327, 1, 2, 2, 5);

		private var _toWorld:Boolean;
		private var _motorSpeed:Number = 0;
		private var _motorTorque:Number = 0;
		private var _motorEnabled:Boolean;
		private var _limited:Boolean;
		private var _maxLimit:Number = 0;
		private var _minLimit:Number = 0;

		private var queryBodyResult:Array = null;

		private var toBodyView:StarlingAdapterSprite = new StarlingAdapterSprite(new JointDot());
		private var limitedSprite:StarlingAdapterSprite = new StarlingAdapterSprite(new PinLimited());
		private var unlimitedSprite:StarlingAdapterSprite = new StarlingAdapterSprite(new PinUnlimited());
		private var motorIcon:StarlingAdapterSprite = new StarlingAdapterSprite(new MotorIcon());

		private var jointDef:b2RevoluteJointDef = null;
		private var bodyAId:int = -1;
		private var bodyBId:int = -1;

		private var _toBody:GameBody = null;
		private var _toBodyAnchor:b2Vec2 = null;
		private var _toRefAngle:Number = 0;

		protected var joint:b2RevoluteJoint = null;
		protected var gameBody:GameBody = null;
		protected var builded:Boolean = false;

		public var world:b2World = null;
		public var flipFlop:Boolean;

		public function JointRevolute():void
		{
			this.limitedSprite.x = -this.limitedSprite.width / 2;
			this.limitedSprite.y = -this.limitedSprite.height / 2;

			this.unlimitedSprite.x = -this.unlimitedSprite.width / 2;
			this.unlimitedSprite.y = -this.unlimitedSprite.height / 2;

			this.toBodyView.x = -this.toBodyView.width / 2;
			this.toBodyView.y = -this.toBodyView.height / 2;

			this.motorIcon.alignPivot();
			this.motorIcon.y = 2;
			this.motorIcon.x = 2;
			addChildStarling(this.limitedSprite);
			addChildStarling(this.unlimitedSprite);
			addChildStarling(this.toBodyView);
			addChildStarling(this.motorIcon);

			this.toWorld = false;
			this.limited = false;
			this.motorEnabled = false;
			this.jointDef = new b2RevoluteJointDef();
			this.jointDef.localAnchorA = null;
			this.jointDef.localAnchorB = null;
		}

		public function set body(value:GameBody):void
		{
			if (this.parentStarling != null && this.gameBody)
				this.parentStarling.removeChildStarling(this, false);

			this.gameBody = value;
			if (value == null)
				return;

			value.addChildStarling(this);
		}

		public function get body():GameBody
		{
			return this.gameBody;
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
			this.motorIcon.scaleX = (-value / Math.abs(value));
			this.motorIcon.alignPivot();
			this.motorIcon.x = 2 * (this.motorIcon.scaleX > 0 ? 1 : -1);
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

		public function build(world:b2World):void
		{
			this.world = world;
			builded = true;
			var anchor:b2Vec2 = this.globalPosition;

			this.toBody = this.toBody ? this.toBody : (this.world.userData as SquirrelGame).map.getObject(this.bodyBId) as GameBody;
			this.body = this.body ? this.body : (this.world.userData as SquirrelGame).map.getObject(this.bodyAId) as GameBody;

			if (this.body == null)
				findMainBody(world, anchor);
			if (this.toBody == null && !this.toWorld)
				findToBody(world, anchor);

			this.clearToBodyFilter();

			if (this.body == null || (this.toBody == null && !this.toWorld))
			{
				this.visible = false;
				return;
			}

			if (!this.toWorld && this.limited && this.body.fixedRotation && this.toBody.fixedRotation)
				this.body.fixedRotation = false;

			if (jointDef.localAnchorA != null)
			{
				this.jointDef.bodyA = this.body.body;
				this.jointDef.bodyB = (this.toWorld ? world.GetGroundBody() : this.toBody.body);
			}
			else
				this.jointDef.Initialize(this.body.body, (this.toWorld ? world.GetGroundBody() : this.toBody.body), anchor);

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
			result.push([this.motorEnabled, this.motorSpeed, this.motorTorque, this.limited, this.maxLimit, this.minLimit, this.flipFlop]);

			if (this.jointDef.localAnchorA != null)
				result.push([this.body.id,
							[this.jointDef.localAnchorA.x, this.jointDef.localAnchorA.y],
							this.toBody ? this.toBody.id : -1,
							[this.jointDef.localAnchorB.x, this.jointDef.localAnchorB.y],
							this.jointDef.referenceAngle, this.motorEnabled]);
			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0], data[1]);

			if (!(2 in data))
				return;

			this.motorEnabled = Boolean(data[2][0]);
			this.motorSpeed = data[2][1];
			this.motorTorque = data[2][2];
			this.limited = Boolean(data[2][3]);
			this.maxLimit = data[2][4];
			this.minLimit = data[2][5];
			this.flipFlop = Boolean(data[2][6]);

			this.jointDef = new b2RevoluteJointDef();
			this.jointDef.localAnchorA = null;
			if (!(3 in data))
				return;

			this.bodyAId = data[3][0];
			this.jointDef.localAnchorA = new b2Vec2(data[3][1][0], data[3][1][1]);

			this.bodyBId = data[3][2];
			this.jointDef.localAnchorB = new b2Vec2(data[3][3][0], data[3][3][1]);

			this.jointDef.referenceAngle = data[3][4];
		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{}

		public function dispose():void
		{
			clearToBodyFilter();
			if (this.parentStarling != null)
				this.parentStarling.removeChildStarling(this);

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
			if (this.joint == null && body != null && !this.toWorld && !builded)
			{
				var pos:b2Vec2 = WorldQueryUtil.GetWorldPoint(body, this.position);
				findToBody(this.world, pos);
				if (toBody && toBody.body)
				{
					this.toBodyAnchor = toBody.body.GetLocalPoint(pos);
					this._toRefAngle = toBody.angle - body.angle;
				}
			}

			if (!this.flipFlop || this.joint == null)
				return;

			if (this.joint.GetJointAngle() > this.joint.GetUpperLimit())
				this.joint.SetMotorSpeed(-Math.abs(this.joint.GetMotorSpeed()));
			if (this.joint.GetJointAngle() < this.joint.GetLowerLimit())
				this.joint.SetMotorSpeed(Math.abs(this.joint.GetMotorSpeed()));
		}

		public function set game(value:SquirrelGame):void
		{}

		public function onCastStart():void
		{
			if (toBody == null ||  this.toBody.body == null || this.jointDef == null)
				return;

			this.jointDef.localAnchorA = this.position;
			this.jointDef.localAnchorB = this.toBody.body.GetLocalPoint(this.globalPosition);
			this.jointDef.referenceAngle = this.toBody.angle - this.body.angle;
		}

		public function onCastCancel():void
		{}

		public function onCastComplete():void
		{}

		private function setMotor():void
		{
			if (this.joint == null)
				return;

			this.joint.EnableMotor(this.motorTorque != 0 && this.motorEnabled);
			this.joint.SetMotorSpeed(this.motorSpeed);
			this.joint.SetMaxMotorTorque(this.motorTorque);
		}

		private function findMainBody(world:b2World, position:b2Vec2):void
		{
			this.queryBodyResult = [];
			world.QueryPoint(queryMainBody, position);

			this.body = (IndexUtil.getMaxIndex(queryBodyResult, this.parentStarling.getChildStarlingIndex(this)) as GameBody);
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
			this.queryBodyResult = [];

			world.QueryPoint(queryToBody, position);

			if (this.parentStarling && this.parentStarling.parentStarling && this.parentStarling.parentStarling is Cast)
				this.toBody = (IndexUtil.getMaxIndex(queryBodyResult) as GameBody);
			else
				this.toBody = (IndexUtil.getMaxIndex(
					queryBodyResult,
					(this.body == null ? this.parentStarling : this.body.parentStarling)
						.getChildStarlingIndex(
							(this.body == null ? this : this.parentStarling)
						)) as GameBody);

			this.queryBodyResult = null;
		}

		private function queryToBody(fixture:b2Fixture):Boolean
		{
			var userData:* = fixture.GetBody().GetUserData();
			if (userData is GameBody && !(userData is IPinFree) && userData != this.body)
				this.queryBodyResult.push(userData);

			return true;
		}

		private function get globalPosition():b2Vec2
		{
			if (this.body == null)
				return this.position;

			return WorldQueryUtil.GetWorldPoint(this.body, this.position);
		}

		public function get toBodyAnchor():b2Vec2
		{
			return _toBodyAnchor;
		}

		public function set toBodyAnchor(value:b2Vec2):void
		{
			_toBodyAnchor = value;
		}

		public function get toBody():GameBody
		{
			return _toBody;
		}

		public function set toBody(value:GameBody):void
		{
			if (_toBody == value)
				return;
			clearToBodyFilter();
			_toBody = value;
			if (_toBody == null)
				return;
			_toBody.filters = _toBody.filters.concat([GLOW]);
		}

		private function setLimits():void
		{
			if (this.joint == null)
				return;

			this.joint.EnableLimit(this.limited);
			this.joint.SetLimits(this.minLimit, this.maxLimit);
		}

		private function clearToBodyFilter():void
		{
			if (_toBody != null)
			{
				var bodyFilters:Array = _toBody.filters;
				for each (var filter:* in bodyFilters)
				{
					if (filter is GlowFilter && (filter as GlowFilter).color == GLOW.color)
					{
						bodyFilters.splice(bodyFilters.indexOf(filter), 1);
					}
				}
				_toBody.filters = bodyFilters;
			}
		}
	}
}