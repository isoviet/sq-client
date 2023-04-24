package game.mainGame.entity.joints
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;

	import game.mainGame.entity.view.GumView;
	import screens.ScreenGame;

	public class JointGum extends JointToSquirrel
	{
		public var lifeTimeEnabled:Boolean = true;
		public var lifeTime:Number = 30;

		public function JointGum():void
		{
			this.lifeTime = (ScreenGame.mode == Locations.HARD_MODE) ? 10 : 30;

			this.jointView = new GumView();

			super();
		}

		override public function serialize():*
		{
			var result:Array = [];

			if (this.broken)
				return result;

			result.push([this.position.x, this.position.y]);
			result.push([this.anchor0.position.x, this.anchor0.position.y]);
			result.push([this.anchor1.position.x, this.anchor1.position.y]);
			result.push([this.frequency, this.damping]);
			result.push([this.lifeTime, this.lifeTimeEnabled]);

			if (this.jointDef != null)
				result.push([this.hero1 ? this.hero1.id : -1, this.hero0 ? this.hero0.id : -1, broken]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			if (data.length == 0)
			{
				this.broken = true;
				return;
			}

			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.anchor0.position = new b2Vec2(data[1][0], data[1][1]);
			this.anchor1.position = new b2Vec2(data[2][0], data[2][1]);
			this.frequency = data[3][0];
			this.damping = data[3][1];

			this.lifeTime = data[4][0];
			this.lifeTimeEnabled = Boolean(data[4][1]);

			if (!(4 in data))
				return;

			this.jointDef = new b2DistanceJointDef();
			this.body0Id = data[4][0];
			this.body1Id = data[4][1];
		}

		override public function update(timeStep:Number = 0):void
		{
			if (this.broken)
			{
				this.visible = false;
				return;
			}
			this.rotation = 0;

			if (this.lifeTimeEnabled)
			{
				this.lifeTime -= timeStep;

				this.jointView.alpha = b2Math.Clamp(this.lifeTime, 0, 1);

				if (this.lifeTime <= 0)
					this.onBreak();
			}
		}

		override protected function listenBreak():void
		{
			this.hero0.addEventListener(Hero.EVENT_BREAK_MAGIC_JOINT, onBreak, false, 0, true);
			this.hero1.addEventListener(Hero.EVENT_BREAK_MAGIC_JOINT, onBreak, false, 0, true);
		}
	}
}