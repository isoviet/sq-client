package game.mainGame.perks.clothes
{
	import flash.events.Event;

	import sounds.GameSounds;

	import dragonBones.Bone;
	import dragonBones.animation.Animation;

	import utils.starling.StarlingAdapterMovie;

	public class PerkClothesToothlessJump extends PerkClothes
	{
		static private const CLOAK_BONE:String = "Cloak";
		static private const ANIMATION_NAME:String = "jumpDragon";

		static private const SLOW_FALL_VELOCITY:Number = 1;

		static private const JUMP_VALUE:Number = 1.5;
		private var dust:StarlingAdapterMovie;

		public function PerkClothesToothlessJump(hero:Hero)
		{
			super(hero);

			this.dust = new StarlingAdapterMovie(new JumpDust());
			this.dust.loop = false;
			this.dust.gotoAndStop(0);
			this.dust.visible = false;
			this.dust.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				dust.gotoAndStop(0);
				dust.visible = false;
			});

			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override public function dispose():void
		{
			this.dust.removeFromParent(true);

			super.dispose();
		}

		override protected function activate():void
		{
			super.activate();

			if (isEndGame || !this.hero)
				return;

			this.hero.heroView.showPerkAnimationPermanent(new ButtonMagic());
			this.hero.addEventListener(Hero.EVENT_UP, onJump);
			this.hero.fallVelocities.push(SLOW_FALL_VELOCITY);
			this.hero.jumpVelocity *= JUMP_VALUE;

			if (this.hero.heroView && this.hero.heroView.armature)
			{

				var bone:Bone = this.hero.heroView.armature.getBone(CLOAK_BONE);
				if (bone)
				{
					bone.displayController = ANIMATION_NAME;
					try
					{
						var slot:* = bone.getSlots().pop();
						if (slot)
							slot.childArmature.animation.timeScale += 2;
					}
					catch (e:Error)
					{}
				}
			}
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (isEndGame)
				return;

			this.hero.heroView.hidePerkAnimationPermanent();

			this.hero.removeEventListener(Hero.EVENT_UP, onJump);

			var index:int = this.hero.fallVelocities.indexOf(SLOW_FALL_VELOCITY);
			if (index != -1)
				this.hero.fallVelocities.splice(index, 1);

			this.hero.jumpVelocity /= JUMP_VALUE;

			//TODO
			//if (this.hero.getClothesDressed().indexOf(COMPLECT_FOR_PERK[0]) == -1)
			//	return;

			var bone:Bone = this.hero.heroView.armature.getBone(CLOAK_BONE);
			if (!bone)
				return;
			bone.displayController = null;
			try
			{
				bone.getSlots().pop().childArmature.animation.timeScale -= 2;
			}
			catch (e:Error)
			{
				Logger.add("deactivate", e);
			}
		}

		private function onJump(e:Event):void
		{
			if (!this || !this.active || !this.hero || !this.hero.onFloor || !e || !this.dust)
				return;

			this.dust.x = this.hero.getPosition().x;
			this.dust.y = this.hero.getPosition().y;
			this.dust.rotation = this.hero.rotation;
			this.dust.scaleX = (this.hero.heroView.direction ? 1 : -1) * Math.abs(this.dust.scaleX);

			if (!this.dust.parentStarling && Hero.self.getStarlingView().parent != null)
				Hero.self.getStarlingView().parent.addChild(this.dust.getStarlingView());

			if (this.hero && this.hero.heroView && this.hero.heroView.armature)
			{
				var bone: Bone =  this.hero.heroView.armature.getBone(CLOAK_BONE);
				if (bone && bone.getSlots())
				{
					var slot: * = bone.getSlots().pop();
					if (slot && slot.childArmature && slot.childArmature.animation)
						slot.childArmature.animation.gotoAndPlay(ANIMATION_NAME, -1, -1, 1, 0, "dragon", Animation.SAME_GROUP);
				}

				if(this.hero.isSelf)
					GameSounds.play(SOUND_WINGS);
			}

			this.dust.gotoAndPlay(0);
			this.dust.visible = true;
		}
	}
}