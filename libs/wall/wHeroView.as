package
{
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import landing.game.ShamanAnimation;
	import landing.game.SquirrelAnimationFactory;

	public class wHeroView extends Sprite
	{
		static public const SHAMAN_CLOTHES:Array = [wClothes.SHAMAN];

		private var lastState:* = null;

		private var acorn:* = null;
		private var isRunning:* = null;
		private var inAir:* = null;
		private var shaman:* = null;
		private var casting:* = null;
		private var isDead:* = null;
		private var runDirection:* = null;

		private var squirrelFormat:TextFormat = null;
		private var squirrelAlpha:Number = 1;
		private var squirrelFilters:Array = [];

		private var shamanFormat:TextFormat = null;
		private var shamanAlpha:Number = 1;
		private var shamanFilters:Array = [];

		private var heroSprite:Sprite = new Sprite();

		private var viewStand:Sprite = new Sprite();
		private var viewRun:Sprite = new Sprite();
		private var viewShaman:Sprite = new Sprite();

		private var viewDeath:SquirrelAnimationFactory = null;
		private var viewStandWithAcorn:SquirrelAnimationFactory = null;
		private var viewRunWithAcorn:SquirrelAnimationFactory = null;
		private var viewStandWithoutAcorn:SquirrelAnimationFactory = null;
		private var viewRunWithoutAcorn:SquirrelAnimationFactory = null;
		private var viewShamanWithAcorn:ShamanAnimation = null;
		private var viewShamanWithoutAcorn:ShamanAnimation = null;

		private var clothing:wClothing = null;

		public var circle:Circle = new Circle();

		public function wHeroView():void
		{
			this.viewShamanWithoutAcorn = new ShamanAnimation(false);
			this.viewShamanWithAcorn = new ShamanAnimation(true);
			this.viewStandWithoutAcorn = new SquirrelAnimationFactory(new HeroStand);
			this.viewRunWithoutAcorn = new SquirrelAnimationFactory(new HeroRun, SquirrelAnimationFactory.TYPE_RUN);
			this.viewStandWithAcorn = new SquirrelAnimationFactory(new HeroStandAcorn);
			this.viewRunWithAcorn = new SquirrelAnimationFactory(new HeroRunAcorn, SquirrelAnimationFactory.TYPE_RUN);

			this.viewDeath = new SquirrelAnimationFactory(new HeroDead, SquirrelAnimationFactory.TYPE_DEATH);
			this.viewDeath.x = 60;
			this.viewDeath.y = -150;
			this.viewDeath.blendMode = BlendMode.SCREEN;
			this.heroSprite.addChild(this.viewDeath);

			this.viewStand.addChild(this.viewStandWithoutAcorn)
			this.viewStand.addChild(this.viewStandWithAcorn)
			this.heroSprite.addChild(this.viewStand);

			this.viewRun.addChild(this.viewRunWithoutAcorn);
			this.viewRun.addChild(this.viewRunWithAcorn);
			this.heroSprite.addChild(this.viewRun);

			this.viewShaman.addChild(this.viewShamanWithoutAcorn);
			this.viewShaman.addChild(this.viewShamanWithAcorn);
			this.heroSprite.addChild(this.viewShaman);

			addChild(this.heroSprite);

			this.viewStandWithAcorn.visible = this.viewRunWithAcorn.visible = this.viewShamanWithAcorn.visible = false;
			this.viewStandWithoutAcorn.visible = this.viewRunWithoutAcorn.visible = this.viewShamanWithoutAcorn.visible = true;

			this.circle.visible = false;
			this.circle.x = -111;
			this.circle.y = -134;
			this.circle.stop();
			addChild(this.circle);
		}

		public function set castProgress(value:int):void
		{
			this.circle.gotoAndStop(int(value * this.circle.totalFrames / 100));
		}

		public function get castProgress():int
		{
			return int(circle.currentFrame / this.circle.totalFrames * 100);
		}

		public function get isCasting():Boolean
		{
			return this.casting;
		}

		public function set isCasting(value:Boolean):void
		{
			if (this.casting == value)
				return;
			this.casting = value;

			this.castProgress = (value ? this.castProgress : 0);

			this.viewShamanWithAcorn.toggleAnimationCasting(this.shaman);
			this.viewShamanWithoutAcorn.toggleAnimationCasting(this.shaman);

			update();
		}

		public function set dead(value:Boolean):void
		{
			if (this.isDead == value)
				return;
			this.isDead = value;

			update();
		}

		public function get dead():Boolean
		{
			return this.isDead;
		}

		public function get hasAcorn():Boolean
		{
			return this.acorn;
		}

		public function set hasAcorn(value:Boolean):void
		{
			if (this.acorn == value)
				return;
			this.acorn = value;

			this.viewStandWithAcorn.visible = this.viewRunWithAcorn.visible = this.viewShamanWithAcorn.visible = value;
			this.viewStandWithoutAcorn.visible = this.viewRunWithoutAcorn.visible = this.viewShamanWithoutAcorn.visible = !value;

			onStateChanged();
			update();
			updateCloth();
		}

		public function setClothing(itemIds:Array):void
		{
			if (this.isShaman && itemIds != SHAMAN_CLOTHES)
				return;

			if (this.clothing != null)
				this.heroSprite.removeChild(this.clothing);

			this.clothing = new wClothing(wClothing.RASTR_IMAGE);
			this.clothing.setItems(itemIds);
			updateCloth();

			this.heroSprite.addChild(this.clothing);
		}

		public function removeClothing():void
		{
			if (this.clothing == null)
				return;

			this.heroSprite.removeChild(this.clothing);
			this.clothing = null;
		}

		public function get isShaman():Boolean
		{
			return this.shaman;
		}

		public function set isShaman(value:Boolean):void
		{
			if (this.shaman == value)
				return;
			this.shaman = value;

			if (value)
			{
				setClothing(SHAMAN_CLOTHES);
			}

			update();
		}

		public function get running():Boolean
		{
			return this.isRunning;
		}

		public function set running(value:Boolean):void
		{
			if (isRunning == value)
				return;
			this.isRunning = value;

			update();
		}

		public function get direction():Boolean
		{
			return this.runDirection;
		}

		public function set direction(value:Boolean):void
		{
			if (this.runDirection == value)
				return;
			this.runDirection = value;

			this.heroSprite.scaleX = (value ? 1 : -1) * Math.abs(this.heroSprite.scaleX);
		}

		public function get fly():Boolean
		{
			return this.inAir;
		}

		public function set fly(value:Boolean):void
		{
			if (this.inAir == value)
				return;
			this.inAir = value;

			update();
		}

		public function update():void
		{
			this.viewDeath.visible = this.dead;
			this.viewShaman.visible = this.casting && !this.dead;
			this.viewRun.visible = (this.running || this.fly) && !this.casting && !this.dead;
			this.viewStand.visible = !this.running && !this.fly && !this.casting && !this.dead;

			if (this.lastState != this.state)
				onStateChanged();
			updateCloth();
		}

		private function onStateChanged():void
		{
			stopAllAnimation();

			switch (this.state)
			{
				case wHero.STATE_REST:
					this.currentAnimation.animation.gotoAndPlay(0);
					break;
				case wHero.STATE_RUN:
					this.currentAnimation.animation.gotoAndPlay(0);
					break;
				case wHero.STATE_JUMP:
					this.currentAnimation.animation.gotoAndStop(5);
					break;
				case wHero.STATE_SHAMAN:
					this.currentAnimation.animation.play();
					break;
				case wHero.STATE_DEAD:
					this.currentAnimation.animation.gotoAndPlay(1);
					break;
			}

			this.lastState = this.state;
		}

		private function updateCloth():void
		{
			if (this.clothing != null)
				this.clothing.setState(this.state, this.frame);
		}

		private function get state():int
		{
			if (this.dead)
				return wHero.STATE_DEAD;
			if (this.casting)
				return wHero.STATE_SHAMAN;
			if (this.fly)
				return wHero.STATE_JUMP;
			if (this.running)
				return wHero.STATE_RUN;
			return wHero.STATE_REST;
		}

		private function stopAllAnimation():void
		{
			this.viewDeath.animation.stop();

			this.viewStandWithoutAcorn.animation.stop();
			this.viewStandWithAcorn.animation.stop();

			this.viewRunWithoutAcorn.animation.stop();
			this.viewRunWithAcorn.animation.stop();

			this.viewShamanWithoutAcorn.animation.stop();
			this.viewShamanWithAcorn.animation.stop();
		}

		private function get currentAnimation():SquirrelAnimationFactory
		{
			if (this.viewStand.visible)
				return this.hasAcorn ? this.viewStandWithAcorn : this.viewStandWithoutAcorn;
			if (this.viewRun.visible)
				return this.hasAcorn ? this.viewRunWithAcorn : this.viewRunWithoutAcorn;
			if (this.viewStand.visible)
				return this.hasAcorn ? this.viewStandWithAcorn : this.viewStandWithoutAcorn;
			if (this.viewShaman.visible)
				return this.hasAcorn ? this.viewShamanWithAcorn : this.viewShamanWithoutAcorn;
			return this.viewDeath;
		}

		private function get frame():int
		{
			return this.currentAnimation.animation.currentFrame;
		}
	}
}