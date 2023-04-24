package game.mainGame.entity.shaman
{
	import flash.geom.Point;

	import Box2D.Dynamics.b2World;

	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.cast.ICastRemote;
	import game.mainGame.entity.editor.decorations.Decoration;

	import com.greensock.TweenMax;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class ShamanTotem extends Decoration implements ICastRemote, ILifeTime, IUpdate
	{
		static private const LIFE_TIME:int = 60 * 1000;
		static private const DEFAULT_RADIUS:int = 100;

		static public var totemsOnMap:int = 0;

		private var view:StarlingAdapterMovie = null;
		private var _playerId:int;

		private var radiusView:StarlingAdapterSprite = null;
		public var radius:Number = DEFAULT_RADIUS;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = LIFE_TIME;
		private var disposed:Boolean = false;

		private var gameInst:SquirrelGame = null;

		private var builded:Boolean = false;

		public function ShamanTotem():void
		{
			super(null);
			this.view = new StarlingAdapterMovie(new TotemImg);
			this.view.stop();
			this.view.alignPivot();
			this.view.x = -13;

			addChildStarling(this.view);
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			super.build(world);

			this.gameInst = world.userData as SquirrelGame;
			this.view.play();

			this.radiusView = new StarlingAdapterSprite(new PerkRadius());
			this.radiusView.scaleXY((this.radius * 2) / this.radiusView.width);
			addChildStarling(this.radiusView);

			this.builded = true;

			if (this.playerId == Game.selfId)
			{
				totemsOnMap++;
				Logger.add("TOTEMS +", totemsOnMap);
			}
		}

		override public function dispose():void
		{
			if (this.playerId == Game.selfId && this.builded)
			{
				totemsOnMap--;
				Logger.add("TOTEMS -", totemsOnMap);
			}

			super.dispose();
		}

		override public function serialize():*
		{
			var data:Array = super.serialize();
			data.push([this.playerId, this.radius, this.aging, this.lifeTime]);

			return data;
		}

		override public function deserialize(data:*):void
		{
			var dataPointer:Array = data.pop();

			this.playerId = dataPointer[0];
			this.radius = dataPointer[1];
			this.aging = Boolean(dataPointer[2]);
			this.lifeTime = dataPointer[3];

			super.deserialize(data);
		}

		public function update(timeStep:Number = 0):void
		{
			if (!this.aging || this.disposed)
				return;

			this._lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		public function get playerId():int
		{
			return this._playerId;
		}

		public function set playerId(value:int):void
		{
			this._playerId = value;
		}

		public function resolve(globalPos:Point):Boolean
		{
			return globalToLocal(globalPos).length < this.radius;
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
			if (!this.gameInst)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}