package game.mainGame.entity.joints
{
	import flash.events.Event;

	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2World;

	import game.mainGame.GameMap;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.entity.IUnselectable;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.view.StickyView;
	import game.mainGame.gameEditor.Selection;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class JointSticky extends StarlingAdapterSprite implements IJoint, IComplexEditorObject, IGameObject, ISerialize, IDispose, IUpdate, IUnselectable, IPinFree
	{
		private var joint:b2Joint = null;

		private var world:b2World = null;

		protected var heroId:int = -1;
		protected var bodyId:int = -1;
		protected var jointDef:b2DistanceJointDef = null;
		protected var jointView:StickyView;

		public var lifeTimeEnabled:Boolean = true;
		public var lifeTime:Number = 10;

		public var body:GameBody = null;
		public var hero:Hero = null;

		public var broken:Boolean;

		public var damping:Number = 0.1;
		public var frequency:Number = 2;

		public var anchor0:JointPoint = null;
		public var anchor1:JointPoint = null;

		public function JointSticky():void
		{
			this.jointView = new StickyView();

			this.anchor0 = new JointPoint(this, new StarlingAdapterSprite(new PinUnlimited));
			this.anchor0.visible = false;

			this.anchor1 = new JointPoint(this, new StarlingAdapterSprite(new PinUnlimited));
			this.anchor1.visible = false;
		}

		override public function get rotation():Number
		{
			return 0;
		}

		override public function set rotation(value:Number):void
		{
			if (value) {/*unused*/}
			super.rotation = 0;
		}

		public function onAddedToMap(map:GameMap):void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0, false);

			addChildStarling(this.jointView);

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

		public function onRemovedFromMap(map:GameMap):void
		{
			map.remove(this.anchor0);
			if (this.anchor0 != null)
				this.anchor0.dispose();

			map.remove(this.anchor1);
			if (this.anchor1 != null)
				this.anchor1.dispose();
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

		public function build(world:b2World):void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0, false);

			if (this.broken)
			{
				this.visible = false;
				this.dispose();
				return;
			}

			addChildStarling(this.jointView);
			update();

			this.world = world;

			if (this.jointDef != null)
			{
				this.hero = ((world.userData as SquirrelGame).squirrels.get(this.heroId) as Hero);
				this.body = ((world.userData as SquirrelGame).map.getObject(this.bodyId) as GameBody);
			}

			if (!this.hero || !this.body)
			{
				this.visible = false;
				return;
			}

			if (jointDef == null)
				this.jointDef = new b2DistanceJointDef();

			this.jointDef.bodyA = body.body;

			if (this.hero && this.hero.isExist)
				this.hero.bindToDistanceJointDef(this.jointDef, false);
			else
			{
				this.visible = false;
				return;
			}

			if (this.body != null)
				this.body.addChild(this.anchor0);
			if (this.hero != null)
				this.hero.addChild(this.anchor1);

			this.jointDef.rope = true;
			this.jointDef.length = 5;

			this.jointDef.localAnchorA = new b2Vec2();
			this.jointDef.localAnchorB = new b2Vec2();

			this.jointDef.dampingRatio = this.damping;
			this.jointDef.frequencyHz = this.frequency;
			this.jointDef.collideConnected = true;

			this.joint = world.CreateJoint(this.jointDef);

			this.anchor0.position = this.jointDef.localAnchorA;
			this.anchor1.position = this.jointDef.localAnchorB;

			this.jointView.setView(body, hero);

			listenBreak();
		}

		public function onSelect(selection:Selection):void
		{
			selection.add(this.anchor0);
			selection.add(this.anchor1);
		}

		public function serialize():*
		{
			var result:Array = [];

			if (this.broken)
				return result;

			result.push([this.position.x, this.position.y]);
			result.push([this.anchor0.position.x, this.anchor0.position.y]);
			result.push([this.anchor1.position.x, this.anchor1.position.y]);
			result.push([this.frequency, this.damping]);
			result.push([this.lifeTime, this.lifeTimeEnabled]);
			result.push([this.hero ? this.hero.id : -1, this.body ? this.body.id : -1, broken]);

			return result;
		}

		public function deserialize(data:*):void
		{
			if (data.length == 0)
			{
				this.broken = true;
				return;
			}

			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.anchor0.position = new b2Vec2(data[1][0], data[1][1]);
			this.anchor1.position = new b2Vec2(data[2][0], data[2][1]);
			this.frequency = data[3][0];
			this.damping = data[3][1];

			this.lifeTime = data[4][0];
			this.lifeTimeEnabled = Boolean(data[4][1]);

			this.jointDef = new b2DistanceJointDef();
			this.heroId = data[5][0];
			this.bodyId = data[5][1];
		}

		public function update(timeStep:Number = 0):void
		{
			if (this.broken)
			{
				this.visible = false;
				return;
			}
			this.rotation = 0;

			if (this.lifeTimeEnabled)
			{
				this.lifeTime -= timeStep;

				this.jointView.alpha = b2Math.Clamp(this.lifeTime, 0, 1);

				if (this.lifeTime <= 0)
					this.onBreak();
			}
		}

		public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			this.graphics.clear();

			if (this.parentStarling != null)
				this.parentStarling.removeChildStarling(this);

			if (this.anchor0 != null)
				this.anchor0.dispose();
			this.anchor0 = null;

			if (this.anchor1 != null)
				this.anchor1.dispose();
			this.anchor1 = null;

			if (this.joint != null)
				this.world.DestroyJoint(this.joint);
			this.joint = null;
			this.jointView.visible = false;
			this.jointView.dispose();
			this.broken = true;

			this.body = null;
			this.hero = null;
		}

		protected function onBreak(e:Event = null):void
		{
			this.dispose();
		}

		protected function listenBreak():void
		{
			this.body.addEventListener(Hero.EVENT_BREAK_MAGIC_JOINT, onBreak, false, 0, true);
			this.hero.addEventListener(Hero.EVENT_BREAK_MAGIC_JOINT, onBreak, false, 0, true);
		}
	}
}