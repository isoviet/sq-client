package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.magic.HarlockFlag;
	import game.mainGame.perks.clothes.base.PerkClothesCreateObject;
	import sounds.GameSounds;

	public class PerkClothesHarlock extends PerkClothesCreateObject
	{
		private var point:b2Vec2 = null;

		public function PerkClothesHarlock(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override protected function get objectClass():Class
		{
			return HarlockFlag;
		}

		override public function resetRound():void
		{
			super.resetRound();

			this.point = null;
		}

		override protected function activate():void
		{
			super.activate();

			this.point = this.hero.position.Copy();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.point || !this.hero)
				return;
			this.hero.teleportTo(this.point);
			GameSounds.play(SOUND_TELEPORT);
		}
	}
}