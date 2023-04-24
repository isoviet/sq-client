package game.mainGame.entity.battle
{
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.getTimer;

	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.IShootBattle;
	import game.mainGame.entity.simple.GameBody;
	import sensors.ISensor;

	import com.greensock.TweenMax;

	import utils.starling.StarlingAdapterSprite;

	public class BattlePoise extends GameBody implements ISensor, ILifeTime, IShootBattle
	{
		static private const BLUE_FILTER:Array = [new GlowFilter(0x0037ff, 1, 4, 4, 2.08)];
		static private const RED_FILTER:Array = [new GlowFilter(0xff3a33, 1, 4, 4, 2.08)];

		protected var _aging:Boolean = true;
		protected var _lifeTime:Number = 3000;
		protected var disposed:Boolean = false;
		protected var creationTime:Number = -1;

		protected var _aimCursor:StarlingAdapterSprite = null;
		protected var view:StarlingAdapterSprite = null;

		public function BattlePoise():void
		{}

		override public function build(world:b2World):void
		{
			super.build(world);

			if (!this.builded)
				this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(200, 0)));

			if ((this.playerId != -1) && this.gameInst.squirrels.get(this.playerId))
			{
				switch (this.gameInst.squirrels.get(this.playerId).heroView.team)
				{
					case Hero.TEAM_BLUE:
						this.view.filters = BLUE_FILTER;
						break;
					case Hero.TEAM_RED:
						this.view.filters = RED_FILTER;
						break;
				}
			}

			this.creationTime = getTimer();
		}

		override public function dispose():void
		{
			super.dispose();

			this.view = null;
			this._aimCursor = null;
			this.removeFromParent();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body)
			{
				this.body.SetBullet(this.body.GetLinearVelocity().Length() > 100);

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

			result.push([this.aging, this.lifeTime]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			if ('1' in data)
			{
				this.aging = Boolean(data[1][0]);
				this.lifeTime = data[1][1];
			}
		}

		public function get aimCursor():StarlingAdapterSprite
		{
			if (this._aimCursor == null) {
				this._aimCursor = new StarlingAdapterSprite(new AimCursor());
			}

			return this._aimCursor;
		}

		public function onAim(point:Point):void
		{
			this.aimCursor.x = point.x;
			this.aimCursor.y = point.y;
		}

		public function get maxVelocity():Number
		{
			return 0;
		}

		public function get reloadTime():int
		{
			return 0;
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

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

		protected function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			TweenMax.to(this, 0.1, {'alpha': 0.75, 'onComplete': death});
		}

		protected function death():void
		{
			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}