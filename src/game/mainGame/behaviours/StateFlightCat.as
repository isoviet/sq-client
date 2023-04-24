package game.mainGame.behaviours
{
	import Box2D.Common.Math.b2Mat22;

	import wear.BonesData;

	import dragonBones.Bone;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class StateFlightCat extends HeroState implements IStateActive
	{
		private var power:Number = 0;
		private var _active:Boolean = false;
		private var effect: ParticlesEffect;

		public function StateFlightCat(time:Number, power:Number)
		{
			super(time);

			this.power = power;
		}

		public function set active(value:Boolean):void
		{
			if (value == this._active)
				return;
			this._active = value;
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.active = false;

				var bones:Vector.<Bone> = this.hero.heroView.armature.getBones();
				for (var i:int = 0; i < bones.length; i++)
				{
					if (bones[i].name == BonesData.HEAD_BONE || bones[i].name == BonesData.CAP_BONE)
						continue;
					bones[i].visible = true;
				}
				this.hero.disableEffect(CollectionEffects.EFFECT_FAIRY_CAT);
				this.effect = null;

			}
			else
			{
				bones = value.heroView.armature.getBones();
				for (i = 0; i < bones.length; i++)
				{
					if (bones[i].name == BonesData.HEAD_BONE || bones[i].name == BonesData.CAP_BONE)
						continue;
					bones[i].visible = false;
				}
				this.effect = value.applyEffect(CollectionEffects.EFFECT_FAIRY_CAT);
				this.effect.additionAngle = Math.PI * 0.5;
			}

			super.hero = value;
		}

		public function get active():Boolean
		{
			return this._active;
		}

		override public function update(timestep:Number):void
		{
			super.update(timestep);

			if (!this.active)
				return;
			//check
			this.hero.velocity.MulM(this.hero.body.GetTransform().R.GetInverse(new b2Mat22));
			this.hero.velocity.y = -this.power;
			this.hero.velocity.MulM(this.hero.body.GetTransform().R);
			this.hero.body.SetLinearVelocity(this.hero.velocity);
		}
	}
}