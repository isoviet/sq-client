package game.mainGame.entity.joints
{
	import flash.utils.getTimer;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJoint;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.simple.GameBody;

	import interfaces.IDispose;

	import utils.IndexUtil;
	import utils.starling.StarlingAdapterSprite;

	public class JointDrag extends StarlingAdapterSprite implements IGameObject, IJoint, ISerialize, IDispose, IUpdate
	{
		private var view:StarlingAdapterSprite;
		private var world:b2World;
		private var _body:GameBody;
		private var queryBodyResult:Array;
		private var bodyId:int = -1;

		private var _active:Boolean;
		private var _toPos:b2Vec2 = new b2Vec2();

		private var joint:b2DistanceJoint;
		private var toBody:b2Body;

		private var _posQueue:Array = [];
		private var firstTime:int;
		private var myTime:int;
		private var waitForQueue:Boolean;

		public function JointDrag():void
		{
			this.view = new StarlingAdapterSprite(new JointDragView());
			this.view.alignPivot();
			addChildStarling(view);
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

		public function get body():GameBody
		{
			return _body;
		}

		public function set body(value:GameBody):void
		{
			_body = value;

			if (this.parentStarling != null && this.body)
				this.parentStarling.removeChildStarling(this, false);

			this._body = value;
			if (value == null)
				return;

			value.addChildStarling(this);
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			if (_active == value)
				return;

			if (!this.body || !this.body.body)
			{
				Logger.add('ERROR JointDrag: ' + this.body);
				return;
			}

			if (this.posQueue is Array && this.posQueue.length > 0 && !value)
			{
				waitForQueue = true;
				return;
			}

			_active = value;

			this.scaleX = this.scaleY = this._active ? 2 : 1;

			if (world == null)
				return;

			if (value)
			{
				if (this.toBody == null)
					this.toBody = this.world.CreateBody(new b2BodyDef(true, false, b2Body.b2_kinematicBody));

				var anchor:b2Vec2 = this.body.body.GetWorldPoint(this.position);

				this.toBody.SetPosition(anchor);

				if (this.joint == null)
				{
					var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
					jointDef.bodyA = this.body.body;
					jointDef.bodyB = this.toBody;
					jointDef.localAnchorA = this.position;
					jointDef.localAnchorB = new b2Vec2();
					jointDef.length = 0;
					jointDef.dampingRatio = 0.8;
					jointDef.frequencyHz = 1;

					this.joint = this.world.CreateJoint(jointDef) as b2DistanceJoint;
				}
			}
			else
			{
				if (this.joint != null)
					this.world.DestroyJoint(this.joint);
				this.joint = null;

				if (this.toBody != null)
					this.world.DestroyBody(this.toBody);
				this.toBody = null;
			}
		}

		public function get toPos():b2Vec2
		{
			return _toPos;
		}

		public function set toPos(value:b2Vec2):void
		{
			_toPos = value;

			if (this.toBody == null || this.body == null || this.body.body == null || !this.active)
				return;

			this.toBody.SetPosition(value);
			this.toBody.SetAwake(true);
			this.body.body.SetAwake(true);
		}

		public function get posQueue():Array
		{
			return _posQueue;
		}

		public function set posQueue(value:Array):void
		{
			_posQueue = _posQueue.concat(value);

			if (value.length == 0)
				return;

			this.myTime = getTimer();
			this.firstTime = value[0][0];
		}

		public function build(world:b2World):void
		{
			this.world = world;

			this.body = this.body ? this.body : (this.world.userData as SquirrelGame).map.getObject(this.bodyId) as GameBody;

			if (this.body == null)
			{
				findBody(world, this.position);

				if (this.body == null)
				{
					this.visible = false;
					return;
				}
			}

			this.position = this.body.body.GetLocalPoint(this.position);
		}

		public function serialize():*
		{
			var globalPoint:b2Vec2 = null;
			if (this.body != null && this.body.body)
				globalPoint = this.body.body.GetWorldPoint(this.position);
			else
				globalPoint = this.position;

			var result:Array = [globalPoint.x, globalPoint.y, this.active, this.toPos.x, this.toPos.y];

			if (this.body)
			{
				result.push([this.body.id]);
				result.push(this.posQueue);
			}

			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0], data[1]);
			this.active = Boolean(data[2]);
			this.toPos = new b2Vec2(data[3], data[4]);

			if (!(5 in data))
				return;

			this.bodyId = data[5];
			this._posQueue = data[6];
		}

		public function dispose():void
		{
			this._posQueue = [];
			this.active = false;

			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			if (this.parentStarling)
				this.parentStarling.removeChildStarling(this);
		}

		public function update(timeStep:Number = 0):void
		{
			var curTime:int = getTimer() - this.myTime;
			while (true)
			{
				if (this.posQueue.length == 0)
				{
					this.myTime = 0;
					this.firstTime = 0;

					if (this.waitForQueue)
						this.active = false;

					this.waitForQueue = false;
					return;
				}

				var data:Array = this.posQueue[0];
				if (curTime < data[0] - this.firstTime)
					return;

				this.toPos = new b2Vec2(data[1][0], data[1][1]);
				this.posQueue.shift();
			}
		}

		private function findBody(world:b2World, position:b2Vec2):void
		{
			this.queryBodyResult = [];

			world.QueryPoint(queryBody, position);

			this.body = (IndexUtil.getMaxIndex(queryBodyResult, this.parentStarling.getChildStarlingIndex(this)) as GameBody);
			this.queryBodyResult = null;
		}

		private function queryBody(fixture:b2Fixture):Boolean
		{
			var queryBody:b2Body = fixture.GetBody();
			if (queryBody.GetUserData() is GameBody)
				this.queryBodyResult.push(queryBody.GetUserData());
			return true;
		}
	}
}