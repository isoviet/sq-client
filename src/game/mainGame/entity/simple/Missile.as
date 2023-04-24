package game.mainGame.entity.simple
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.editor.Branch;
	import game.mainGame.entity.magic.TuxedoMaskRose;

	import utils.starling.StarlingAdapterSprite;

	public class Missile extends Branch implements IPersonalObject
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.8, 0.1, 0.1, CATEGORIES_BITS, MASK_BITS, 0);

		private var lifeTime:Number = 7.5;
		private var disposed:Boolean = false;

		protected var resetMass:Boolean = false;

		public var direct:Boolean = true;

		public function Missile():void
		{
			super();
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.resetMass)
			{
				this.body.GetFixtureList().SetDensity(200);
				this.body.ResetMassData();
				this.resetMass = false;
			}

			this.lifeTime -= timeStep;
			if (this.lifeTime <= 0)
				destroy();
		}

		override public function set rotation(value:Number):void
		{
			super.rotation = value;
			branchView.getStarlingView().scaleX = this.direct ? -1 : 1;
			if (branchView.scaleX >=0)
			{
				this.branchView.pivotX = this.branchView.width / 2 - 15;
			}
			else
			{
				this.branchView.pivotX = 0;
			}
			updateViewBranch();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.playerId, this.direct, this.lifeTime]);
			return result;
		}

		override protected function updateViewBranch(): void
		{
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			var index:int = GameBody.isOldStyle(data) ? 4 : 2;
			this.playerId = data[index][0];
			this.direct = Boolean(data[index][1]);
			this.lifeTime = data[index][2];
		}

		override public function build(world:b2World):void
		{
			super.build(world);

			this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(this.direct ? -100 : 100, -25)));
		}

		override public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			if (impulse) {/*unused*/}

			var otherObject:* = contact.GetFixtureA().GetBody().GetUserData();
			if (otherObject == this)
				otherObject = contact.GetFixtureB().GetBody().GetUserData();

			if (otherObject is TuxedoMaskRose)
			{
				contact.SetEnabled(false);
				return;
			}

			var hero:Hero = (otherObject as Hero);
			if (!hero)
			{
				if (!this.fixed)
				{
					this.fixed = true;
					this.branchView.visible = true;
					this.resetMass = true;
				}
			}
		}

		override public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if (oldManifold) {/*unused*/}

			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			var otherObject:* = contact.GetFixtureA().GetBody().GetUserData();
			if (otherObject == this)
				otherObject = contact.GetFixtureB().GetBody().GetUserData();

			var hero:Hero = (otherObject as Hero);
			if (!hero)
			{
				if (this.fixed)
					contact.SetEnabled(false);
				return;
			}

			if (contact.GetFixtureB().GetUserData() == this)
				contact.SetEnabled(maniFold.m_normal.y >= 0);
			else
				contact.SetEnabled(!(maniFold.m_normal.y >= 0));
		}

		public function get personalId():int
		{
			return this.playerId;
		}

		public function breakContact(playerId:int):Boolean
		{
			return this.personalId != playerId;
		}

		override protected function get fixture():b2FixtureDef
		{
			return FIXTURE_DEF;
		}

		override protected function init():void
		{
			this.branchView = new StarlingAdapterSprite(originBranchView);
			this.addChildStarling(branchView);

			size = new b2Vec2(branchView.width / Game.PIXELS_TO_METRE, 0);
			this.fixedRotation = true;
		}

		private function destroy():void
		{
			if (this.disposed)
				return;
			this.disposed = true;
			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}