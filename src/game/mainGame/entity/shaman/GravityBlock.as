package game.mainGame.entity.shaman
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.editor.RectGravity;

	import com.greensock.TweenMax;

	public class GravityBlock extends RectGravity implements ILifeTime
	{
		static private const BLOCK_LIFE_TIME:int = 20 * 1000;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = BLOCK_LIFE_TIME;
		private var disposed:Boolean = false;

		private var gameInst:SquirrelGame = null;

		public function GravityBlock():void
		{
			super();

			this.size = new b2Vec2(0.1, 0.1);
			this.affectObject = false;
			this.extGravity = false;
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
			var dat:Array = data.pop();

			this.aging = Boolean(dat[0]);
			this.lifeTime = dat[1];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.aging || this.disposed)
				return;

			this._lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		override public function build(world:b2World):void
		{
			this.gameInst = world.userData as SquirrelGame;

			super.build(world);
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
			if (this.gameInst && this.gameInst.map)
				this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}