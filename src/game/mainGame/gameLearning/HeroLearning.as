package game.mainGame.gameLearning
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.gameData.LearningData;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.gameRecord.Recorder;

	import dragonBones.animation.Animation;
	import dragonBones.animation.WorldClock;

	public class HeroLearning extends Hero
	{
		static private const DELAY:int = 20 * 1000;

		static private const BONES:Array = ["Cap", "Glasses", "Left_Boot", "Left_glove", "Left_sleeve_01", "Left_sleeve_02", "Pants", "Pants_haunch", "Right_Boot_stand", "Right_glove", "Tail_accessory_02", "T-shirt"];

		public var recorder:Recorder = new Recorder();

		public var step:int = -1;

		public var isBlockReplay:Boolean = false;
		public var isContinue:Boolean = false;

		public var alwaysJump:Boolean = false;

		private var intervalId:uint;

		public function HeroLearning(playerId:int, world:b2World, x:int = 0, y:int = 0)
		{
			super(playerId, world, x, y);

			if (this.isSelf)
				return;

			this.recorder.playerId = playerId;
		}

		override public function get isSelf():Boolean
		{
			return this.id == Game.selfId;
		}

		override public function get game():SquirrelGame
		{
			return super.game as SquirrelGameLearning;
		}

		public function dress(type:String = null):void
		{
			for each(var name:String in BONES)
				this.heroView.armature.getBone(name).displayController = type ? type : null;

			if (!type)
				return;

			this.heroView.armature.animation.gotoAndPlay(type, -1, -1, NaN, 0, type, Animation.SAME_GROUP);
			this.heroView.armature.invalidUpdate();

			WorldClock.clock.advanceTime(-1);
		}

		override public function remove():void
		{
			super.remove();

			if (this.intervalId != 0)
				clearInterval(this.intervalId);
			this.intervalId = 0;

			this.recorder.stopRecord();
			this.recorder.dispose();
			this.recorder = null;
		}

		override public function show():void
		{
			if (this.inHollow)
				return;

			super.show();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.isSelf || this.inHollow)
				return;

			if (this.alwaysJump)
				this.jump(true);

			if (this.recorder.isReplay || !this.squirrelIsHere)
				return;

			startReplay();
		}

		public function stopJump():void
		{
			this.alwaysJump = false;
			startReplay();
		}

		public function startReplay():void
		{
			if (!this.isContinue && (this.isBlockReplay || this.alwaysJump))
				return;

			this.step++;

			if (this.step == LearningData.OPEN_DOOR_STEP && this.shaman)
				(this.game.map.getByName(LearningData.DOOR) as GameBody).ghost = true;

			var playerId:int = Math.abs(this.id);
			var data:Array = LearningData.getDataByStep(playerId, this.step);
			if (!data)
				return;

			var message:String = LearningData.getMessage(playerId, data[0]);
			this.heroView.sendMessage(message);

			if (this.intervalId)
				clearInterval(this.intervalId);
			this.intervalId = setInterval(this.heroView.sendMessage, DELAY, message);

			this.recorder.actions = LearningData.getAction(playerId, data[1]);
			this.recorder.startReplay();

			this.isBlockReplay = !this.isContinue && data[1] < 0;
			this.isContinue = false;
		}

		private function get squirrelIsHere():Boolean
		{
			if (Hero.self.position.x > this.position.x)
				return true;

			var pos:b2Vec2 = Hero.self.position.Copy();
			pos.Subtract(this.position);

			return !(pos.Length() > 5 || pos.Length() == 0);
		}
	}
}