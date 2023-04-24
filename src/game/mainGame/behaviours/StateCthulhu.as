package game.mainGame.behaviours
{
	import flash.display.MovieClip;

	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;

	public class StateCthulhu extends HeroState
	{
		protected var view:MovieClip = null;
		protected var joint:b2Joint = null;

		public function StateCthulhu(time:Number)
		{
			super(time);
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.isStoped = false;
				this.view.parent.removeChild(this.view);

				this.hero.body.GetWorld().DestroyJoint(this.joint);
				this.hero.body.SetFixedRotation(true);
				this.hero.hover = false;
				this.hero.resetMass = true;
			}
			else
			{
				this.view = value.isSquirrel ? new CthulhuTenatacleView() : new CthulhuTenatacleBigView();
				view.x = (value.isDragon || value.isSquirrel ? 0 : 15) * (value.heroView.direction ? -1 : 1);
				view.y = value.isSquirrel ? -Hero.Y_POSITION_COEF : (value.isDragon ? -6 : -32);
				view.scaleX = value.heroView.direction ? 1 : -1;

				value.heroView.addChild(view);
				fixHero(value);
				value.isStoped = true;
			}

			super.hero = value;
		}

		private function fixHero(hero:Hero):void
		{
			hero.body.SetFixedRotation(false);

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize(hero.body.GetWorld().GetGroundBody(), hero.body, hero.body.GetPosition());
			jointDef.enableLimit = true;
			jointDef.lowerAngle = 0;
			jointDef.upperAngle = 0;

			this.joint = hero.body.GetWorld().CreateJoint(jointDef);
			hero.hover = true;
		}
	}
}