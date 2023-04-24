package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	import sounds.GameSounds;

	public class PerkClothesSalutBase extends PerkClothes

	{
		static private var SALUT_VIEW:Array = null;
		static private var SALUT_SOUND:Array = ["perk_new_year0", "perk_new_year1"];

		protected var typeSalut:int;

		private var salutSprite:Sprite;
		private var salut:MovieClip;

		public function PerkClothesSalutBase(hero:Hero):void
		{
			super(hero);

			if (!SALUT_VIEW)
				PerkClothesSalutBase.SALUT_VIEW = [NewYearSalut1, NewYearSalut2];
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.heroView.running && !this.hero.heroView.fly && !this.active;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero.game)
				return;

			var position:Point = this.hero.getPosition();
			this.salutSprite = new Sprite();
			this.salutSprite.x = position.x;
			this.salutSprite.y = position.y;
			this.salutSprite.rotation = this.hero.rotation;
			this.hero.game.map.userUpperSprite.addChild(this.salutSprite);

			this.salut = new SALUT_VIEW[this.typeSalut];
			this.salut.gotoAndPlay(0);
			this.salut.addEventListener(Event.CHANGE, onSalut);
			this.salutSprite.addChild(this.salut);

			GameSounds.play(SALUT_SOUND[this.typeSalut]);
		}

		private function onSalut(e:Event):void
		{
			this.salut.removeEventListener(Event.CHANGE, onSalut);

			if (this.salutSprite.parent)
				this.salutSprite.parent.removeChild(this.salutSprite);

			this.active = false;
		}
	}
}