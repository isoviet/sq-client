package game.mainGame.entity.joints
{
	import flash.filters.ColorMatrixFilter;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;

	import game.mainGame.entity.view.RopeToSquirrelView;

	public class JointRopeToSquirrel extends JointToSquirrel
	{
		static private const COLOR_FILTER:Array = [new ColorMatrixFilter([0, 1, 0, 0, 0,
					0, 0, 1, 0, 0,
					1, 0, 0, 0, 0,
					0, 0, 0, 1, 0]),
					new ColorMatrixFilter([3, -1, 0, 0, 0,
					-1, 1, 0, 0, 0,
					0, -1, 3, 0, 0,
					0, 0, 0, 1, 0])
		];
		public function JointRopeToSquirrel(isSelf:Boolean = false):void
		{
			this.jointView = new RopeToSquirrelView();

			super();

			if (!isSelf)
				return;

			this.jointView.filters = COLOR_FILTER;
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

			if (!(4 in data))
				return;

			this.jointDef = new b2DistanceJointDef();
			this.body0Id = data[4][0];
			this.body1Id = data[4][1];
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			if (this.broken)
			{
				this.visible = false;
				return;
			}
			this.rotation = 0;
		}

		override protected function listenBreak():void
		{
			this.hero0.addEventListener(Hero.EVENT_BREAK_ROPE, onBreak, false, 0, true);
			this.hero1.addEventListener(Hero.EVENT_BREAK_ROPE, onBreak, false, 0, true);
		}
	}
}