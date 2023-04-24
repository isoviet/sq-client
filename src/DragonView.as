package
{
	import flash.display.BlendMode;
	import flash.utils.getDefinitionByName;

	import loaders.HeroLoader;

	import dragonBones.Armature;
	import dragonBones.animation.Animation;
	import dragonBones.animation.WorldClock;

	import utils.IControlAnimation;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class DragonView extends StarlingAdapterSprite implements IControlAnimation
	{
		static private const STATE_FIRE:String = "fire";

		static private const HEAD_BONE:String = "Head";

		static private const ACORN:String = "acorn";

		private var _hasAcorn:Boolean = false;
		private var _state:int = -2;

		private var _fire:Boolean = false;
		private var armature:Armature = null;

		private var heroSprite:StarlingAdapterSprite = new StarlingAdapterSprite();

		private var dragonDeathAnimation:StarlingAdapterMovie = null;

		private var _isDead: Boolean = false;
		private var isRemoved:Boolean = false;

		public function DragonView():void
		{
			initViews();

			this.setState(Hero.STATE_STOPED);
			_isDead = false;
		}

		public function remove():void
		{
			this.isRemoved = true;

			if (this.dragonDeathAnimation)
				this.dragonDeathAnimation.removeFromParent(true);

			this.dragonDeathAnimation = null;

			WorldClock.clock.remove(this.armature);
			this.armature.dispose();
			this.armature = null;

			if (this.containsStarling(this.heroSprite))
				removeChildStarling(this.heroSprite, false);

			this.heroSprite = null;
		}

		public function get state():int
		{
			return this._state;
		}

		public function setState(value:int, frame:int = 0):void
		{
			if (this._state == value && value == Hero.STATE_STOPED)
				return;

			this._state = value;

			if (this.dragonDeathAnimation)
			{
				this.dragonDeathAnimation.stop();
				this.dragonDeathAnimation.visible = false;
			}

			if (value == Hero.STATE_STOPED)
				return;

			if (_isDead)
			{
				_isDead = false;
				return;
			}

			switch (this._state)
			{
				case Hero.STATE_DEAD:
					_isDead = true;
					initDeathAnimation();
					this.dragonDeathAnimation.gotoAndPlay(0);
					this.dragonDeathAnimation.visible = true;
					this.heroSprite.visible = false;
					break;
				default:
					this.heroSprite.visible = true;
					this.armature.animation.gotoAndPlay(Hero.DB_STATES[this.state]);
			}
		}

		public function get hasAcorn():Boolean
		{
			return this._hasAcorn;
		}

		public function set hasAcorn(value:Boolean):void
		{
			this._hasAcorn = value;

			this.armature.getBone(HEAD_BONE).childArmature.getBone(ACORN).displayController = value ? ACORN : null;

			if (!value)
				return;

			this.armature.getBone(HEAD_BONE).childArmature.animation.gotoAndPlay(ACORN, -1, -1, NaN, 0, ACORN, Animation.SAME_GROUP);
			this.armature.invalidUpdate();

			WorldClock.clock.advanceTime(-1);
		}

		public function get fire():Boolean
		{
			return this._fire;
		}

		public function set fire(value:Boolean):void
		{
			this._fire = value;

			if (value)
				this.armature.getBone(HEAD_BONE).childArmature.animation.gotoAndPlay(STATE_FIRE);
			else
				this.armature.getBone(HEAD_BONE).childArmature.animation.gotoAndPlay(Hero.DB_STAND);
		}

		private function initViews():void
		{
			this.armature = HeroLoader.getFactory().buildArmature(HeroLoader.DRAGON);
			WorldClock.clock.add(this.armature);

			this.heroSprite.addChildStarling(this.armature.display);
			addChildStarling(this.heroSprite);
		}

		private function initDeathAnimation():void
		{
			if (this.dragonDeathAnimation)
				return;

			var className:Class = getDefinitionByName("DragonDead") as Class;
			this.dragonDeathAnimation = new StarlingAdapterMovie(new className());
			this.dragonDeathAnimation.x = 60;
			this.dragonDeathAnimation.y = -150;
			this.dragonDeathAnimation.blendMode = BlendMode.SCREEN;
			this.dragonDeathAnimation.loop = false;
			this.dragonDeathAnimation.stop();
			addChildStarling(this.dragonDeathAnimation);
		}
	}
}