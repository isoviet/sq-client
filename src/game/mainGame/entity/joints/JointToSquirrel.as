package game.mainGame.entity.joints
{
	import flash.events.Event;

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
	import game.mainGame.entity.IUnselectable;
	import game.mainGame.entity.view.JointBaseView;
	import game.mainGame.gameEditor.Selection;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class JointToSquirrel extends StarlingAdapterSprite implements IJoint, IComplexEditorObject, IGameObject, ISerialize, IDispose, IUpdate, IUnselectable
	{
		private var joint:b2Joint = null;

		private var world:b2World = null;

		protected var body0Id:int = -1;
		protected var body1Id:int = -1;
		protected var jointDef:b2DistanceJointDef = null;
		protected var jointView:JointBaseView;

		public var broken:Boolean;

		public var damping:Number = 0.1;
		public var frequency:Number = 1;

		public var anchor0:JointPoint = null;
		public var anchor1:JointPoint = null;

		public var hero0:Hero = null;
		public var hero1:Hero = null;

		public function JointToSquirrel():void
		{
			this.anchor0 = new JointPoint(this, new StarlingAdapterSprite(new PinUnlimited));
			this.anchor0.visible = false;

			this.anchor1 = new JointPoint(this, new StarlingAdapterSprite(new PinUnlimited));
			this.anchor1.visible = false;
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

		protected function get maxLength():Number
		{
			return 5;
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
				this.hero1 = ((world.userData as SquirrelGame).squirrels.get(this.body0Id) as Hero);
				this.hero0 = ((world.userData as SquirrelGame).squirrels.get(this.body1Id) as Hero);
			}

			if (this.hero1 == null && this.hero0 == null)
			{
				this.visible = false;
				return;
			}

			if (jointDef == null)
				this.jointDef = new b2DistanceJointDef();

			if (this.hero1 && this.hero1.isExist)
				this.hero1.bindToDistanceJointDef(this.jointDef);
			else if (world.GetGroundBody())
				this.jointDef.bodyA = world.GetGroundBody();
			else
			{
				this.visible = false;
				return;
			}

			if (this.hero0 && this.hero0.isExist)
				this.hero0.bindToDistanceJointDef(this.jointDef, false);
			else if (world.GetGroundBody())
				this.jointDef.bodyB = world.GetGroundBody();
			else
			{
				this.visible = false;
				return;
			}

			this.jointDef.rope = true;
			this.jointDef.localAnchorA = new b2Vec2();
			this.jointDef.localAnchorB = new b2Vec2();
			this.jointDef.length = this.maxLength;

			this.jointDef.dampingRatio = this.damping;
			this.jointDef.frequencyHz = this.frequency;
			this.jointDef.collideConnected = true;

			this.joint = world.CreateJoint(this.jointDef);

			this.anchor0.position = this.jointDef.localAnchorA;
			this.anchor1.position = this.jointDef.localAnchorB;

			if (this.hero1 != null)
				this.hero1.addChild(this.anchor0);
			if (this.hero0 != null)
				this.hero0.addChild(this.anchor1);

			this.jointView.setHeroes(hero0, hero1);

			listenBreak();
		}

		public function serialize():*
		{}

		public function deserialize(data:*):void
		{}

		public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			this.graphics.clear();
			this.hero0 = null;
			this.hero1 = null;

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
		}

		public function update(timeStep:Number = 0):void
		{}

		public function onSelect(selection:Selection):void
		{
			selection.add(this.anchor0);
			selection.add(this.anchor1);
		}

		protected function onBreak(e:Event = null):void
		{
			this.dispose();
		}

		protected function listenBreak():void
		{}
	}
}