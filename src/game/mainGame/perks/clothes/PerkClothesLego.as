package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.magic.Lego;

	public class PerkClothesLego extends PerkClothes
	{
		public function PerkClothesLego(hero:Hero):void
		{
			super(hero);
			this.code = PerkClothesFactory.PERK_LEGO;
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused)
			{
				this._active = false;
				return;
			}

			super.activate();

			if (this.hero.id != Game.selfId)
				return;

			var castObject:Lego = new Lego();
			castObject.angle = this.hero.angle;
			var dirX:b2Vec2 = this.hero.rCol1;
			dirX.Multiply(this.hero.heroView.direction ? -4 : 4);
			var dirY:b2Vec2 = this.hero.rCol2;
			dirX.Add(dirY);
			castObject.position = b2Math.AddVV(this.hero.position, dirX);
			this.hero.game.map.createObjectSync(castObject, true);
		}
	}
}