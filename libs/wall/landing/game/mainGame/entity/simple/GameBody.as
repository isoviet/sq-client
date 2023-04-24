package landing.game.mainGame.entity.simple
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointEdge;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.CollisionGroup;
	import landing.game.mainGame.IDispose;
	import landing.game.mainGame.ISerialize;
	import landing.game.mainGame.IUpdate;
	import landing.game.mainGame.SquirrelGame;
	import landing.game.mainGame.entity.IGameObject;
	import landing.game.mainGame.entity.joints.JointRevolute;

	import utils.Box2DUtil;

	public class GameBody extends Sprite implements IUpdate, IDispose, IGameObject, ISerialize
	{
		private var _ghost:Boolean = false;
		private var _noCollision:Boolean = false;
		private var _fixedRotation:Boolean = false;
		private var _fixed:Boolean;

		private var _body:b2Body = null;
		private var joint:b2Joint = null;
		private var game:SquirrelGame = null;

		public var casted:Boolean;

		public function GameBody(body:b2Body = null):void
		{
			super();

			this.body = body;
		}

		public function get body():b2Body
		{
			return this._body;
		}

		public function set body(value:b2Body):void
		{
			this._body = value;

			if (this._body == null)
				return;

			this._body.SetUserData(this);
		}

		public function get ghost():Boolean
		{
			return this._ghost;
		}

		public function set ghost(value:Boolean):void
		{
			this._ghost = value;

			if (value)
				this.noCollision = false;

			for (var i:int = 0; i < this.numChildren; i++)
				getChildAt(i).filters = this.ghost ? [new GlowFilter(0xC0C0C0, 0.5, 60, 60, 100, 1, true, true)] : [];
		}

		public function set noCollision(value:Boolean):void
		{
			this._noCollision = value;

			if (value)
				this.ghost = false;

			for (var i:int = 0; i < this.numChildren; i++)
				getChildAt(i).filters = this.noCollision ? [new GlowFilter(0xC0C0C0, 0.1, 60, 60, 100, 1, true, true)] : [];
		}

		public function get noCollision():Boolean
		{
			return this._noCollision;
		}

		public function get fixedRotation():Boolean
		{
			return this._fixedRotation;
		}

		public function set fixedRotation(value:Boolean):void
		{
			this._fixedRotation = value;

			if (this.body)
				this.body.SetFixedRotation(value);
		}

		public function build(world:b2World):void
		{
			this.game = world.userData as SquirrelGame;
			Box2DUtil.debugDraw(this.body.GetWorld(), this.parent);

			this.body.SetPositionAndAngle(new b2Vec2(this.x / WallShadow.PIXELS_TO_METRE, this.y / WallShadow.PIXELS_TO_METRE), this.rotation * (Math.PI / 180));
			this._body.SetFixedRotation(fixedRotation);
			fix();

			if (this.ghost || this.noCollision)
			{
				for (var fixture:b2Fixture = this.body.GetFixtureList(); fixture; fixture = fixture.GetNext())
				{
					var filterData:b2FilterData = fixture.GetFilterData();
					filterData.categoryBits = ghost ? CollisionGroup.OBJECT_GHOST_CATEGORY : CollisionGroup.OBJECT_NONE_CATEGORY;
					fixture.SetFilterData(filterData);
				}
			}

		}

		public function set fixed(value:Boolean):void
		{
			if (this._fixed == value)
				return;

			this._fixed = value;

			fix();
		}

		public function get fixed():Boolean
		{
			if (this.body)
			{
				var list:b2JointEdge = this.body.GetJointList();
				for (; list; list = list.next)
				{
					var joint:* = list.joint.GetUserData();
					if (joint is JointRevolute)
						var jointRev:JointRevolute = (joint as JointRevolute);
					if (jointRev)
						if (jointRev.toWorld && jointRev.limited && jointRev.maxLimit == jointRev.minLimit)
							return true;
				}
			}
			return this._fixed;
		}

		public function get id():int
		{
			if (this.game == null)
				return -1;

			return this.game.map.getID(this);
		}

		public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildAt(0);

			this.game = null;

			if (this.parent != null)
				this.parent.removeChild(this);

			if (this.body == null)
				return;

			this.fixed = false;

			this.body.SetUserData(null);
			this.body.GetWorld().DestroyBody(this.body);

			this.body = null;
		}

		public function get position():b2Vec2
		{
			if (this.body == null)
				return new b2Vec2(this.x / WallShadow.PIXELS_TO_METRE, this.y / WallShadow.PIXELS_TO_METRE);

			return this.body.GetPosition();
		}

		public function set position(value:b2Vec2):void
		{
			if (this.body == null)
			{
				this.x = value.x * WallShadow.PIXELS_TO_METRE;
				this.y = value.y * WallShadow.PIXELS_TO_METRE;
				return;
			}

			this.body.SetPosition(value);
			updatePosition();
		}

		public function set angle(value:Number):void
		{
			if (this.body == null)
			{
				this.rotation = value / (Math.PI / 180);
				return;
			}

			this.body.SetAngle(value);
			updatePosition();
		}

		public function get angle():Number
		{
			if (this.body == null)
				return this.rotation * (Math.PI / 180);
			return this.body.GetAngle();
		}

		public function update(timeStep:Number = 0):void
		{
			if (this.body == null)
				return;

			if (this.body.IsAwake() && this.visible)
				updatePosition();

			this.body.SetActive(this.body.GetPosition().y < 150);
		}

		public function updatePosition():void
		{
			if (this.body == null)
				return;

			var pos:b2Vec2 = this.body.GetPosition();
			this.x = pos.x * WallShadow.PIXELS_TO_METRE;
			this.y = pos.y * WallShadow.PIXELS_TO_METRE;
			this.rotation = this.body.GetAngle() * 180 / Math.PI;
		}

		public function serialize():*
		{
			var result:Array = new Array();

			result.push([this.position.x, this.position.y]);
			result.push(this.angle);
			result.push(this.ghost);
			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.angle = data[1];
			this.ghost = data[2];
		}

		private function fix():void
		{
			if (!this.body)
				return;

			if (!this.joint)
			{
				if (!this._fixed)
					return;

				var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
				jointDef.Initialize(this.body.GetWorld().GetGroundBody(), this.body, this.body.GetPosition());
				jointDef.enableLimit = true;
				jointDef.lowerAngle = 0;
				jointDef.upperAngle = 0;

				this.joint = this.body.GetWorld().CreateJoint(jointDef);
			}
			else
			{
				if (this._fixed)
					return;
				this.body.GetWorld().DestroyJoint(this.joint);
				this.joint = null;
			}
		}
	}

}