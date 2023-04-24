package game.mainGame.entity.magic
{
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.simple.CollectionMirageElement;
	import game.mainGame.entity.simple.Element;
	import game.mainGame.entity.simple.InvisibleBody;
	import sensors.events.DetectHeroEvent;

	import utils.starling.StarlingAdapterMovie;

	public class EasterChicken extends InvisibleBody
	{
		static public const SPEED:int = 300 / Game.PIXELS_TO_METRE;
		static public const RADIUS:int = 50 / Game.PIXELS_TO_METRE;

		private var disposed:Boolean = false;
		private var currentPoint:int;
		private var viewDestroy:StarlingAdapterMovie;

		public var points:Array;

		public function EasterChicken():void
		{
			this.view = new StarlingAdapterMovie(new EasterChickenView);
           		this.view.loop = true;
            		this.view.play();
			addChildStarling(this.view);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.points, this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.points = data[1][0];
			this.playerId = data[1][1];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.currentPoint >= this.points.length)
			{
				destroy();
				return;
			}

			var point:b2Vec2 = new b2Vec2(this.points[this.currentPoint].x / Game.PIXELS_TO_METRE, this.points[this.currentPoint].y / Game.PIXELS_TO_METRE);
			point.Subtract(this.position);

			var distance:Number = point.Length();
			if (distance <= SPEED * timeStep)
				this.currentPoint++;
			var speed:Number = Math.min(SPEED * timeStep, distance);
			var x:Number = this.position.x + speed * point.x / distance;
			var y:Number = this.position.y + speed * point.y / distance;
			this.position = new b2Vec2(x, y);

			this.view.scaleX = point.x > 0 ? -1 : 1;

			if (this.playerId != Game.selfId || !this.gameInst || !this.gameInst.squirrels)
				return;
			var hero:Hero = this.gameInst.squirrels.get(this.playerId);
			if (!hero)
				return;

			for each (var element:Element in this.gameInst.map.elements)
			{
				if (element.sensor == null)
					continue;
				if (element is CollectionMirageElement)
				{
					element.sensor.dispatchEvent(new DetectHeroEvent(hero));
					continue;
				}
				point = element.position.Copy();
				point.Subtract(this.position);
				if (point.Length() > RADIUS)
					continue;
				element.sensor.dispatchEvent(new DetectHeroEvent(hero));
			}
		}

		private function destroy():void
		{
			if (this.disposed)
				return;
			this.disposed = true;

			this.view.visible = false;
			this.viewDestroy = new StarlingAdapterMovie(new EasterChickenDestroy());
            		this.viewDestroy.loop = false;
            		this.viewDestroy.play();
			this.viewDestroy.addEventListener(Event.COMPLETE, onChange);
			addChildStarling(this.viewDestroy);
		}

		private function onChange(e:Event):void
		{
			this.viewDestroy.removeEventListener(Event.COMPLETE, onChange);
			if (this.viewDestroy && this.viewDestroy.parentStarling)
				removeChildStarling(this.viewDestroy);

			this.viewDestroy = null;

			if (!this.gameInst)
				return;
			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}