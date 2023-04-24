package screens
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import dialogs.DialogWelcome;
	import game.gameData.EducationQuestManager;
	import game.gameData.LearningData;
	import game.mainGame.entity.simple.CollectionElement;
	import game.mainGame.entity.simple.LearningCollectionElement;
	import game.mainGame.gameLearning.SquirrelGameLearning;
	import game.mainGame.gameLearning.TrainingCounter;
	import loaders.RuntimeLoader;
	import views.LoadGameAnimation;

	public class ScreenLearning extends Screen
	{
		static public const EVENT_COLLECT:String = "EVENT_COLLECT";

		static public var allowedPerks:Object = {};

		static private var _instance:ScreenLearning;

		private var squirrelGame:SquirrelGameLearning;
		private var displayItems:Array = [];

		private var collectionIcon:LearningCollectionElement;

		public function ScreenLearning():void
		{
			_instance = this;
		}

		static public function newGame():void
		{
			var timer:Timer = new Timer(1, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteTimerInNewGame);
			timer.reset();
			timer.start();
		}

		static public function onComplete():void
		{
			_instance.squirrelGame.finish();
			setTimeout(onCompleteTimerExit, 1500);
		}

		private static function onCompleteTimerInNewGame(e:Event):void
		{
			if (_instance)
				_instance.newGame();
		}

		private static function onCompleteTimerExit():void
		{
			if (_instance)
				_instance.onExit();
		}

		override public function show():void
		{
			this.squirrelGame = new SquirrelGameLearning();
			this.addChild(this.squirrelGame);
			ScreenStarling.instance.addChild(this.squirrelGame.getStarlingView());

			super.show();

			newGame();

			showItems();

			LoadGameAnimation.instance.open();
		}

		override public function hide():void
		{
			super.hide();

			if (this.squirrelGame != null)
			{
				if (ScreenStarling.instance.contains(this.squirrelGame.getStarlingView()))
					ScreenStarling.instance.removeChild(this.squirrelGame.getStarlingView());
				this.squirrelGame.dispose();
				this.squirrelGame = null;
			}

			hideItems();
		}

		private function newGame():void
		{
			setMap();
		}

		private function setMap(data:String = null):void
		{
			if (!this.squirrelGame)
				return;

			if (data == null)
				data = LearningData.getMap();

			this.squirrelGame.map.deserialize(data);
			this.squirrelGame.start();

			this.collectionIcon = new LearningCollectionElement();
			this.collectionIcon.x = 1542;
			this.collectionIcon.y = 216;
			this.collectionIcon.addEventListener(EVENT_COLLECT, onCollect);
			this.squirrelGame.map.add(this.collectionIcon);
			this.collectionIcon.build(this.squirrelGame.world);

			new DialogWelcome().show();
		}

		private function onCollect(e:Event):void
		{
			Hero.self.heroView.showCollectionAnimation(0, CollectionElement.KIND_COLLECTION);

			this.squirrelGame.stopJump();
		}

		private function showItems():void
		{
			for each (var item:Object in LearningData.getImages())
			{
				var image:DisplayObject = new item['image'];
				image.x = item['x'];
				image.y = item['y'];
				addChild(image);

				this.displayItems.push(image);
			}
		}

		private function hideItems():void
		{
			for (var i:int = 0; i < displayItems.length; i++)
				(displayItems[i] as DisplayObject).parent.removeChild(displayItems[i]);
			displayItems = [];
		}

		private function onExit():void
		{
			TrainingCounter.finish();

			EducationQuestManager.complete(EducationQuestManager.FIRST_GAME);

			LoadGameAnimation.instance.close(false);
			RuntimeLoader.load(function():void
			{
				ScreenGame.start(Locations.ISLAND_ID, false, false, 0);
			}, true);
		}
	}
}