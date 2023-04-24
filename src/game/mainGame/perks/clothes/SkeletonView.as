package game.mainGame.perks.clothes
{
	import loaders.HeroLoader;

	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;

	import utils.IControlAnimation;
	import utils.starling.StarlingAdapterSprite;

	public class SkeletonView extends StarlingAdapterSprite implements IControlAnimation
	{
		private var state:int = -2;

		public var armature:Armature;

		public var notChangeState:Boolean = false;

		public function SkeletonView(skeletonName:String)
		{
			super();

			this.armature = HeroLoader.getFactory().buildArmature(skeletonName);
			addChildStarling(this.armature.display);

			WorldClock.clock.add(this.armature);
		}

		override public function removeFromParent(dispose:Boolean = true):void
		{
			WorldClock.clock.remove(this.armature);
			removeChildStarling(this.armature.display);

			this.armature.dispose();
			this.armature = null;

			super.removeFromParent(dispose);
		}

		public function setState(value:int, frame:int = 0):void
		{
			if (this.notChangeState || (this.state == value && value == Hero.STATE_STOPED))
				return;

			this.state = value;

			if (!this.armature)
				return;

			switch (this.state)
			{
				case Hero.STATE_STOPED:
					this.armature.animation.stop();
					break;
				case Hero.STATE_RUN:
				case Hero.STATE_REST:
				case Hero.STATE_JUMP:
					this.armature.animation.gotoAndPlay(Hero.DB_STATES[this.state]);
					break;
			}
		}
	}
}