package game.mainGame.gameBattleNet.achieves
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;

	import game.mainGame.IReset;
	import game.mainGame.SquirrelCollection;
	import game.mainGame.SquirrelGame;
	import game.mainGame.events.AchieveEvent;
	import game.mainGame.gameBattleNet.SquirrelGameBattleNet;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.PacketClient;

	public class AchievementController extends Sprite
	{
		private var achievements:Vector.<IDispose> = new Vector.<IDispose>;
		private var achieveQueue:Vector.<String> = new Vector.<String>;

		private var showTimer:Timer = new Timer(650, 1);

		public function AchievementController(game:SquirrelGame):void
		{
			init();
		}

		public function dispose():void
		{
			this.showTimer.stop();

			while (this.achievements.length != 0)
				this.achievements.pop().dispose();
		}

		public function reset():void
		{
			for (var i:int = 0; i < this.achievements.length; i++)
			{
				if (!(this.achievements[i] is IReset))
					continue;

				(this.achievements[i] as IReset).reset();
			}
		}

		private function init():void
		{
			this.showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showNext);

			var kills:AchieveKills = new AchieveKills();
			kills.addEventListener(AchieveEvent.DOUBLE_KILL, addAchieve);
			kills.addEventListener(AchieveEvent.TRIPLE_KILL, addAchieve);
			kills.addEventListener(AchieveEvent.MEGA_KILL, addAchieve);
			this.achievements.push(kills);

			var firstBlood:AchieveFirstBlood = new AchieveFirstBlood(SquirrelGame.instance as SquirrelGameBattleNet);
			firstBlood.addEventListener(AchieveEvent.FIRST_BLOOD, addAchieve);
			this.achievements.push(firstBlood);

			var invulnerable:AchieveFragsWithoutDie = new AchieveFragsWithoutDie();
			invulnerable.addEventListener(AchieveEvent.INVULNERABLE, addAchieve);
			invulnerable.addEventListener(AchieveEvent.RAMBO, addAchieve);
			this.achievements.push(invulnerable);

			var comeback:AchieveComeBack = new AchieveComeBack();
			comeback.addEventListener(AchieveEvent.COMEBACK, addAchieve);
			this.achievements.push(comeback);

			var revenge:AchieveRevenge = new AchieveRevenge(SquirrelGame.instance);
			revenge.addEventListener(AchieveEvent.REVENGE, addAchieve);
			this.achievements.push(revenge);

			var sniper:AchieveSniper = new AchieveSniper(SquirrelGame.instance);
			sniper.addEventListener(AchieveEvent.SNIPER, addAchieve);
			this.achievements.push(sniper);
		}

		private function addAchieve(e:AchieveEvent):void
		{
			if (Hero.self.isDead)
			{
				if (this.achieveQueue.length != 0)
					this.achieveQueue = new Vector.<String>;

				return;
			}

			this.achieveQueue.push(e.type);

			if (this.showTimer.running)
				return;

			showNext();
		}

		private function showNext(e:TimerEvent = null):void
		{
			if (this.achieveQueue.length == 0)
				return;

			showAchieve(this.achieveQueue.shift());

			this.showTimer.reset();
			this.showTimer.start();
		}

		private function showAchieve(type:String):void
		{
			if (!Hero.selfAlive || !SquirrelCollection.instance)
				return;

			var position:Point = new Point(Hero.self.x + 15, Hero.self.y - 42);
			switch(type)
			{
				case AchieveEvent.DOUBLE_KILL:
					new AchievementMessageAnimation(gls("ДВОЙНОЕ УБИЙСТВО"), SquirrelCollection.instance, position.x, position.y);
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.DOUBLE_KILL, 1);
					break;
				case AchieveEvent.TRIPLE_KILL:
					new AchievementMessageAnimation(gls("ТРОЙНОЕ УБИЙСТВО"), SquirrelCollection.instance, position.x, position.y);
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.TRIPLE_KILL, 1);
					break;
				case AchieveEvent.MEGA_KILL:
					new AchievementMessageAnimation(gls("МЕГА ВЫСТРЕЛ"), SquirrelCollection.instance, position.x, position.y);
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.MEGA_KILL, 1);
					break;
				case AchieveEvent.FIRST_BLOOD:
					new AchievementMessageAnimation(gls("ПЕРВАЯ КРОВЬ!"), SquirrelCollection.instance, position.x, position.y);
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.FIRST_BLOOD, 1);
					break;
				case AchieveEvent.INVULNERABLE:
					new AchievementMessageAnimation(gls("НЕУБИВАЕМЫЙ"), SquirrelCollection.instance, position.x, position.y);
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.INVULNERABLE, 1);
					break;
				case AchieveEvent.RAMBO:
					new AchievementMessageAnimation(gls("РЭМБО"), SquirrelCollection.instance, position.x, position.y);
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.RAMBO, 1);
					break;
				case AchieveEvent.COMEBACK:
					new AchievementMessageAnimation(gls("ВОЗВРАЩЕНИЕ"), SquirrelCollection.instance, position.x, position.y);
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.COMEBACK, 1);
					break;
				case AchieveEvent.REVENGE:
					new AchievementMessageAnimation(gls("МЕСТЬ"), SquirrelCollection.instance, position.x, position.y);
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.REVENGE, 1);
					break;
				case AchieveEvent.SNIPER:
					new AchievementMessageAnimation(gls("СНАЙПЕР"), SquirrelCollection.instance, position.x, position.y);
					Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.SNIPER, 1);
					break;
			}
		}
	}
}