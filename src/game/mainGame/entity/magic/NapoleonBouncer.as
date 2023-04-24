package game.mainGame.entity.magic
{
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.simple.Bouncer;

	import utils.starling.StarlingAdapterMovie;

	public class NapoleonBouncer extends Bouncer implements ILifeTime
	{
		private var _aging:Boolean = true;
		private var _lifeTime:Number = 15 * 1000;

		private var disposed:Boolean = false;

		public function NapoleonBouncer()
		{
			this.view = new StarlingAdapterMovie(new NapoleonPerkView());
			this.view.stop();
			this.view.loop = false;
			addChildStarling(this.view);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;
			if (!this.aging || this.disposed)
				return;

			this.lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.aging, this.lifeTime, this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.aging = Boolean(data[2][0]);
			this.lifeTime = data[2][1];
			this.playerId = data[2][2];
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
			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}