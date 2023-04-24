package
{
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;

	import game.BaseCollectionHeroAnimation;
	import game.CollectionHeroAnimation;
	import game.EnergyKitAnimation;
	import game.ExplosionAnimation;
	import game.ExplosionAnimationPermanent;
	import game.gameData.OutfitData;
	import game.mainGame.gameDesertNet.MirageAnimation;
	import loaders.HeroLoader;
	import wear.BonesData;
	import wear.Clothing;

	import com.api.Player;

	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;
	import dragonBones.animation.WorldClock;
	import dragonBones.events.FrameEvent;

	import utils.Animation;
	import utils.IControlAnimation;
	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class HeroView extends StarlingAdapterSprite
	{
		static public const HERO_TOP:int = -60;

		static private const DRAGON_TOP:int = -65;
		static private const SCRAT_TOP:int = -70;
		static private const HARE_TOP:int = -80;
		static private const VENDIGO_TOP:int = -80;
		static private const LEOPARD_TOP:int = -80;
		static private const FLIGHT_TOP:int = -80;

		static public const DEFAULT:int = 0;
		static public const DREAM_CATCHERS:int = 1;
		static public const FLOWER:int = 2;

		static public const ACORN:String = "acorn";
		static public const BELT:String = "belt";

		static public const DB_FIRE:String = "fire";

		static private const HEARTS_EVENT:String = "hearts";

		private var lastState:* = null;

		private var nut:Boolean = false;
		private var isRunning:* = null;
		private var inAir:* = null;
		private var inEmotion:* = null;
		private var _shaman:* = null;
		private var casting:* = null;
		private var isDead:* = null;
		private var runDirection:* = null;
		private var emotionChanged:* = null;
		private var hare:* = null;
		private var scrat:* = null;
		private var dragon:* = null;
		private var isDeathClothing:Boolean = false;
		private var _allowCharacter:Boolean = true;

		public var messageSprite:HeroMessage = null;
		private var emotionSprite:HeroSmile = null;

		private var _cheaterPointer: StarlingAdapterSprite = null;
		private var heroSprite:StarlingAdapterSprite = new StarlingAdapterSprite();
		private var hareSprite:StarlingAdapterSprite = new StarlingAdapterSprite();
		private var scratSprite:StarlingAdapterSprite = new StarlingAdapterSprite();
		private var dragonSprite:StarlingAdapterSprite = new StarlingAdapterSprite();

		private var viewDeath:StarlingAdapterMovie = null;

		private var needHeroScaleX:Boolean = true;

		private var viewPerkAnimation:ExplosionAnimation = null;
		private var viewPerkAnimationPermanent:ExplosionAnimationPermanent = null;
		private var viewCollectionAnimation:CollectionHeroAnimation = null;
		private var viewEnergyKitAnimation:EnergyKitAnimation = null;
		private var mirageAnimation:MirageAnimation = null;

		private var clothing:Clothing = null;

		private var nameSprite:HeroName = null;
		private var player:Player = null;
		private var emotionState:int = 0;
		private var gum:MovieClip = null;
		private var curseView:DisplayObject = null;

		private var _team:int = Hero.TEAM_NONE;
		private var _onCurse:Boolean = false;

		private var passiveAuraCount:int = 0;
		private var _scale:Number = 1;

		private var bubble:StarlingAdapterSprite = null;

		private var heartsView:* = null;
		private var tearsView:StarlingAdapterSprite = new StarlingAdapterSprite();

		private var tears:Object = {};

		public var hareView:HareView = null;
		public var scratView:ScratView = null;
		public var dragonView:DragonView = null;
		public var viewAlternative:Sprite = null;

		public var circle:StarlingAdapterMovie = new StarlingAdapterMovie(new Circle());
		public var circleDefSize:Number = circle.width;

		public var aura:MovieClip = null;
		public var activeAura:StarlingAdapterMovie = null;
		public var passiveAura:Animation = null;

		public var animationOffset:int = 10;

		public var typeShaman:int = 0;

		public var armature:Armature;

		public function HeroView(playerId:int):void
		{
			super();

			this.mouseChildren = false;
			this.mouseEnabled = false;
			this.player = Game.getPlayer(playerId);

			this.armature = HeroLoader.getFactory().buildArmature(HeroLoader.SQUIRREL);
			this.armature.addEventListener(FrameEvent.MOVEMENT_FRAME_EVENT, onFrameEvent);
			WorldClock.clock.add(this.armature);

			this.clothing = new Clothing(this.armature);
			this.heroSprite.addChildStarling(this.armature.display);

			updateSmoothingBones();

			this.viewPerkAnimation = new ExplosionAnimation();
			this.viewPerkAnimation.x = -30;
			this.viewPerkAnimation.y = -45;

			this.viewPerkAnimationPermanent = new ExplosionAnimationPermanent();
			this.viewPerkAnimationPermanent.x = -30;
			this.viewPerkAnimationPermanent.y = -45;

			this.viewCollectionAnimation = new CollectionHeroAnimation();
			this.viewCollectionAnimation.x = -30;
			this.viewCollectionAnimation.y = -45;

			this.viewEnergyKitAnimation = new EnergyKitAnimation();
			this.viewEnergyKitAnimation.y = -30;

			this.mirageAnimation = new MirageAnimation();
			this.mirageAnimation.x = -10;

			addChild(this.viewPerkAnimation);
			addChildStarling(this.viewCollectionAnimation);

			addChildStarling(this.heroSprite);
			addChildStarling(this.scratSprite);
			addChildStarling(this.hareSprite);
			addChildStarling(this.dragonSprite);

			this.nameSprite = new HeroName(playerId);
			this.nameSprite.y = this.topCoords - 5;
			addChildStarling(this.nameSprite);
			this.messageSprite = new HeroMessage();
			addChild(this.messageSprite);

			this.emotionSprite = new HeroSmile();
			this.emotionSprite.x = -17;
			this.emotionSprite.visible = false;
			addChild(this.emotionSprite);

			this.circle.touchable = false;
			this.circle.visible = false;
			this.circle.stop();

			initEmotion();

			updateTopOffset();
		}

		override public function set filters(value:Array):void
		{
			super.filters = value;

			//this.heroSprite.filters = value;
			//this.hareSprite.filters = this.scratSprite.filters = this.dragonSprite.filters = value;
		}

		override public function get alpha():Number
		{
			if (!this.heroSprite)
				return super.alpha;

			if (this.player['id'] != Game.selfId)
				return super.alpha;

			return this.heroSprite.alpha;
		}

		override public function set alpha(value:Number):void
		{
			if (!this.heroSprite)
				return;

			if (this.player['id'] != Game.selfId)
				super.alpha = value;

			this.heroSprite.alpha = value;
			this.hareSprite.alpha = value;
			this.scratSprite.alpha = value;
			this.dragonSprite.alpha = value;
			this.viewPerkAnimation.alpha = value;
			this.viewPerkAnimationPermanent.alpha = value;
			this.viewCollectionAnimation.alpha = value;
			this.viewEnergyKitAnimation.alpha = value;
			this.mirageAnimation.alpha = value;
			if (this.viewAlternative != null)
				this.viewAlternative.alpha = value;
			if (this.activeAura)
				this.activeAura.alpha = value;
			if (this.passiveAura)
				this.passiveAura.alpha = value;
			if (this.bubble)
				this.bubble.alpha = value;
		}

		public function toggleBlackEmotion(value:Boolean):void
		{
			if (!this.armature)
				return;

			this.armature.getBone(BonesData.HEAD_BONE).childArmature.getBone("Eye").displayController = value ? "black" : null;
			this.armature.getBone(BonesData.HEAD_BONE).childArmature.getBone("Mouth").displayController = value ? "black" : null;

			if (!value)
				return;
			this.armature.getBone(BonesData.HEAD_BONE).childArmature.animation.gotoAndPlay("black");
		}

		public function hitTest(point:Point):Boolean
		{
			return this.heroSprite.hitTestPoint(point.x, point.y);
		}

		public function remove():void
		{
			this.player = null;

			if (circle)
				circle.removeFromParent();

			if (this.heartsView)
				(this.heartsView as IStarlingAdapter).removeFromParent();
			if (this.tears['left'])
				(this.tears['left'] as IStarlingAdapter).removeFromParent();
			if (this.tears['right'])
				(this.tears['right'] as IStarlingAdapter).removeFromParent();

			if (this.viewDeath)
				this.viewDeath.removeFromParent(true);
			this.viewDeath = null;

			if (this.clothing)
				this.clothing.remove();
			this.clothing = null;

			if (this.scratView)
				(this.scratView as ScratView).remove();
			this.scratView = null;

			if (this.scratSprite && this.containsStarling(this.scratSprite))
				removeChildStarling(this.scratSprite, true);
			this.scratSprite = null;

			if (this.hareView)
				(this.hareView as HareView).remove();
			this.hareView = null;

			if (this.hareSprite && this.containsStarling(this.hareSprite))
				removeChildStarling(this.hareSprite, true);
			this.hareSprite = null;

			if (this.dragonView)
				(this.dragonView as DragonView).remove();
			this.dragonView = null;

			if (this.dragonSprite && this.containsStarling(this.dragonSprite))
				removeChildStarling(this.dragonSprite, true);
			this.dragonSprite = null;

			//this.viewSquirrelCast = null;

			if (this.containsStarling(this.viewEnergyKitAnimation))
				removeChildStarling(this.viewEnergyKitAnimation);
			this.viewEnergyKitAnimation.dispose();
			this.viewEnergyKitAnimation = null;

			if (this.contains(this.mirageAnimation))
				removeChild(this.mirageAnimation);

			if (this.containsStarling(this.mirageAnimation))
				removeChildStarling(this.mirageAnimation);

			this.mirageAnimation.dispose();
			this.mirageAnimation = null;

			if (this.contains(this.viewPerkAnimationPermanent))
				removeChild(this.viewPerkAnimationPermanent);
			this.viewPerkAnimationPermanent = null;

			if (this.contains(this.viewPerkAnimation))
				removeChild(this.viewPerkAnimation);
			this.viewPerkAnimation = null;

			if (this.containsStarling(this.viewCollectionAnimation))
				removeChildStarling(this.viewCollectionAnimation);
			this.viewCollectionAnimation.dispose();
			this.viewCollectionAnimation = null;

			if (this.contains(this.nameSprite) || this.containsStarling(this.nameSprite))
				removeChildStarling(this.nameSprite);

			this.nameSprite.dispose();
			this.nameSprite = null;

			this.messageSprite.dispose();
			this.emotionSprite.dispose();

			if (this.activeAura)
			{
				if (this.containsStarling(this.activeAura))
					removeChildStarling(this.activeAura);
			}

			if (this.passiveAura)
			{
				this.passiveAura.remove();
				if (this.contains(this.passiveAura))
					removeChild(this.passiveAura);
			}

			if (this.bubble)
			{
				if (this.containsStarling(this.bubble))
				{
					this.bubble.removeFromParent();
					this.bubble = null;
				}
			}

			this.circle = null;
			this.aura = null;
			this.activeAura = null;
			this.bubble = null;

			WorldClock.clock.remove(this.armature);
			this.armature.dispose();
			this.armature = null;

			if (this.containsStarling(this.heroSprite))
				removeChildStarling(this.heroSprite, false);

			this.heroSprite = null;
		}

		public function set gummed(value:Boolean):void
		{
			if (value)
			{
				if (!this.gum)
					this.gum = new GumStart();
				this.gum.y = -20;
				addChild(this.gum);
				return;
			}

			if (this.gum && this.gum.parent)
				this.gum.parent.removeChild(this.gum);
		}

		public function set contused(value:Boolean):void
		{
			if (this.isDeathClothing)
				return;

			if (value) {/*unused*/}

			//this.clothing.dress(ClothesData.CONTUSED_SQUIRREL);
		}

		public function set immortal(value:Boolean):void
		{
			if (value && !this.bubble)
			{
				this.bubble = new StarlingAdapterSprite(new ImmortalityBubble);
				updateImmortal();
			}

			if (value)
			{
				this.getStarlingView().addChildAt(this.bubble.getStarlingView(), 0);
			}
			else
			{
				if (this.bubble.getStarlingView() && this.getStarlingView().contains(this.bubble.getStarlingView())) {
					this.bubble.getStarlingView().removeFromParent(true);
				}

				removeChildStarling(this.bubble);
				this.bubble = null;
			}
		}

		public function setCurseView(view:DisplayObject):void
		{
			if (this.curseView && this.curseView.parent)
				this.curseView.parent.removeChild(this.curseView);

			this.curseView = view;

			if (view == null)
				return;

			this.curseView.y = -75;
			addChildAt(this.curseView, getChildIndex(this.messageSprite));
		}

		public function get onCurse():Boolean
		{
			return this._onCurse;
		}

		public function set onCurse(value:Boolean):void
		{
			this._onCurse = value;
		}

		public function set clanName(value:String):void
		{
			return;

			this.nameSprite.fieldClan.text = value;
			this.nameSprite.redraw();
		}

		public function set castProgress(value:int):void
		{
			this.circle.touchable = false;
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

			update();
		}

		public function get playerNameSprite():HeroName
		{
			return this.nameSprite;
		}

		public function sendMessage(message:String, duration:int = 5000):void
		{
			removeMessage();
			removeSmile();

			if (message)
				this.messageSprite.setText(message, duration);
		}

		public function sendSmile(type:int):void
		{
			removeMessage();
			removeSmile();

			this.emotionSprite.emotion = type;
		}

		public function set dead(value:Boolean):void
		{
			if (this.isDead == value)
				return;

			this.isDead = value;

			if (this.nameSprite)
				this.nameSprite.visible = !value;
			if (this.viewPerkAnimation)
				this.viewPerkAnimation.visible = !value;

			if (this.aura)
				this.aura.visible = !value;

			if (this.activeAura)
				this.activeAura.visible = !value;

			if (this.passiveAura)
			{
				this.passiveAura.visible = !value;
				(this.passiveAura.visible ? this.passiveAura.play() : this.passiveAura.stop());
			}

			if (this.bubble)
			{
				this.bubble.visible = !value;
			}

			if (this.isDead)
			{
				initDeadAnimation();
				setView();
			}

			update();
		}

		public function get dead():Boolean
		{
			return this.isDead;
		}

		public function get hasNut():Boolean
		{
			return this.nut;
		}

		public function set hasNut(value:Boolean):void
		{
			if (this.hareView)
				(this.hareView as HareView).hasAcorn = value;
			if (this.scratView)
				(this.scratView as ScratView).hasAcorn = value;
			if (this.dragonView)
				(this.dragonView as DragonView).hasAcorn = value;

			if (this.nut == value)
				return;

			this.nut = value;

			this.armature.getBone(ACORN).displayController = value ? ACORN : null;
			this.armature.getBone(BELT).displayController = value ? ACORN : null;

			if (!value)
				return;

			this.armature.animation.gotoAndPlay(ACORN, -1, -1, NaN, 0, ACORN, "sameGroup");
			this.armature.invalidUpdate();

			WorldClock.clock.advanceTime(-1);
		}

		public function setClothing(packagesIds:Array, accessoriesIds:Array = null):void
		{
			if (packagesIds == null)
				packagesIds = [];
			if (accessoriesIds == null)
				accessoriesIds = [];

			if (this.clothing != null)
				this.clothing.clear();

			this.isDeathClothing = false;

			var clothesIds:Array = [];
			var shamanClothesIds:Array = [];
			for (var i:int = 0; i < packagesIds.length; i++)
			{
				if (OutfitData.isShamanSkin(packagesIds[i]))
					shamanClothesIds.push(packagesIds[i]);
				else if (!OutfitData.isScratSkin(packagesIds[i]) && !OutfitData.isScrattySkin(packagesIds[i]))
				{
					clothesIds.push(packagesIds[i]);
					this.isDeathClothing = this.isDeathClothing || OutfitData.isDeathSkin(packagesIds[i]);
				}
			}

			if (this.clothing != null)
				this.clothing.setItems(this.shaman ? shamanClothesIds : clothesIds, this.shaman ? null : accessoriesIds);

			if (this.scratView)
				(this.scratView as ScratView).setClothing(packagesIds);

			update();

			updateTopOffset();
			updateSmoothingBones();

			if (this.nameSprite)
				addChildStarling(this.nameSprite);
			if (this.visible)
				onStateChanged();
		}

		public function get emotion():Boolean
		{
			return this.inEmotion;
		}

		public function get emotionType():int
		{
			return this.emotionState;
		}

		public function setEmotion(typeEmotion:int):void
		{
			if ((this.emotion && (this.emotionState == typeEmotion)) || this.fly || this.running)
				return;

			if (typeEmotion >= Hero.EMOTION_MAX_TYPE)
				return;

			this.inEmotion = true;
			this.emotionState = typeEmotion;
			this.emotionChanged = true;
			toggleBlackEmotion(false);

			update();
		}

		public function resetEmotion():void
		{
			this.inEmotion = false;
			if (this.hareView)
				(this.hareView as HareView).laugh = false;

			toggleBlackEmotion(this._team == Hero.TEAM_BLACK);
			update();
		}

		public function get shaman():Boolean
		{
			if (this.nameSprite)
				this.nameSprite.redraw();
			return this._shaman;
		}

		public function set shaman(value:Boolean):void
		{
			if (this._shaman == value)
				return;

			if (this.clothing != null)
				this.clothing.clear();

			this._shaman = value;

			if (this.aura)
				this.aura.visible = !value;

			if (!value)
			{
				if (this.player['weared'] != null)
					setClothing(this.player['weared_packages'], this.player['weared_accessories']);
				toggleBlackEmotion(false);
			}
			else
				dressShaman();

			this.nameSprite.shaman = value;

			this.heroSprite.visible = !this.hare && !dragon && (this.shaman || !(this.scrat && this._allowCharacter));
			this.scratSprite.visible = !this.hare && !this.shaman && !this.dragon && this.scrat && this._allowCharacter;
			this.dragonSprite.visible = !this.hare && !this.shaman && !this.scrat && this.dragon;

			update();

			if (this.visible)
				onStateChanged();

			if (this.nameSprite)
				this.nameSprite.redraw();
		}

		public function showCheaterPointer(visible: Boolean): void
		{
			if (this._cheaterPointer && !visible)
			{
				this._cheaterPointer.removeFromParent();
				this._cheaterPointer = null;
			}

			if (visible && !this._cheaterPointer)
			{
				this._cheaterPointer = new StarlingAdapterSprite(new ArrowMovie);
				this._cheaterPointer.rotation = -90;
				this._cheaterPointer.x = -13;
				this._cheaterPointer.y -= this._cheaterPointer.height + nameSprite.height / 2;
				this.addChildStarling(this._cheaterPointer);
			}

		}

		public function get team():int
		{
			return this._team;
		}

		public function set team(value:int):void
		{
			if (this._team == value)
				return;
			this._team = value;

			if (this.shaman)
				dressShaman();

			this.nameSprite.team = value;

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

			if (value)
				this.inEmotion = false;
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

			this.armature.display.scaleX = (value ? 1 : -1) * Math.abs(this.armature.display.scaleX);
			this.hareSprite.getStarlingView().scaleX = (value ? 1 : -1) * Math.abs(this.hareSprite.getStarlingView().scaleX);
			this.scratSprite.getStarlingView().scaleX = (value ? 1 : -1) * Math.abs(this.scratSprite.getStarlingView().scaleX);
			this.dragonSprite.getStarlingView().scaleX = (value ? 1 : -1) * Math.abs(this.dragonSprite.getStarlingView().scaleX);

			if (this.viewAlternative && this.needHeroScaleX)
				this.viewAlternative.scaleX = (value ? 1 : -1) * Math.abs(this.viewAlternative.scaleX);
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

			if (value)
				this.inEmotion = false;
		}

		public function update():void
		{
			if (this.viewDeath)
				this.viewDeath.visible = this.dead && !this.shaman && !this.onCurse;

			if (this.armature && this.armature.display)
				this.armature.display.visible = !this.dead;

			//if (this.casting && !this.shaman)
			//	this.viewSquirrelCast.play();

			if ((this.lastState != this.state) || ((this.lastState == this.state) && (this.state == Hero.STATE_EMOTION) && this.emotionChanged))
				onStateChanged();
		}

		public function scaleHead(scaleFactor:Number):void
		{
			for each(var name:String in [BonesData.HEAD_BONE, BonesData.CAP_BONE])
			{
				var bone:Bone = this.armature.getBone(name);
				bone.node.scaleX = bone.node.scaleY = scaleFactor;
			}
		}

		public function set scale(value:Number):void
		{
			this._scale = value;

			this.scaleY = value;
			this.scaleX = (this.scaleX ? 1 : -1) * Math.abs(this.scaleY);
			this.y = value < 1 ? 21 * value : 21;

			this.nameSprite.scaleXY(1);
			this.messageSprite.scaleX = this.scaleX;
			this.viewCollectionAnimation.scaleX = 1;
			this.viewCollectionAnimation.scaleY = 1;
			updateImmortal();
			updateTopOffset();
		}

		public function showPerkAnimation(button:SimpleButton, delay:int, showExplosion:Boolean = true):void
		{
			this.viewPerkAnimation.play(button, delay, showExplosion);
			addChildAt(this.viewPerkAnimation, getChildIndex(this.emotionSprite) - 1);
		}

		public function showPerkAnimationPermanent(button:SimpleButton, showExplosion:Boolean = true):void
		{
			this.viewPerkAnimationPermanent.play(button, 0, showExplosion);
			addChildAt(this.viewPerkAnimationPermanent, getChildIndex(this.emotionSprite) - 1);
		}

		public function hidePerkAnimation():void
		{
			this.viewPerkAnimation.stop();
		}

		public function hidePerkAnimationPermanent():void
		{
			this.viewPerkAnimationPermanent.removeAnimation();
		}

		public function showCollectionAnimation(itemId:int, kind:int, duration:int = 0):void
		{
			this.viewCollectionAnimation.play(itemId, kind, duration);
			addChildStarling(this.viewCollectionAnimation);
		}

		public function hideCollectionAnimation():void
		{
			if (this.containsStarling(this.viewCollectionAnimation))
				removeChildStarling(this.viewCollectionAnimation);
		}

		public function showGetBonusAnimation(view:MovieClip):void
		{
			this.viewEnergyKitAnimation.view = view;
			this.viewEnergyKitAnimation.play(0, 0, BaseCollectionHeroAnimation.DURATION);
			addChildStarling(this.viewEnergyKitAnimation);
		}

		public function showMirageAnimation(hero:Hero, itemId:int):void
		{
			this.mirageAnimation.startAnimation(hero, itemId);
			this.mirageAnimation.y = this.topCoords - 45;
			addChildStarling(this.mirageAnimation);
		}

		public function showActiveAura():void
		{
			if (!this.activeAura)
			{
				this.activeAura = new StarlingAdapterMovie(new ActiveAura);
				this.activeAura.loop = false;
			}
			this.activeAura.alignPivot();
			this.activeAura.x = 0;
			this.activeAura.y = -20;

			this.activeAura.gotoAndPlay(0);
			addChildStarling(this.activeAura);
		}

		public function showPassiveAura():void
		{
			if (this.passiveAuraCount++)
				return;

			if (!this.passiveAura)
			{
				this.passiveAura = new Animation(new PassiveAura);
				this.passiveAura.x = -25;
				this.passiveAura.y = -30;
			}

			this.passiveAura.play();
			addChild(this.passiveAura);
		}

		public function hidePassiveAura():void
		{
			if (this.passiveAuraCount == 0 || !this.passiveAura)
				return;

			this.passiveAuraCount --;

			if (this.passiveAuraCount != 0)
				return;

			this.passiveAura.stop();
			if (contains(this.passiveAura))
				removeChild(this.passiveAura);
		}

		public function setView(view:Sprite = null, needHeroScaleX:Boolean = true):void
		{
			if (this.heroSprite == null)
				return;

			if (this.nameSprite)
				this.nameSprite.redraw();

			this.needHeroScaleX = needHeroScaleX;

			if (this.viewAlternative && this.contains(this.viewAlternative))
				removeChild(this.viewAlternative);

			if (this.viewAlternative is StarlingAdapterSprite && this.containsStarling(this.viewAlternative))
				removeChildStarling(this.viewAlternative, false);

			if (view == null)
			{
				this.hareSprite.visible = Boolean(this.isHare);
				this.heroSprite.visible = !this.hare && !this.dragon && (this.shaman || !(this.scrat && this._allowCharacter));
				this.scratSprite.visible = !this.hare && !this.shaman && !this.dragon && this.scrat && this._allowCharacter;
				this.dragonSprite.visible = Boolean(this.dragon);
				return;
			}

			this.nameSprite.visible = true;
			this.heroSprite.visible = false;
			this.hareSprite.visible = false;
			this.scratSprite.visible = false;
			this.dragonSprite.visible = false;
			this.viewAlternative = view;
			if (this.needHeroScaleX)
				this.viewAlternative.scaleX = (this.direction ? 1 : -1) * Math.abs(this.scaleX);
			this.viewAlternative.alpha = this.heroSprite.alpha;

			addChildAt(this.viewAlternative, 1);

			if (this.viewAlternative is StarlingAdapterSprite)
				addChildStarling(this.viewAlternative);

			updateTopOffset();
		}

		public function addView(view:DisplayObject, addOver:Boolean = false, needHeroScaleX:Boolean = true):void
		{
			if (this.viewAlternative && this.contains(this.viewAlternative))
				removeChild(this.viewAlternative);

			if (this.hareSprite)
				this.hareSprite.visible = false;

			this.viewAlternative = view as Sprite;
			if (this.viewAlternative && view)
			{
				if (needHeroScaleX)
					this.viewAlternative.scaleX = (this.direction ? 1 : -1) * Math.abs(this.scaleX);
				this.viewAlternative.alpha = this.heroSprite ? this.heroSprite.alpha : 0;

				this.viewAlternative.x = this.viewAlternative.x;
				this.viewAlternative.y = this.viewAlternative.y;

				if (addOver)
				{/*unused*/
				}

				//if (addOver && getChildStarlingIndex(this.dragonSprite) > -1)
				//	addChildAt(this.viewAlternative, (getChildStarlingIndex(this.dragonSprite) + 1));
				//else
				addChild(this.viewAlternative);
			}
		}

		public function get isHare():*
		{
			return this.hare;
		}

		public function set isHare(value:*):void
		{
			if (this.hare == value)
				return;

			if (!this.hareView && value)
			{
				this.hareView = new HareView();
				(this.hareView as HareView).hasAcorn = this.hasNut;
				this.hareSprite.addChildStarling(this.hareView);
			}

			this.hare = value;
			this.hareSprite.visible = Boolean(value);
			this.heroSprite.visible = !this.hare && !this.dragon && (this.shaman || !(this.scrat && this._allowCharacter));
			this.scratSprite.visible = !this.hare && !this.shaman && !this.dragon && this.scrat && this._allowCharacter;
			this.dragonSprite.visible = Boolean(this.dragon);
			updateTopOffset();

			if (value && this.viewAlternative && this.contains(this.viewAlternative))
				removeChild(this.viewAlternative);
		}

		public function get isScrat():Boolean
		{
			return this.scrat;
		}

		public function set isScrat(value:Boolean):void
		{
			if (this.scrat == value)
				return;

			if (!this.scratView && value)
			{
				var isScrat:Boolean = false;
				for (var i:int = 0; i < this.player['weared_packages'].length; i++)
					isScrat = isScrat || OutfitData.isScratSkin(this.player['weared_packages'][i]);

				this.scratView = new ScratView(isScrat);
				(this.scratView as ScratView).hasAcorn = this.hasNut;
				this.scratSprite.addChildStarling(this.scratView);
			}

			this.scrat = value;
			this.hareSprite.visible = Boolean(this.hare);
			this.heroSprite.visible = !this.hare && !this.dragon && (this.shaman || !(value && this._allowCharacter));
			this.scratSprite.visible = !this.hare && !this.shaman && !this.dragon && this._allowCharacter && value;
			this.dragonSprite.visible = Boolean(this.dragon);
			updateTopOffset();

			if (value && this.viewAlternative && this.contains(this.viewAlternative))
				removeChild(this.viewAlternative);
		}

		public function get isDragon():*
		{
			return this.dragon;
		}

		public function set isDragon(value:*):void
		{
			if (this.dragon == value)
				return;

			if (!this.dragonView && value)
			{
				this.dragonView = new DragonView();
				(this.dragonView as DragonView).hasAcorn = this.hasNut;
				this.dragonSprite.addChildStarling(this.dragonView);
			}

			this.dragon = value;
			this.hareSprite.visible = Boolean(this.hare);
			this.heroSprite.visible = !this.hare && !this.dragon && (this.shaman || !(this.scrat && this._allowCharacter));
			this.scratSprite.visible = !this.hare && !this.shaman && !this.dragon && this.scrat && this._allowCharacter;
			this.dragonSprite.visible = Boolean(this.dragon);
			updateTopOffset();

			if (value && this.viewAlternative && this.contains(this.viewAlternative))
				removeChild(this.viewAlternative);
		}

		public function set allowCharacter(value:Boolean):void
		{
			this._allowCharacter = value;

			this.scratSprite.visible = !this.hare && !this.shaman && !this.dragon && this.scrat && this._allowCharacter;
			this.heroSprite.visible = !this.hare && !this.dragon && (this.shaman || !(this.scrat && this._allowCharacter));
		}

		public function get topCoords():int
		{
			if (this.isScrat)
				return SCRAT_TOP;

			if (this.isDragon)
				return DRAGON_TOP;

			if (this.isHare)
				return HARE_TOP;

			if (this.shaman && this._scale > 1)
				return HERO_TOP * this._scale;

			if (this.viewAlternative && this.viewAlternative.name == "Vendigo")
				return VENDIGO_TOP;

			if (this.viewAlternative && this.viewAlternative.name == "SnowLeopard")
				return LEOPARD_TOP;

			if (this.viewAlternative && this.viewAlternative.name == "ClothesFlightView")
				return FLIGHT_TOP;

			return HERO_TOP;
		}

		private function initEmotion():void
		{
			var head:Bone = this.armature.getBone(BonesData.HEAD_BONE);
			var slot:Slot = HeroLoader.buildSlot();

			var heartsDisplay:StarlingAdapterSprite = new StarlingAdapterSprite();

			this.heartsView = new StarlingAdapterMovie(new KissHearts());
			this.heartsView.x = 25;
			this.heartsView.y = 72;
			this.heartsView.loop = false;
			this.heartsView.stop();
			heartsDisplay.addChildStarling(this.heartsView.getStarlingView());

			slot.display = heartsDisplay.getStarlingView();
			slot.origin.copy(head.origin);
			slot.zOrder = this.armature.getSlots().length + 1;
			head.addChild(slot);

			this.tears['left'] = new StarlingAdapterMovie(new ShamTears());
			this.tears['left'].scaleX *= -1;
			this.tears['left'].x = 7;
			this.tears['left'].y = 32;
			this.tears['left'].stop();
			this.tearsView.addChildStarling(this.tears['left'].getStarlingView());

			this.tears['right'] = new StarlingAdapterMovie(new ShamTears());
			this.tears['right'].x = -5;
			this.tears['right'].y = 31;
			this.tears['right'].stop();
			this.tearsView.addChildStarling(this.tears['right'].getStarlingView());

			slot = HeroLoader.buildSlot();
			slot.display = this.tearsView.getStarlingView();
			slot.origin.copy(head.origin);
			slot.node.rotation = -0.2;
			slot.zOrder = this.armature.getSlots().length + 1;
			head.addChild(slot);

			this.heartsView.visible = this.tearsView.visible = false;
		}

		private function onStateChanged():void
		{
			this.lastState = this.state;

			if (this.hareView && !this.heroSprite.visible)
				(this.hareView as HareView).setState(this.state);
			if (this.dragonView && !this.heroSprite.visible)
				(this.dragonView as DragonView).setState(this.state);
			if (this.scratView && !this.heroSprite.visible)
				(this.scratView as ScratView).setState(this.state);
			if (this.viewAlternative && this.viewAlternative is IControlAnimation)
				(this.viewAlternative as IControlAnimation).setState(this.state);

			if (this.heartsView)
				this.heartsView.visible = false;

			if (this.tearsView)
				this.tearsView.visible = false;

			if (this.tears['right'])
				this.tears['right'].stop();

			if (this.tears['left'])
				this.tears['left'].stop();

			switch (this.state)
			{
				case Hero.STATE_DEAD:
					if (this.onCurse || this.hareSprite && this.hareView && this.hareSprite.visible ||
						this.scratSprite && this.scratView && this.scratSprite.visible ||
						this.dragonSprite && this.dragonView && this.dragonSprite.visible)
					{
						break;
					}

					if (this.viewDeath)
						this.viewDeath.gotoAndPlay(1);
					break;
				case Hero.STATE_EMOTION:
					this.emotionChanged = false;
					if (this.hareSprite && this.hareView && this.hareSprite.visible)
					{
						(this.hareView as HareView).laugh = true;
						break;
					}
					var animationName:String = '';

					switch (this.emotionType)
					{
						case Hero.EMOTION_LAUGH:
							animationName = Hero.DB_LAUGH;
							break;
						case Hero.EMOTION_KISS:
							animationName = Hero.DB_KISS;
							break;
						case Hero.EMOTION_CRY:
							animationName = Hero.DB_CRY;
							if (this.tearsView)
								this.tearsView.visible = true;

							if (this.tears['right'])
								this.tears['right'].play();

							if (this.tears['left'])
								this.tears['left'].play();
							break;
						case Hero.EMOTION_ANGRY:
							animationName = Hero.DB_ANGRY;
					}

					if (this.armature && this.armature.animation && animationName != '')
						this.armature.animation.gotoAndPlay(animationName);
					break;
				case Hero.STATE_STOPED:
					this.lastState = this.state;
					if (this.armature && this.armature.animation)
						this.armature.animation.stop();
					break;
				default:
					if (this.state in Hero.DB_STATES)
					{
						switch (this.state)
						{
							case Hero.STATE_SHAMAN:
								if (this.armature)
								{
									if (this.typeShaman == DREAM_CATCHERS)
										this.armature.animation.gotoAndPlay(Hero.DB_CAST3);
									else
										this.armature.animation.gotoAndPlay(Hero.DB_STATES[this.state]);
									break;
								}
							case Hero.STATE_RUN:
							case Hero.STATE_JUMP:
								if (this.armature && this.armature.animation)
								{
									if (this.isDeathClothing)
										this.armature.animation.gotoAndPlay(Hero.DB_STAND);
									else
										this.armature.animation.gotoAndPlay(Hero.DB_STATES[this.state]);
									break;
								}
							default:
								if (this.armature && this.armature.animation)
									this.armature.animation.gotoAndPlay(Hero.DB_STATES[this.state]);
						}
					}
					break;
			}
		}

		private function updateImmortal():void
		{
			if (this.bubble)
				this.bubble.y = -33 * this._scale;
		}

		private function dressShaman():void
		{
			switch (this.team)
			{
				case Hero.TEAM_BLUE:
					setClothing([OutfitData.SHAMAN_BLUE]);
					break;
				case Hero.TEAM_RED:
					setClothing([OutfitData.SHAMAN_RED]);
					break;
				case Hero.TEAM_BLACK:
					setClothing([OutfitData.SHAMAN_BLACK]);
					toggleBlackEmotion(true);
					break;
				default:
					var shamanClothes:Array = [];
					if (('weared' in this.player))
					{
						shamanClothes = (this.player['weared_packages'] as Array).filter(function(item:*, index:int, array:Array):Boolean
						{
							if (array && index) {/*unused*/}

							return OutfitData.getOwnerById(item) == OutfitData.OWNER_SHAMAN;
						});
					}

					if (shamanClothes.length == 0)
						setClothing([OutfitData.SHAMAN_BLUE]);
					else
						setClothing(shamanClothes);

					var clothes:Array = this.clothing.getClothesDressed();

					if (clothes.indexOf(ClothesData.DREAMCATCHERS_MALE_ID) != -1 || clothes.indexOf(ClothesData.DREAMCATCHERS_FEMALE_ID) != -1)
						this.typeShaman = DREAM_CATCHERS;
					else if (clothes.indexOf(ClothesData.FLOWER_ID) != -1)
						this.typeShaman = FLOWER;
					else
						this.typeShaman = DEFAULT;
			}
		}

		private function get state():int
		{
			if (!this.visible)
				return Hero.STATE_STOPED;
			if (this.dead)
				return Hero.STATE_DEAD;
			if (this.casting)
				return Hero.STATE_SHAMAN;
			if (this.fly)
				return Hero.STATE_JUMP;
			if (this.running)
				return Hero.STATE_RUN;
			if (this.emotion)
				return Hero.STATE_EMOTION;
			return Hero.STATE_REST;
		}

		private function initDeadAnimation():void
		{
			if (this.viewDeath || !this.heroSprite)
				return;

			var className:Class = getDefinitionByName("HeroDead") as Class;
			if (className == null)
				return;
			this.viewDeath = new StarlingAdapterMovie(new className());
			this.viewDeath.x = -30;
			this.viewDeath.y = -150;
			this.viewDeath.blendMode = BlendMode.SCREEN;
			this.viewDeath.loop = false;
			this.heroSprite.addChildStarling(this.viewDeath);
		}

		override public function set scaleY(value: Number): void
		{
			super.scaleY = value;
			updateTopOffset();
		}

		private function updateTopOffset():void
		{
			if (!this.player)
				return;
			this.nameSprite.y = (this.topCoords - 5) * this.armature.display.scaleY;
			this.messageSprite.offsetY = this.topCoords + this.animationOffset - 30;

			this.emotionSprite.y = this.topCoords + this.animationOffset - 50;

			this.viewPerkAnimation.y = this.topCoords + this.animationOffset - 15;
			this.viewPerkAnimationPermanent.y = this.topCoords + this.animationOffset - 15;
			this.viewCollectionAnimation.y = this.topCoords + this.animationOffset - 8;
			this.mirageAnimation.y = this.topCoords + this.animationOffset;
			this.viewEnergyKitAnimation.y = this.topCoords + this.animationOffset + 15;
		}

		private function removeMessage():void
		{
			this.messageSprite.remove();
		}

		private function removeSmile():void
		{
			this.emotionSprite.remove();
		}

		private function onFrameEvent(e:FrameEvent):void
		{
			if (!(e.frameLabel == HEARTS_EVENT))
				return;

			this.heartsView.visible = true;
			this.heartsView.gotoAndPlay(0);
		}

		private function updateSmoothingBones():void
		{
			//TODO вернуть если хлебушки или в рабочке будут рвать пуканы
		//	SmoothingUtil.setSmoothing(this.armature, TextureSmoothing.TRILINEAR, ["Chest", "Stomach", "Tail", "T-shirt", "Skirt", "Pants", "Tail_accessory_01", "Tail_accessory_02", "Tail_accessory_03", "Long_dress"]);
		}
	}
}