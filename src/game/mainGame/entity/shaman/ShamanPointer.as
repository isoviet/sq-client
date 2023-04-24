package game.mainGame.entity.shaman
{
	import Box2D.Dynamics.b2World;

	import game.mainGame.Cast;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.cast.ICastChange;
	import game.mainGame.entity.editor.decorations.Decoration;

	import com.greensock.TweenMax;

	import utils.starling.StarlingAdapterMovie;

	public class ShamanPointer extends Decoration implements ICastChange, IUpdate, ILifeTime
	{
		static private const LIFE_TIME:int = 5 * 1000;

		private var animated:Boolean = false;
		private var scale:Number = 1;

		private var view:StarlingAdapterMovie = null;

		private var oldCastTime:Number;
		private var oldCastRadius:Number;
		private var _cast:Cast = null;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = LIFE_TIME;
		private var disposed:Boolean = false;

		private var gameInst:SquirrelGame = null;

		public function ShamanPointer(scale:Number = 1, animated:Boolean = false):void
		{
			super(null);
			this.scale = scale;
			this.animated = animated;

			var arrow:ArrowRed = new ArrowRed();
			arrow.scaleX = arrow.scaleY = this.scale;

			this.view = new StarlingAdapterMovie(arrow);
			this.view.rotation = -90;
			this.view.x = -(arrow.height / 2);
			this.view.y = arrow.width / 2;
			this.view.stop();
			addChildStarling(this.view);
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			this.gameInst = world.userData as SquirrelGame;

			if (this.view.parent)
				this.view.parent.removeChild(this.view);

			this.view.removeFromParent();

			var arrow:ArrowRed = new ArrowRed();
			arrow.scaleX = arrow.scaleY = this.scale;

			this.view = new StarlingAdapterMovie(arrow);
			this.view.rotation = -90;
			this.view.loop = true;
			this.view.x = -(arrow.height / 2);
			this.view.y = arrow.width / 2;
			addChildStarling(this.view);

			(this.animated ? this.view.play() : this.view.stop());
		}

		override public function dispose():void
		{
			this._cast = null;

			if (this.view)
			{
				this.view.removeFromParent();
				this.view = null;
			}

			super.dispose();
		}

		override public function serialize():*
		{
			var data:Array = super.serialize();
			data.push([this.scale, this.animated, this.aging, this.lifeTime]);

			return data;
		}

		override public function deserialize(data:*):void
		{
			var dataPointer:Array = data.pop();

			this.scale = dataPointer[0];
			this.animated = Boolean(dataPointer[1]);
			this.aging = Boolean(dataPointer[2]);
			this.lifeTime = dataPointer[3];

			super.deserialize(data);
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

		public function update(timeStep:Number = 0):void
		{
			if (!this.aging || this.disposed)
				return;

			this._lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		public function set cast(cast:Cast):void
		{
			this._cast = cast;
		}

		public function setCastParams():void
		{
			this.oldCastRadius = this._cast.castRadius;
			this.oldCastTime = this._cast.castTime;

			this._cast.castRadius = 0;
			this._cast.castTime = 0;
		}

		public function resetCastParams():void
		{
			if (!this._cast)
				return;

			this._cast.castRadius = this.oldCastRadius;
			this._cast.castTime = this.oldCastTime;
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