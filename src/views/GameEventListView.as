package views
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import events.GameEvent;
	import game.gameData.AwardManager;
	import game.gameData.CollectionManager;
	import game.gameData.HolidayManager;
	import game.gameData.RatingManager;
	import statuses.Status;

	public class GameEventListView extends Sprite
	{
		static private var _instance:GameEventListView = null;

		static private var queue:Vector.<GameEventElementView> = new <GameEventElementView>[];

		private var hidden:Boolean = false;
		private var onResult:Boolean = false;

		private var buttonShow:SimpleButton = null;
		private var buttonHide:SimpleButton = null;
		private var spriteEvents:Sprite = null;

		static public function show():void
		{
			if (!_instance)
				return;
			_instance.show();
		}

		static public function hide():void
		{
			if (!_instance)
				return;
			_instance.hide();
		}

		public function GameEventListView():void
		{
			_instance = this;

			init();

			Experience.addEventListener(GameEvent.LEVEL_CHANGED, onLevel);
			AwardManager.addEventListener(GameEvent.AWARD_CHANGED, onAward);
			CollectionManager.addEventListener(GameEvent.COLLECTION_PICKUP, onCollection);
			RatingManager.addEventListener(GameEvent.LEAGUE_CHANGED, onLeague);
			HolidayManager.addEventListener(GameEvent.HOLIDAY_ELEMENTS, onHoliday);

			EnterFrameManager.addPerSecondTimer(onTime);
		}

		private function init():void
		{
			this.y = 105;

			this.buttonShow = new ButtonEventListShow();
			this.buttonShow.addEventListener(MouseEvent.CLICK, onShow);
			addChild(this.buttonShow);
			new Status(this.buttonShow, gls("Показывать ленту событий во время игры"));

			this.buttonHide = new ButtonEventListHide();
			this.buttonHide.addEventListener(MouseEvent.CLICK, onHide);
			addChild(this.buttonHide);
			new Status(this.buttonHide, gls("Скрывать ленту событий во время игры"));

			this.spriteEvents = new Sprite();
			this.spriteEvents.y = 30;
			addChild(this.spriteEvents);
		}

		private function show():void
		{
			this.onResult = true;

			this.buttonShow.alpha = 1.0;
			this.spriteEvents.visible = true;
		}

		private function hide():void
		{
			this.onResult = false;

			this.buttonShow.alpha = this.hidden ? 0.3 : 1.0;
			this.spriteEvents.visible = !this.hidden;
		}

		private function onShow(e:MouseEvent):void
		{
			this.hidden = false;

			this.buttonShow.alpha = 1.0;
			this.buttonShow.visible = false;
			this.buttonHide.visible = true;

			this.spriteEvents.visible = !this.hidden;
		}

		private function onHide(e:MouseEvent):void
		{
			this.hidden = true;

			this.buttonShow.alpha = this.onResult ? 1.0 : 0.3;
			this.buttonShow.visible = true;
			this.buttonHide.visible = false;
			this.spriteEvents.visible = this.onResult || !this.hidden;
		}

		private function add(type:int, id:int, value:int):void
		{
			var event:GameEventElementView = new GameEventElementView(type, id, value);
			event.y = queue.length * 40;
			this.spriteEvents.addChild(event);

			event.start();
			queue.push(event);
		}

		private function onTime():void
		{
			var needUpdate:Boolean = false;
			for (var i:int = queue.length - 1; i >= 0; i--)
			{
				if (queue[i].expired)
					queue[i].stop();
				if (!queue[i].stopped)
					continue;
				this.spriteEvents.removeChild(queue[i]);
				queue.splice(i, 1);
				needUpdate = true;
			}

			if (!needUpdate)
				return;
			for (i = 0; i < queue.length; i++)
				queue[i].offsetY = i * 40;
		}

		private function onCollection(e:GameEvent):void
		{
			add(GameEventElementView.COLLECTION, e.data['id'], e.data['value']);
		}

		private function onAward(e:GameEvent):void
		{
			add(GameEventElementView.AWARD, e.data['id'], e.data['value']);
		}

		private function onLeague(e:GameEvent):void
		{
			if (e.data['value'] == 0)
				return;
			add(GameEventElementView.LEAGUE, RatingManager.PLAYER_TYPE, e.data['value']);
		}

		private function onLevel(e:GameEvent):void
		{
			add(GameEventElementView.LEVEL, 0, e.data['value']);
		}

		private function onHoliday(e:GameEvent):void
		{
			add(GameEventElementView.HOLIDAY, 0, 0);
		}
	}
}