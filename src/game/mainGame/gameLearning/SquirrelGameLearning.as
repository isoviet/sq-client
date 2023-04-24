package game.mainGame.gameLearning
{
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Vec2;

	import events.LearningEvent;
	import events.MovieClipPlayCompleteEvent;
	import game.gameData.LearningData;
	import game.mainGame.SquirrelGame;
	import game.mainGame.gameRecord.CastRecord;
	import game.mainGame.gameRecord.Recorder;

	public class SquirrelGameLearning extends SquirrelGame
	{
		static public const FRIEND_ID:int = Recorder.FIRST_ID - 1;
		static public const SCRAT_ID:int = FRIEND_ID - 1;

		private const FUNCTIONS:Array = [
			[goShaman],
			[unblock, sayShaman],
			[createScrat],
			[unblock],
			[unblock],
			[goFriend]
		];

		public var friendSquirrel:HeroLearning;

		private var mySquirrel:HeroLearning;
		private var shaman:HeroLearning;

		private var scrat:ScratView;
		private var scratMessage:HeroMessage;

		public function SquirrelGameLearning():void
		{
			this.map = new GameMapLearning(this);
			this.squirrels = new SquirrelCollectionLearning();

			this.cast = new CastRecord(this);

			super();
		}

		public function start():void
		{
			this.simulate = false;

			addEventListener(LearningEvent.NAME, onLearning);

			this.squirrels.clear();
			this.squirrels.add(Game.selfId);
			this.squirrels.add(Recorder.FIRST_ID);
			this.squirrels.add(FRIEND_ID);
			this.squirrels.reset();

			this.squirrels.setShamans(new <int>[Recorder.FIRST_ID]);

			this.squirrels.place();
			this.squirrels.show();
			this.simulate = true;

			this.friendSquirrel = this.squirrels.get(FRIEND_ID) as HeroLearning;
			this.friendSquirrel.position = new b2Vec2(1576 / Game.PIXELS_TO_METRE, 354 / Game.PIXELS_TO_METRE);
			this.friendSquirrel.heroView.sendMessage(gls("Моя коллекция, моя!"), 0);
			this.friendSquirrel.dress(LearningData.PIRATE);
			this.friendSquirrel.alwaysJump = true;

			this.shaman = this.squirrels.getShamans()[0] as HeroLearning;
			this.shaman.heroView.playerNameSprite.playerName = gls("Шаман");
			this.shaman.heroView.playerNameSprite.redraw();
			this.mySquirrel = Hero.self as HeroLearning;
			this.mySquirrel.addEventListener(MovieClipPlayCompleteEvent.DEATH, onSelfLearningDie, false, 0, true);

			this.shaman.startReplay();

			TrainingCounter.start();

			Game.stage.focus = Game.stage;
		}

		public function stopJump():void
		{
			unblock();

			this.friendSquirrel.stopJump();

			if (this.shaman.step == 3)	//TODO fix it
				this.shaman.isContinue = true;
		}

		override public function update(timeStep:Number):void
		{
			super.update(timeStep);

			if (!this.scrat)
				return;

			this.scrat.y += 5;

			if (this.scrat.y > this.height + 500)
				deleteScrat();
		}

		public function finish():void
		{
			unblock();
		}

		private function onSelfLearningDie(e:MovieClipPlayCompleteEvent):void
		{
			var playerId:int = Math.abs(this.shaman.id);
			this.shaman.heroView.sendMessage(LearningData.getMessage(playerId, LearningData.getDataByStep(playerId, this.shaman.step)[0]));

			this.mySquirrel.teleportTo(this.map.respawnPosition);
			this.mySquirrel.respawn();

			TrainingCounter.dead();
		}

		private function onLearning(e:LearningEvent):void
		{
			for each(var action:Function in FUNCTIONS[e.step])
				action.apply();
		}

		private function unblock():void
		{
			for each(var hero:HeroLearning in this.squirrels.players)
				hero.isBlockReplay = false;
		}

		private function createScrat():void
		{
			this.scratMessage = new HeroMessage();
			this.scratMessage.setText(gls("АААААААААААААА!"), 0);

			this.scrat = new ScratView();
			this.scrat.setState(Hero.STATE_JUMP);
			this.scrat.x = 2512;
			this.scrat.scaleX *= -1;
			this.scrat.addChild(this.scratMessage);

			this.map.addChild(this.scrat);
			this.map.addChildStarling(this.scrat);
		}

		private function deleteScrat():void
		{
			this.scrat.removeChild(this.scratMessage);
			this.scratMessage.dispose();
			this.scratMessage = null;

			this.map.removeChild(this.scrat);
			this.map.removeChildStarling(this.scrat);
			this.scrat.remove();
			this.scrat = null;
		}

		private function goShaman():void
		{
			unblock();

			this.shaman.startReplay();
		}

		private function goFriend():void
		{
			unblock();

			setTimeout(this.friendSquirrel.heroView.sendMessage, 5000, gls("Спасибо за помощь, шаман! Ещё увидимся!"));
		}

		private function sayShaman():void
		{
			setTimeout(this.shaman.heroView.sendMessage, 500, gls("Отлично."));
		}
	}
}