package game.mainGame.entity.shaman
{
	import flash.events.Event;
	import flash.utils.Timer;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.perks.shaman.PerkShamanFactory;

	import com.greensock.TweenMax;

	import utils.Animation;

	public class IceCube extends GameBody implements IPinFree, ILifeTime
	{
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const LIFE_TIME:int = 2 * 1000;

		public var objectFixture:Boolean = false;
		public var size:int = 40;
		public var heroId:int;

		private var view:Animation = null;
		private var hero:Hero = null;
		private var joint:b2Joint = null;

		private var timer:Timer = new Timer(LIFE_TIME / 100, 100);
		private var buff:BuffRadialView = null;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = LIFE_TIME;
		private var disposed:Boolean = false;

		public function IceCube():void
		{}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			var shape:b2PolygonShape = b2PolygonShape.AsOrientedBox(this.size / Game.PIXELS_TO_METRE, this.size / Game.PIXELS_TO_METRE, new b2Vec2());
			this.body.CreateFixture(new b2FixtureDef(shape, null, 0.1, 0.1, 1, this.categoriesBits, MASK_BITS, 0));
			super.build(world);

			this.fixedRotation = true;

			this.hero = (world.userData as SquirrelGame).squirrels.get(heroId);

			if (!this.hero || this.hero.isDead || this.hero.inHollow)
			{
				dispose();
				return;
			}

			freezeSquirrel();

			if (!this.hero.isSelf)
				return;

			this.timer.reset();
			this.timer.start();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body)
			{
				if (!this.aging || this.disposed)
					return;

				this._lifeTime -= timeStep * 1000;

				if (lifeTime <= 0)
					destroy();
			}
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.objectFixture, this.size, this.heroId, this.aging, this.lifeTime]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.objectFixture = Boolean(data[1][0]);
			this.size = data[1][1];
			this.heroId = data[1][2];
			this.aging = Boolean(data[1][3]);
			this.lifeTime = data[1][4];
		}

		override public function dispose():void
		{
			releaseSquirrel();

			this.timer.stop();

			super.dispose();
		}

		public function get aging():Boolean
		{
			return this._aging;
		}

		public function set aging(value:Boolean):void
		{
			this._aging = value;
		}

		public function get lifeTime():Number
		{
			return this._lifeTime;
		}

		public function set lifeTime(value:Number):void
		{
			this._lifeTime = value;
		}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			TweenMax.to(this, 0.1, {'alpha': 0, 'onComplete': death});
		}

		private function death():void
		{
			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}

		override protected function get categoriesBits():uint
		{
			return this.objectFixture ? CollisionGroup.OBJECT_CATEGORY : CollisionGroup.OBJECT_NONE_CATEGORY;
		}

		private function freezeSquirrel():void
		{
			this.position = this.hero.position.Copy();
			this.angle = this.hero.angle;

			this.position = b2Math.AddVV(this.position, this.body.GetWorldVector(new b2Vec2(0, -1)));
			this.hero.frozen = true;

			this.buff = new BuffRadialView(new PerkShamanFactory.perkData[PerkShamanFactory.getClassById(PerkShamanFactory.PERK_ICE_CUBE)]['buttonClass'], 0.7, 0.5, "<b/>" + PerkShamanFactory.perkData[PerkShamanFactory.getClassById(PerkShamanFactory.PERK_ICE_CUBE)]['name'] + "</b><br/>" + PerkShamanFactory.getDescriptionById(PerkShamanFactory.PERK_ICE_CUBE, PerkShamanFactory.DEFAULT_DESCRIPTION, null));
			this.hero.addBuff(this.buff, this.timer);

			var freezeView:FreezerView = new FreezerView();
			freezeView.scaleX = freezeView.scaleY = this.size * 2 / 40;

			this.view = new Animation(freezeView);
			this.view.x = -freezeView.width / 2 - 10;
			this.view.y = -freezeView.height / 2 - 10;
			this.view.play();
			this.hero.addChild(this.view);

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.bodyA = this.body;
			this.hero.bindToRevoluteJointDef(jointDef, false);
			jointDef.collideConnected = false;
			jointDef.localAnchorA = new b2Vec2(0, 1);
			jointDef.localAnchorB = new b2Vec2();
			this.joint = this.body.GetWorld().CreateJoint(jointDef);

			this.hero.addEventListener(SquirrelEvent.DIE, onHeroEvent);
			this.hero.addEventListener(SquirrelEvent.SHAMAN, onHeroEvent);
			this.hero.addEventListener(HollowEvent.HOLLOW, onHeroEvent);
			this.hero.addEventListener(SquirrelEvent.RESET, onHeroEvent);
		}

		private function releaseSquirrel():void
		{
			if (!this.hero)
				return;

			this.hero.removeEventListener(SquirrelEvent.DIE, onHeroEvent);
			this.hero.removeEventListener(SquirrelEvent.SHAMAN, onHeroEvent);
			this.hero.removeEventListener(HollowEvent.HOLLOW, onHeroEvent);
			this.hero.removeEventListener(SquirrelEvent.RESET, onHeroEvent);

			this.hero.frozen = false;

			if (this.buff)
				this.hero.removeBuff(this.buff, this.timer);

			if (this.view && this.view.parent)
				this.view.parent.removeChild(this.view);

			if (this.view)
				this.view.remove();

			if (!this.body)
				return;

			if (this.joint)
				this.body.GetWorld().DestroyJoint(this.joint);

			this.joint = null;
			this.hero = null;
		}

		private function onHeroEvent(e:Event):void
		{
			destroy();
		}
	}
}