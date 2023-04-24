package game.mainGame.entity.simple
{
	import flash.display.Shape;

	import game.mainGame.entity.IGameObject;

	import utils.starling.StarlingAdapterSprite;

	public class BindPoint extends StarlingAdapterSprite
	{
		private var wayDebugSprite: StarlingAdapterSprite = new StarlingAdapterSprite();

		private var starlingShapeWay: StarlingAdapterSprite = new StarlingAdapterSprite();

		protected var waySprite:StarlingAdapterSprite;

		protected var bodyPoints:Vector.<IGameObject> = new Vector.<IGameObject>();
		public var bindPoints:Vector.<IGameObject> = new Vector.<IGameObject>();

		protected var debugDraw:Boolean = false;

		public function BindPoint():void
		{
			this.waySprite = new StarlingAdapterSprite();

			addChildStarling(wayDebugSprite);
			addChildStarling(this.waySprite);
		}

		override public function set alpha(value: Number): void
		{
			if (this.touchable == true) {
				if (value < 1)
				{
					this.touchable = false;
				}
			}
			super.alpha = value;
		}

		public function bindWith(points:Vector.<IGameObject>):void
		{
			var vector:Vector.<IGameObject>;

			for each (var point:IGameObject in points)
			{
				vector = (point is GameBody ? this.bodyPoints : this.bindPoints);

				var index:int = vector.indexOf(point);

				if (index == -1 && point)
					vector.push(point);
				else
					unbind(point as BindPoint);
			}

			updateWay();
		}

		public function unbind(point:BindPoint):void
		{
			var vector:Vector.<IGameObject> = (point is GameBody ? this.bodyPoints : this.bindPoints);

			var index:int = vector.indexOf(point as IGameObject);

			if (index == -1)
				return;

			vector.splice(index, 1);

			updateWay();
		}

		public function removeWays():void
		{
			for each (var point:IGameObject in this.bindPoints.concat(this.bodyPoints))
				if (point != null) (point as BindPoint).unbind(this);

			this.bindPoints = new Vector.<IGameObject>();
			this.bodyPoints = new Vector.<IGameObject>();
		}

		public function updateWay():void
		{
			var coordX:int = this.x;
			var coordY:int = this.y;
			var shapeWay: Shape = new Shape();

			while (wayDebugSprite.numChildren > 0)
				wayDebugSprite.removeChildStarlingAt(0);

			shapeWay.graphics.lineStyle(2, 0xFFFFFF);

			wayDebugSprite.rotation = -this.rotation;

			for each (var point:IGameObject in this.bindPoints.concat(this.bodyPoints))
			{
				if (point != null)
				{
					var pointX:int = (point as StarlingAdapterSprite).x - coordX;
					var pointY:int = (point as StarlingAdapterSprite).y - coordY;
					shapeWay.graphics.moveTo(0, 0);
					shapeWay.graphics.lineTo(pointX, pointY);
				}
			}

			if (!this.debugDraw)
				return;

			starlingShapeWay.removeFromParent();
			starlingShapeWay = new StarlingAdapterSprite(shapeWay);

			wayDebugSprite.addChildStarling(starlingShapeWay);
		}

		protected function updateWays():void
		{
			if (!this.debugDraw)
				return;

			updateWay();

			for each (var point:IGameObject in this.bindPoints.concat(this.bodyPoints))
				if (point != null) (point as BindPoint).updateWay();
		}
	}
}