package game.mainGame.entity.simple
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.editor.decorations.Decoration;

	public class BubblesEmitter extends Decoration implements IUpdate
	{
		private var bubbleTime:int = 0;

		private var disposed:Boolean = false;
		private var world:b2World = null;

		public var bubbleDelay:int = 3 * 1000;
		public var bubbleSpeed:Number = -10;
		public var bubbleTouchLimit:int = 3;

		public function BubblesEmitter():void
		{
			super(BubbleEmitterImg);
		}

		override public function get rotation():Number
		{
			return super.rotation;
		}

		override public function set rotation(value:Number):void
		{
			if (value) {/*unused*/}

			super.rotation = 0;
		}

		override public function get angle():Number
		{
			return 0;
		}

		override public function set angle(value:Number):void
		{
			if (value) {/*unused*/}

			this.rotation = 0;
		}

		override public function serialize():*
		{
			var data:Array = super.serialize();
			data.push([this.bubbleTime, this.bubbleDelay, this.bubbleSpeed, this.bubbleTouchLimit]);
			return data;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			var dataPointer:Array = data.pop();

			this.bubbleTime = dataPointer[0];
			this.bubbleDelay = dataPointer[1];
			this.bubbleSpeed = dataPointer[2];
			this.bubbleTouchLimit = dataPointer[3];
		}

		override public function dispose():void
		{
			this.disposed = true;
			this.world = null;

			super.dispose();
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			this.world = world;
		}

		public function update(timeStep:Number = 0):void
		{
			if (this.disposed)
				return;

			this.bubbleTime += timeStep * 1000;

			if (this.bubbleTime < this.bubbleDelay)
				return;

			this.bubbleTime = 0;
			emitBubble();
		}

		private function emitBubble():void
		{
			if (!this.world || !(this.world.userData as SquirrelGame).squirrels.isSynchronizing)
				return;

			var bubble:BubbleBody = new BubbleBody();
			bubble.position = new b2Vec2(this.position.x, this.position.y - 7);
			bubble.velocity = this.bubbleSpeed;
			bubble.touchCount = this.bubbleTouchLimit;
			(this.world.userData as SquirrelGame).map.createObjectSync(bubble, true);
		}
	}
}