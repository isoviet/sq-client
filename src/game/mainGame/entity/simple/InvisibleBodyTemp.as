package game.mainGame.entity.simple
{
	import flash.events.Event;

	import game.mainGame.entity.ILifeTime;

	import utils.starling.StarlingAdapterMovie;

	public class InvisibleBodyTemp extends InvisibleBody implements ILifeTime
	{
		protected var _aging:Boolean = true;
		protected var _lifeTime:Number = 10 * 1000;

		protected var disposed:Boolean = false;

		public function InvisibleBodyTemp(imageClass:Class, x:int, y:int)
		{
			if (!imageClass)
				return;
			this.view = new StarlingAdapterMovie(new imageClass);
			this.view.play();
			this.view.x = x;
			this.view.y = y;
			addChildStarling(this.view);

			if (this.stopInEnd)
				this.view.addEventListener(Event.ENTER_FRAME, onFrame);
		}

		public function get stopInEnd():Boolean
		{
			return false;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

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

			this.aging = Boolean(data[1][0]);
			this.lifeTime = data[1][1];
			this.playerId = data[1][2];
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

		protected function destroy():void
		{
			if (this.disposed)
				return;
			this.disposed = true;
			this.gameInst.map.destroyObjectSync(this, true);
		}

		protected function onFrame(e:Event):void
		{
			if (!this.view)
				return;
			if (this.view.currentFrame < this.view.totalFrames - 1)
				return;
			this.view.stop();
			this.view.removeEventListener(Event.ENTER_FRAME, onFrame);
		}
	}
}