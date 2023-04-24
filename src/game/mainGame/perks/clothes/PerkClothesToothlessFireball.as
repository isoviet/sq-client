package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.simple.FireBall;

	import dragonBones.events.FrameEvent;

	public class PerkClothesToothlessFireball extends PerkClothes
	{
		static private const FIRE_EVENT:String = "fireEvent";

		public function PerkClothesToothlessFireball(hero:Hero)
		{
			super(hero);

			this.code = PerkClothesFactory.PERK_TOOTHLESS_FIREBALL;

			this.activateSound = SOUND_APPEARANCE;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.heroView.running && !this.hero.heroView.fly;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.heroView.armature.addEventListener(FrameEvent.ANIMATION_FRAME_EVENT, onFrameEvent);
			this.hero.heroView.armature.animation.gotoAndPlay(HeroView.DB_FIRE, -1, -1, 1);
		}

		private function onFrameEvent(e:FrameEvent):void
		{
			if (!(e.frameLabel == FIRE_EVENT))
				return;

			this.hero.heroView.armature.removeEventListener(FrameEvent.ANIMATION_FRAME_EVENT, onFrameEvent);
			this.active = false;

			if (!this.hero.isSelf)
				return;

			var fireball:FireBall = new FireBall();
			fireball.playerId = Game.selfId;
			fireball.angle = (this.hero.heroView.direction ? 0 : Math.PI) + this.hero.angle;
			var dirX:b2Vec2 = this.hero.rCol1;
			dirX.Multiply(this.hero.heroView.direction ? (-5 * this.hero.scale) : (5 * this.hero.scale));
			var dirY:b2Vec2 = this.hero.rCol2;
			dirY.Multiply(-1 * this.hero.scale);
			dirX.Add(dirY);
			fireball.position = b2Math.AddVV(this.hero.position, dirX);
			fireball.scale = this.hero.scale;

			this.hero.game.map.createObjectSync(fireball, true);
		}
	}
}