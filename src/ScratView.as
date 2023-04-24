package
{
	import flash.display.BlendMode;
	import flash.utils.getDefinitionByName;

	import game.gameData.OutfitData;
	import loaders.HeroLoader;
	import wear.Clothing;

	import dragonBones.Armature;
	import dragonBones.animation.Animation;
	import dragonBones.animation.WorldClock;

	import starling.textures.TextureSmoothing;

	import utils.IControlAnimation;
	import utils.dragonBones.SmoothingUtil;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class ScratView extends StarlingAdapterSprite implements IControlAnimation
	{
		static private const ACORN:String = "acorn";

		private var _hasAcorn:Boolean = false;
		private var _state:int = -2;
		private var _isMan:Boolean = true;

		private var scratDeathAnimation:StarlingAdapterMovie = null;

		private var clothing:Clothing = null;
		private var heroSprite:StarlingAdapterSprite = new StarlingAdapterSprite();

		private var heartsView:StarlingAdapterMovie;

		public var armature:Armature;

		public function ScratView(isMan:Boolean = true):void
		{
			this._isMan = isMan;

			initViews();

			this.setState(Hero.STATE_STOPED);
		}

		public function remove():void
		{
			if (this.scratDeathAnimation)
				this.scratDeathAnimation.removeFromParent(true);

			this.scratDeathAnimation = null;

			if (this.heartsView)
				this.heartsView.removeFromParent(true);
			this.heartsView = null;

			if (this.clothing)
				this.clothing.remove();
			this.clothing = null;

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

			if (this.scratDeathAnimation)
			{
				this.scratDeathAnimation.stop();
				this.scratDeathAnimation.visible = false;
			}

			if (value == Hero.STATE_STOPED)
				return;

			switch (this._state)
			{
				case Hero.STATE_DEAD:
					initDeadView();
					this.scratDeathAnimation.gotoAndPlay(0);
					this.scratDeathAnimation.visible = true;
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

			this.armature.getBone(ACORN).displayController = value ? ACORN : null;

			if (!value)
				return;

			this.armature.animation.gotoAndPlay(ACORN, -1, -1, NaN, 0, ACORN, Animation.SAME_GROUP);
			this.armature.invalidUpdate();

			WorldClock.clock.advanceTime(-1);
		}

		public function setClothing(packagesIds:Array):void
		{
			var clothesIds:Array = [];
			for (var i:int = 0; i < packagesIds.length; i++)
				if (this._isMan ? OutfitData.isScratSkin(packagesIds[i]) : OutfitData.isScrattySkin(packagesIds[i]))
					clothesIds.push(packagesIds[i]);

			if (clothesIds.length == 0)
				return;

			this.clothing.setItems(clothesIds);

			updateSmoothingBones();
		}

		public function get usingClothes():Array
		{
			if (this.clothing == null)
				return [];

			return this.clothing.getClothesDressed();
		}

		private function initViews():void
		{
			this.armature = HeroLoader.getFactory().buildArmature(this._isMan ? HeroLoader.SCRAT : HeroLoader.SCRATTY);
			WorldClock.clock.add(this.armature);

			this.clothing = new Clothing(this.armature);

			this.heroSprite.addChildStarling(this.armature.display);
			addChildStarling(this.heroSprite);

			updateSmoothingBones();

			initHearts();
		}

		private function initDeadView():void
		{
			if (this.scratDeathAnimation)
				return;

			var className:Class = getDefinitionByName("HeroDead") as Class;
			this.scratDeathAnimation = new StarlingAdapterMovie(new className());
			this.scratDeathAnimation.x = 60;
			this.scratDeathAnimation.y = -150;
			this.scratDeathAnimation.blendMode = BlendMode.SCREEN;
			this.scratDeathAnimation.loop = false;
			this.scratDeathAnimation.stop();
			addChildStarling(this.scratDeathAnimation);
		}

		private function initHearts():void
		{
			this.heartsView = new StarlingAdapterMovie(new AcornShareView());
			this.heartsView.loop = true;
			this.heartsView.visible = false;
			this.heartsView.stop();

			addChildStarling(this.heartsView.getStarlingView());
		}

		private function updateSmoothingBones():void
		{
			SmoothingUtil.setSmoothing(this.armature, TextureSmoothing.TRILINEAR, ["Tail", "innerHead"]);
		}
	}
}