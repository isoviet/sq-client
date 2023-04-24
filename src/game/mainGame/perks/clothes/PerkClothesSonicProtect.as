package game.mainGame.perks.clothes
{
	import flash.events.Event;
	import flash.geom.Point;

	import sounds.GameSounds;

	public class PerkClothesSonicProtect extends PerkClothes
	{
		public function PerkClothesSonicProtect(hero:Hero):void
		{
			super(hero);

			this.hero.addEventListener(Hero.EVENT_DEADLY_CONTACT, onDeadlyContact);

			this.activateSound = "moneys";
			this.soundOnlyHimself = true;
		}

		override public function get available():Boolean
		{
			return false;
		}

		private function onDeadlyContact(e:Event):void
		{
			if (this.hero.immortal)
				return;
			if (this.activationCount > 0 || !this.hero.isSquirrel || this.hero.isDead)
				return;
			var view:SonicProtectMagicView = new SonicProtectMagicView();
			var position:Point = this.hero.getPosition();
			view.x = position.x;
			view.y = position.y;
			this.hero.game.map.userUpperSprite.addChild(view);

			GameSounds.play("sonic_spikes");

			this.hero.simpleRespawn();
			this.activationCount++;
		}

		override protected function get packets():Array
		{
			return [];
		}
	}
}