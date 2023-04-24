package game.mainGame.perks.shaman
{
	import flash.display.DisplayObject;

	import Box2D.Common.Math.b2Vec2;

	import chat.ChatDeadServiceMessage;
	import screens.ScreenGame;

	public class PerkShamanTeleport extends PerkShamanSelective
	{
		static private const RADIUS:int = 100 / Game.PIXELS_TO_METRE;

		private var radius:Number;
		private var radiusView:DisplayObject = null;

		public function PerkShamanTeleport(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_TELEPORT;

			this.radius = RADIUS * (1 + countBonus() / 100);
			this.selectionsCount = countExtraBonus();
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.radiusView)
				this.radiusView = new PerkRadius();

			this.radiusView.width = this.radiusView.height = int(this.radius * 2 * Game.PIXELS_TO_METRE);
			this.radiusView.y = - Hero.Y_POSITION_COEF;

			this.hero.addChild(this.radiusView);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.radiusView && this.radiusView.parent)
				this.radiusView.parent.removeChild(this.radiusView);
		}

		override protected function set selectedHero(heroId:int):void
		{
			if (!this.hero.game)
				return;

			var hero:Hero = this.hero.game.squirrels.get(heroId);

			if (!hero || !checkDistance(hero))
				return;

			super.selectedHero = heroId;

			hero.magicTeleportTo(this.hero.position);

			ScreenGame.sendMessage(hero.player.id, "", ChatDeadServiceMessage.TELEPORT_PERK);
		}

		private function checkDistance(hero:Hero):Boolean
		{
			var distance:b2Vec2 = this.hero.position.Copy();
			distance.Subtract(hero.position.Copy());

			return distance.Length() < this.radius;
		}
	}
}