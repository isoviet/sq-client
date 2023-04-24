package game.mainGame.gameSchool
{
	import events.MovieClipPlayCompleteEvent;
	import footers.FooterGame;
	import game.mainGame.Cast;
	import game.mainGame.SquirrelCollection;
	import game.mainGame.SquirrelGame;
	import game.mainGame.perks.mana.PerkFactory;
	import screens.ScreenSchool;

	import protocol.PacketServer;

	public class SquirrelGameSchool extends SquirrelGame
	{
		public function SquirrelGameSchool():void
		{
			init();

			super();
		}

		override public function dispose():void
		{
			if (Hero.self)
				Hero.self.removeEventListener(MovieClipPlayCompleteEvent.DEATH, onSelfLearningDie);
			super.dispose();
		}

		public function start():void
		{
			this.simulate = false;
			if (Hero.self)
				Hero.self.removeEventListener(MovieClipPlayCompleteEvent.DEATH, onSelfLearningDie);

			this.squirrels.clear();
			this.squirrels.add(Game.selfId);
			Hero.self.addEventListener(MovieClipPlayCompleteEvent.DEATH, onSelfLearningDie, false, 0, true);
			this.squirrels.reset();

			this.squirrels.setShamans(ScreenSchool.type == ScreenSchool.SHAMAN ? new <int>[Game.selfId] : new Vector.<int>());

			this.squirrels.place();
			this.squirrels.show();
			FooterGame.gameState = PacketServer.ROUND_START;
			FooterGame.hero = Hero.self;
			this.simulate = true;
		}

		protected function init():void
		{
			this.map = new GameMapSchool(this);
			this.cast = new Cast(this);
			this.squirrels = new SquirrelCollection();
		}

		private function onSelfLearningDie(e:MovieClipPlayCompleteEvent):void
		{
			if (this.squirrels.activeSquirrelCount > 0 && (PerkFactory.SKILL_RESURECTION in ScreenSchool.allowedPerks))
				return;
			ScreenSchool.restart();
		}
	}
}