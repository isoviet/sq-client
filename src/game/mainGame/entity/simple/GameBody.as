package game.mainGame.entity.simple
{
	import flash.filters.GlowFilter;
	import flash.utils.getTimer;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointEdge;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import game.mainGame.ActiveBodiesCollector;
	import game.mainGame.CollisionGroup;
	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.ICache;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.joints.IJoint;
	import game.mainGame.entity.joints.JointRevolute;
	import syncronize.SyncGameBody;

	import by.blooddy.crypto.serialization.JSON;

	import interfaces.IDispose;

	public class GameBody extends BindPoint implements IUpdate, IDispose, IGameObject, ISerialize, IEditorDebugDraw, ICache
	{
		//static public const GHOST_FILTER:Array = [new GlowFilter(0xC0C0C0, 0.5, 60, 60, 100, 1, true, true)];
		//static private const GHOST_TO_OBJECT_FILTER:Array = [new GlowFilter(0x00FFFF, 0.5, 60, 60, 100, 1, true, true)];

		static public const GHOST_FILTER:Array = [new GlowFilter(0x00FFFF, 1, 10, 10, 1, 1, true, true)];
		static public const GHOST_TO_OBJECT_FILTER:Array =  [new GlowFilter(0x00A0FF, 1, 30, 30, 100, 1, true, true)];
		static public const GHOST_OBJECT_ALPHA: Number = 0.5;

		private var _ghost:Boolean = false;
		private var _ghostToObject:Boolean = false;
		private var _fixedRotation:Boolean = false;
		private var _fixed:Boolean;

		private var _speed:Number = 1;

		private var linearDeserializeVelocity:b2Vec2 = new b2Vec2();
		private var angularDeserializeVelocity:Number = 0;

		private var _body:b2Body = null;
		private var joint:b2Joint = null;

		private var errorSended:Boolean = false;
		private var _syncObject: SyncGameBody;

		protected var gameInst:SquirrelGame = null;

		protected var builded:Boolean = false;

		public var castType:int = -1;
		public var playerId:int = -1;

		public var lastTime: Number = 0;

		public function GameBody(body:b2Body = null):void
		{
			super();
			this.body = body;
		}

		public function get casted():Boolean
		{
			return this.castType != -1
		}

		public function get syncObject(): SyncGameBody {
			return _syncObject;
		}

		public function set syncObject(value: SyncGameBody): void {
			_syncObject = value;
		}

		static public function isOldStyle(data:*):Boolean
		{
			return (data[0] is Array && data[0].length == 2);
		}

		override public function bindWith(points:Vector.<IGameObject>):void
		{
			removeWays();

			super.bindWith(points);
		}

		override public function set x(value:Number):void
		{
			super.x = value;

			updateWays();
		}

		override public function set y(value:Number):void
		{
			super.y = value;

			updateWays();
		}

		public function get cacheBitmap():Boolean
		{
			return this.fixed;
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
			if (this._ghost == value)
				return;

			this._ghost = value;

			if (value && this.ghostToObject)
				this.ghostToObject = false;

			setFilter(this.ghost ? GHOST_FILTER : []);

			if (this.body == null)
				return;

			setCategorieBits(this._ghost ? this.categoriesBitsGhost : this.categoriesBits);
		}

		public function get ghostToObject():Boolean
		{
			return this._ghostToObject;
		}

		public function set ghostToObject(value:Boolean):void
		{
			if (this._ghostToObject == value)
				return;

			this._ghostToObject = value;

			if (value && this.ghost)
				this.ghost = false;

			if (this.debugDraw) {
				setFilter(this.ghostToObject ? GHOST_TO_OBJECT_FILTER : []);
			}

			if (this.body == null)
				return;

			setCategorieBits(this._ghost ? this.categroiesBitsGhostToObject : this.categoriesBits);
		}

		public function get fixedRotation():Boolean
		{
			return this._fixedRotation;
		}

		public function set fixedRotation(value:Boolean):void
		{
			if (this.fixed && value)
				this.fixed = false;

			this._fixedRotation = value;

			if (this.body)
				this.body.SetFixedRotation(value);
		}

		public function get speed():Number
		{
			return this._speed;
		}

		public function set speed(value:Number):void
		{
			this._speed = Math.abs(value);
		}

		public function setFilter(filter:Array):void
		{
			if (filter) {/*unused*/}

			if (this is IJoint)
				return;

			if (this.alpha > 0)
				this.alpha = this._ghost ? GHOST_OBJECT_ALPHA : 1;

			//this.filters = filter;
		}

		public function build(world:b2World):void
		{
			if (lastTime == -1) {
				lastTime = getTimer();
			}

			Logger.add("GameBody.build " + this, this.parentStarling, (getTimer() - lastTime));
			lastTime = getTimer();

			this.showDebug = false;
			this.gameInst = world.userData as SquirrelGame;

			this.body.SetPositionAndAngle(new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE), this.rotation * (Game.D2R));
			this._body.SetFixedRotation(fixedRotation);
			fix();

			this.linearVelocity = this.linearDeserializeVelocity;
			this.angularVelocity = this.angularDeserializeVelocity;

			checkNaN();

			if (this.ghost)
			{
				setCategorieBits(this.categoriesBitsGhost);
				setFilter(GHOST_FILTER);
			}

			if (this.ghostToObject)
				setCategorieBits(this.categroiesBitsGhostToObject);
		}

		public function set fixed(value:Boolean):void
		{
			if (this._fixed == value)
				return;

			if (this.fixedRotation && value)
				this.fixedRotation = false;

			this._fixed = value;

			fix();
		}

		public function get fixed():Boolean
		{
			if (this.body && !this._fixed)
			{
				var list:b2JointEdge = this.body.GetJointList();
				var joint:* = null, jointRev:JointRevolute = null;
				for (; list; list = list.next)
				{
					joint = list.joint.GetUserData();
					if (!(joint is JointRevolute))
						continue;

					jointRev = (joint as JointRevolute);
					if (jointRev.toWorld && jointRev.limited && jointRev.maxLimit == jointRev.minLimit)
						return true;
				}
			}
			return this._fixed;
		}

		public function get id():int
		{
			if (this.gameInst == null || this.gameInst.map == null)
				return -1;

			return this.gameInst.map.getID(this);
		}

		public function dispose():void
		{
			try {
				syncObject = null;

				while (this.numChildren > 0)
					removeChildStarlingAt(0);

				this.gameInst = null;

				this.removeFromParent();

				if (this.body == null)
					return;

				if (!this._fixed)
					ActiveBodiesCollector.removeBody(this.body);

				if (this._fixed && this.joint)
					removeJoint();

				for (var fixture:b2Fixture = this.body.GetFixtureList(); fixture; fixture = fixture.GetNext())
				{
					fixture.SetUserData(null);
				}

				this.body.SetUserData(null);
				this.body.GetWorld().DestroyBody(this.body);

				this.body = null;

			} catch (e: Error) {
				Logger.add('GameBody dispose error:', e.message);
			}
		}

		public function set showDebug(value:Boolean):void
		{
			this.debugDraw = value;
			this.waySprite.visible = this.debugDraw;
			updateWays();

			if (this.ghostToObject) {
				setFilter(value ? GHOST_TO_OBJECT_FILTER : []);
			}
		}

		public function get position():b2Vec2
		{
			if (this.body == null)
				return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);

			return this.body.GetPosition();
		}

		public function set position(value:b2Vec2):void
		{
			if (this.body == null)
			{
				this.x = value.x * Game.PIXELS_TO_METRE;
				this.y = value.y * Game.PIXELS_TO_METRE;
				return;
			}

			var removedJoint:Boolean = false;
			if (this.fixed && this.joint)
			{
				removedJoint = true;
				removeJoint();
			}

			this.body.SetPosition(value);
			updatePosition();

			if (removedJoint)
				addJoint();
		}

		override public function set alpha(value: Number): void
		{
			if (this._ghost)
			{
				value = Math.min(GHOST_OBJECT_ALPHA, value);
			}
			super.alpha = value;
		}

		public function set angle(value:Number):void
		{
			if (this.body == null)
			{
				this.rotation = value / (Game.D2R);
				return;
			}

			this.body.SetAngle(value);
			updatePosition();

			updateWays();
		}

		public function get angle():Number
		{
			if (this.body == null)
				return this.rotation * (Game.D2R);
			return this.body.GetAngle();
		}

		public function get linearVelocity():b2Vec2
		{
			if (this.body == null)
				return this.linearDeserializeVelocity;
			return this.body.GetLinearVelocity();
		}

		public function set linearVelocity(vector:b2Vec2):void
		{
			if (this.body == null)
			{
				this.linearDeserializeVelocity = vector;
				this.builded = true;
				return;
			}
			this.body.SetLinearVelocity(vector);
		}

		public function get angularVelocity():Number
		{
			if (this.body == null)
				return this.angularDeserializeVelocity;
			return this.body.GetAngularVelocity();
		}

		public function set angularVelocity(value:Number):void
		{
			if (this.body == null)
			{
				this.angularDeserializeVelocity = value;
				this.builded = true;
				return;
			}
			this.body.SetAngularVelocity(value);
		}

		public function update(timeStep:Number = 0):void
		{
			if (this.body == null)
				return;

			if (this.body.IsAwake() && this.visible && this.body.IsActive())
				updatePosition();

			this.body.SetActive(this.body.GetPosition().y < 150);
		}

		public function updatePosition():void
		{
			if (this.body == null)
				return;

			var pos:b2Vec2 = this.body.GetPosition();
			this.x = pos.x * Game.PIXELS_TO_METRE;
			this.y = pos.y * Game.PIXELS_TO_METRE;
			this.rotation = this.body.GetAngle() * Game.R2D;
		}

		public function serialize():*
		{
			var result:Array = [];

			var bodyBuilded:String = ((this.body != null || this.builded) ? "1" : "0");

			result.push([[this.position.x, this.position.y], this.angle, this.ghost, this.fixed, this.fixedRotation, [this.linearVelocity.x, this.linearVelocity.y], this.angularVelocity, bodyBuilded, this.speed, this.ghostToObject]);
			return result;
		}

		public function deserialize(data:*):void
		{
			if(!data)
				return;

			// FIXME Old style deserialize
			if (GameBody.isOldStyle(data))
			{
				this.position = new b2Vec2(data[0][0], data[0][1]);
				this.angle = data[1];
				this.ghost = Boolean(data[2]);
				return;
			}

			this.position = new b2Vec2(data[0][0][0], data[0][0][1]);
			this.angle = data[0][1];
			this.ghost = Boolean(data[0][2]);
			this.fixed = Boolean(data[0][3]);
			this.fixedRotation = Boolean(data[0][4]);

			if (data[0].length < 6)
				return;

			this.linearDeserializeVelocity = new b2Vec2(data[0][5][0], data[0][5][1]);
			this.angularDeserializeVelocity = data[0][6];
			this.builded = data[0][7] == "1";

			if (data[0].length < 9)
				return;

			this.speed = data[0][8];

			if (data[0].length < 10)
				return;

			this.ghostToObject = Boolean(data[0][9]);
		}

		protected function get categoriesBits():uint
		{
			return CollisionGroup.OBJECT_CATEGORY;
		}

		protected function get categoriesBitsGhost():uint
		{
			return CollisionGroup.OBJECT_GHOST_CATEGORY;
		}

		protected function get categroiesBitsGhostToObject():uint
		{
			return CollisionGroup.OBJECT_GHOST_TO_OBJECT_CATEGORY;
		}

		private function fix():void
		{
			if (!this.body)
				return;

			if (!this.joint)
			{
				if (!this._fixed)
				{
					ActiveBodiesCollector.addBody(this.body);
					return;
				}

				ActiveBodiesCollector.removeBody(this.body);

				addJoint();
			}
			else
			{
				if (this._fixed)
					return;

				ActiveBodiesCollector.addBody(this.body);

				removeJoint();
			}
		}

		private function addJoint():void
		{
			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize(this.body.GetWorld().GetGroundBody(), this.body, this.body.GetPosition());
			jointDef.enableLimit = true;
			jointDef.lowerAngle = 0;
			jointDef.upperAngle = 0;

			this.joint = this.body.GetWorld().CreateJoint(jointDef);
		}

		private function removeJoint():void
		{
			this.body.GetWorld().DestroyJoint(this.joint);
			this.joint = null;
		}

		private function checkNaN():void
		{
			if (this.errorSended)
				return;

			if (isNaN(this.body.GetPosition().x) || isNaN(this.body.GetPosition().y) || isNaN(this.body.GetAngle()) || isNaN(this.body.GetLinearVelocity().x) || isNaN(this.body.GetLinearVelocity().y) || isNaN(this.body.GetAngularVelocity()))
			{
				PreLoader.sendError(new Error("!!!NaN!!! " + this, 666));
				Logger.add("Error NaN " + by.blooddy.crypto.serialization.JSON.encode(this.body));
				this.gameInst.onError();
				this.errorSended = true;
			}
		}

		private function setCategorieBits(value:int):void
		{
			for (var fixture:b2Fixture = this.body.GetFixtureList(); fixture; fixture = fixture.GetNext())
			{
				var filterData:b2FilterData = fixture.GetFilterData();
				filterData.categoryBits = value;
				fixture.SetFilterData(filterData);
			}
		}
	}
}