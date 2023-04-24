package landing.game.mainGame.entity.simple
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import flash.display.DisplayObject;

	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.entity.simple.GameBody;

	public class InvisibleBody extends GameBody
	{
		public function InvisibleBody(imageClass:Class = null):void
		{
			var view:DisplayObject = new imageClass() as DisplayObject;
			view.x = -view.width;
			view.y = -view.height;
			addChild(view);
			this.fixed = true;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(new b2BodyDef(false, false, b2Body.b2_dynamicBody);
			this.body.SetUserData(this);
			super.build(world);
		}

		override public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildAt(0);

			if (this.parent != null)
				this.parent.removeChild(this);
		}
	}
}