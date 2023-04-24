package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	public class PerkClothesZoom extends PerkClothes
	{
		static private const DISTANCE:Number = 150 / Game.PIXELS_TO_METRE;

		public function PerkClothesZoom(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_TELEPORT;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override protected function activate():void
		{
			super.activate();

			var destination:b2Vec2 = new b2Vec2((this.hero.heroView.direction ? -1 : 1) * DISTANCE, 0);
			destination.MulM(this.hero.body.GetTransform().R);
			destination.Add(this.hero.position.Copy());
			this.hero.magicTeleportTo(destination);
		}
	}
}