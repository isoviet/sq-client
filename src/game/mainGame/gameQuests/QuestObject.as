package game.mainGame.gameQuests
{
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.IUpdate;
	import game.mainGame.entity.IGameObject;

	import interfaces.IDispose;

	public class QuestObject extends Sprite implements IGameObject, IUpdate, IDispose, IQuestObject
	{
		public var hero:Hero = null;
		public var activated:Boolean = false;
		protected var view:MovieClip = null;

		public function QuestObject(hero:Hero):void
		{
			this.hero = hero;
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{}

		public function build(world:b2World):void
		{}

		public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildAt(0);

			if (this.parent != null)
				this.parent.removeChild(this);

			this.hero = null;
			this.view = null;
		}

		public function update(timeStep:Number = 0):void
		{}
	}
}