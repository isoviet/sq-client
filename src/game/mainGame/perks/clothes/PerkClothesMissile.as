package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.simple.Missile;

	public class PerkClothesMissile extends PerkClothes
	{
		protected var missileClass:Class;

		public function PerkClothesMissile(hero:Hero):void
		{
			super(hero);
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.game.paused;
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused || this.hero.isDead || this.hero.inHollow)
			{
				this.active = false;
				return;
			}

			super.activate();
		}

		protected function onMissile():void
		{
			if (this.hero.id != Game.selfId)
				return;

			var missile:Missile = new missileClass() as Missile;
			var dirX:b2Vec2 = this.hero.rCol1;
			var dirY:b2Vec2 = this.hero.rCol2;
			dirY.Multiply(-1.5);
			dirX.Add(dirY);
			missile.position = b2Math.AddVV(this.hero.position, dirX);
			missile.playerId = this.hero.id;
			missile.direct = this.hero.heroView.direction;
			this.hero.game.map.createObjectSync(missile, true);
		}
	}
}