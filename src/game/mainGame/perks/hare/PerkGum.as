package game.mainGame.perks.hare
{
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.magic.Gum;
	import sounds.GameSounds;

	public class PerkGum extends PerkHare
	{
		public function PerkGum(hero:Hero):void
		{
			super(hero);
			this.code = Keyboard.TAB;
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.hareView as HareView).stomp && !(this.hero.heroView.hareView as HareView).rock;
		}

		override protected function activate():void
		{
			super.activate();
			(this.hero.heroView.hareView as HareView).chew = true;
			this.hero.isStoped = true;
			setTimeout(throwGum, 1000);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.hero == null)
				return;

			(this.hero.heroView.hareView as HareView).chew = false;
			this.hero.isStoped = false;
		}

		override protected function block():void
		{
			if (!super.available)
				return;

			this.charge = 0;
			this.isBlocked = true;
			dispatchEvent(new Event("STATE_CHANGED"));
		}

		private function throwGum():void
		{
			if (this.hero == null)
				return;

			if (this.charge != 100)
				return;

			if (!this.active)
				return;

			this.hero.sendLocation(-this.code);

			this.active = false;
			this.charge = 0;

			GameSounds.play("spit");
			GameSounds.playUnrepeatable("hare_spit", HareView.SOUND_PROBABILITY);

			if (!this.hero.isSelf)
				return;

			var gum:Gum = new Gum();
			gum.angle = (this.hero.heroView.direction ? 0 : Math.PI) + this.hero.angle;
			gum.playerId = Game.selfId;
			var dir:b2Vec2 = this.hero.rCol1;
			dir.Multiply(this.hero.heroView.direction ? -4 : 4);
			gum.position = b2Math.AddVV(this.hero.position, dir);

			this.hero.game.map.createObjectSync(gum, true);
		}

	}
}