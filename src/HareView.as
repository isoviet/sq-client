package
{
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	import loaders.HeroLoader;
	import sounds.GameSounds;

	import dragonBones.Armature;
	import dragonBones.animation.Animation;
	import dragonBones.animation.WorldClock;

	import utils.IControlAnimation;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class HareView extends StarlingAdapterSprite implements IControlAnimation
	{
		static private const LAUGH_SOUNDS:Array = [
			"hare_laugh_long",
			"hare_laugh_loop",
			"hare_laugh_short",
			"hare_laugh1",
			"hare_laugh2",
			"hare_laugh3",
			"hare_laugh4"
		];

		static private const STOMP_SOUNDS:Array = [
			"hare_stomp_short0",
			"hare_stomp_short1",
			"hare_stomp_short2",
			"hare_stomp_short3"
		];

		static private const ACORN:String = "acorn";

		static private const HEAD_BONE:String = "Head";

		static public const STATE_STOMP:String = "stomp";
		static public const STATE_LAUGH:String = "laugh";
		static public const STATE_CHEW:String = "chewing";
		static public const STATE_SPIT:String = "spittle";
		static public const STATE_ROCK_RUN:String = "rockRun";
		static public const STATE_ROCK_STAND:String = "rockStand";

		static public const SOUND_PROBABILITY:Number = 0.3;

		private var _rock:Boolean = false;
		private var _stomp:Boolean = false;
		private var _chew:Boolean = false;
		private var _spit:Boolean = false;
		private var _hasAcorn:Boolean = false;
		private var _laugh:Boolean = false;
		private var _state:int = -2;

		private var walkSound:SoundChannel = null;
		private var stompSound:SoundChannel = null;
		private var laughSound:SoundChannel = null;

		private var hareDeathAnimation:StarlingAdapterMovie = null;

		private var armature:Armature = null;

		private var heroSprite:StarlingAdapterSprite = new StarlingAdapterSprite();

		public function HareView():void
		{
			initViews();

			this.setState(Hero.STATE_STOPED);
		}

		public function remove():void
		{
			if (this.hareDeathAnimation)
				this.hareDeathAnimation.removeFromParent();
			this.hareDeathAnimation = null;

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

		public function set walkSpeed(value:Number):void
		{
			this.armature.animation.timeScale += value;
		}

		public function get walkSpeed():Number
		{
			return 0;
		}

		public function setState(value:int, frame:int = 0):void
		{
			if (this._state == value && value == Hero.STATE_STOPED)
				return;

			this._state = value;

			if (this.hareDeathAnimation)
			{
				this.hareDeathAnimation.stop();
				this.hareDeathAnimation.visible = false;
			}

			if (state == Hero.STATE_RUN)
				playWalk();
			else
				stopWalk();

			if (value == Hero.STATE_STOPED)
				return;

			if (this.rock && this._state != Hero.STATE_DEAD)
			{
				stateRock();
				return;
			}

			switch (this._state)
			{
				case Hero.STATE_DEAD:
					initDeathAnimation();
					this.hareDeathAnimation.gotoAndPlay(0);
					this.hareDeathAnimation.visible = true;
					this.heroSprite.visible = false;
					break;
				default:
					this._laugh = false;
					this.heroSprite.visible = true;
					this.armature.animation.gotoAndPlay(Hero.DB_STATES[this.state]);
			}
		}

		public function get rock():Boolean
		{
			return this._rock;
		}

		public function set rock(value:Boolean):void
		{
			this._rock = value;
			this._laugh = false;

			this.setState(this.state);

			if (!value)
				return;

			GameSounds.playUnrepeatable((Math.random() > 0.5) ? "hare_rock_shape" : "hare_rock", SOUND_PROBABILITY);
		}

		public function get stomp():Boolean
		{
			return this._stomp;
		}

		public function set stomp(value:Boolean):void
		{
			this._stomp = value;

			this.armature.animation.gotoAndPlay(value ? STATE_STOMP : Hero.DB_STAND);

			if (value)
				playStomp();
			else
				stopStomp();
		}

		public function get chew():Boolean
		{
			return this._chew;
		}

		public function set chew(value:Boolean):void
		{
			this._chew = value;

			if (value)
				this.armature.getBone(HEAD_BONE).childArmature.animation.gotoAndPlay(STATE_CHEW);
			else
				this.armature.animation.gotoAndPlay(Hero.DB_STAND);
		}

		public function get spit():Boolean
		{
			return this._spit;
		}

		public function set spit(value:Boolean):void
		{
			this._spit = value;

			this.armature.animation.gotoAndPlay(value ? STATE_SPIT : Hero.DB_STAND);
		}

		public function get hasAcorn():Boolean
		{
			return this._hasAcorn;
		}

		public function set hasAcorn(value:Boolean):void
		{
			this._hasAcorn = value;

			this.armature.getBone(ACORN).displayController = value ? ACORN : null;

			if (!value)
				return;

			this.armature.animation.gotoAndPlay(ACORN, -1, -1, NaN, 0, ACORN, Animation.SAME_GROUP);
			this.armature.invalidUpdate();

			WorldClock.clock.advanceTime(-1);
		}

		public function set laugh(value:Boolean):void
		{
			this._laugh = value;

			this.armature.animation.gotoAndPlay(value ? STATE_LAUGH : Hero.DB_STAND);

			if (value)
				playLaugh();
			else
				stopLaugh();
		}

		private function stateRock():void
		{
			if (this.state == Hero.STATE_RUN)
				this.armature.animation.gotoAndPlay(STATE_ROCK_RUN);
			else
				this.armature.animation.gotoAndPlay(STATE_ROCK_STAND);

			this.heroSprite.visible = true;
		}

		private function playStomp(e:Event = null):void
		{
			stopStomp();

			if (!this.parentStarling || !this.parentStarling.visible || !GameSounds.on)
				return;

			this.stompSound = GameSounds.play(STOMP_SOUNDS[int(Math.random() * STOMP_SOUNDS.length)]);
			if (this.stompSound == null)
			{
				setTimeout(playStomp, 100);
				return;
			}

			this.stompSound.addEventListener(Event.SOUND_COMPLETE, playStomp, false, 0, true);
		}

		private function stopStomp():void
		{
			if (this.stompSound == null)
				return;

			GameSounds.stop(this.stompSound);

			this.stompSound.removeEventListener(Event.SOUND_COMPLETE, playStomp, false);
			this.stompSound = null;
		}

		private function playLaugh(e:Event = null):void
		{
			stopLaugh();

			if (!this.parentStarling || !this.parentStarling.visible || !GameSounds.on)
				return;

			this.laughSound = GameSounds.playUnrepeatable(LAUGH_SOUNDS[int(Math.random() * LAUGH_SOUNDS.length)]);

			if (this.laughSound == null)
			{
				setTimeout(playLaugh, 1000);
				return;
			}

			this.laughSound.addEventListener(Event.SOUND_COMPLETE, playLaugh, false, 0, true);
		}

		private function stopLaugh():void
		{
			if (this.laughSound == null)
				return;

			GameSounds.stop(this.laughSound);

			this.laughSound.removeEventListener(Event.SOUND_COMPLETE, playLaugh, false);
			this.laughSound = null;
		}

		private function playWalk(e:Event = null):void
		{
			stopWalk();

			if (!this.parentStarling || !this.parentStarling.visible || !GameSounds.on)
				return;

			if (this.walkSpeed == 1)
				this.walkSound = GameSounds.play("hare_step");
			else
				this.walkSound = GameSounds.play("hare_run");

			if (this.walkSound == null)
			{
				setTimeout(playWalk, 1000);
				return;
			}

			this.walkSound.addEventListener(Event.SOUND_COMPLETE, playWalk, false, 0, true);
		}

		private function stopWalk():void
		{
			if (this.walkSound == null)
				return;

			GameSounds.stop(this.walkSound);

			this.walkSound.removeEventListener(Event.SOUND_COMPLETE, playWalk, false);
			this.walkSound = null;
		}

		private function initViews():void
		{
			this.armature = HeroLoader.getFactory().buildArmature(HeroLoader.HARE);
			WorldClock.clock.add(this.armature);

			this.heroSprite.addChildStarling(this.armature.display);
			addChildStarling(this.heroSprite);
		}

		private function initDeathAnimation():void
		{
			if (this.hareDeathAnimation)
				return;

			var className:Class = getDefinitionByName("HareDeath") as Class;
			this.hareDeathAnimation = new StarlingAdapterMovie(new className());
			this.hareDeathAnimation.y = -120;
			this.hareDeathAnimation.blendMode = BlendMode.SCREEN;
			this.hareDeathAnimation.loop = false;
			this.hareDeathAnimation.stop();
			addChildStarling(this.hareDeathAnimation);
		}
	}
}