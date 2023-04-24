package ratings
{
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import events.GameEvent;
	import game.gameData.RatingManager;
	import screens.ScreenRating;
	import screens.Screens;

	import utils.ArrayUtil;
	import utils.DateUtil;
	import utils.FiltersUtil;

	public class RatingViewFriend extends RatingView
	{
		static private const TIME_UPDATE:int = 15;
		static private const COUNT_STEP:int = 8;

		static protected const FILTER_TIMER:GlowFilter = new GlowFilter(0x19545E, 1.0, 4, 4, 16);

		static protected const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFFFFF);

		protected var fieldTimer:GameField = null;
		protected var buttonShowMore:ButtonBase = null;

		private var showMax:int = COUNT_STEP;

		public function RatingViewFriend(type:int)
		{
			super(type);
		}

		override protected function createList():void
		{
			super.createList();

			var buttonInvite:ButtonBase = new ButtonBase(gls("Пригласить друзей"));
			buttonInvite.x = 98 - int(buttonInvite.width * 0.5);
			buttonInvite.y = 60;
			buttonInvite.addEventListener(MouseEvent.CLICK, Game.inviteFriends);
			this.imageBlock.addChild(buttonInvite);

			this.buttonShowMe.x = 450 - this.buttonShowMe.width - 5;

			this.buttonShowMore = new ButtonBase(gls("Показать больше"));
			this.buttonShowMore.x = 455;
			this.buttonShowMore.y = this.buttonShowMe.y;
			this.buttonShowMore.addEventListener(MouseEvent.CLICK, onShowMore);
			addChild(this.buttonShowMore);
		}

		override protected function get imageClass():Class
		{
			return RatingImageNoFriend;
		}

		override protected function get imageText():String
		{
			return gls("У тебя нет друзей-белок,\nс которыми можно было\nбы состязаться.\n\nЗнакомься, общайся и\nприглашай в игру!\nС друзьями всегда\nвеселей!");
		}

		override protected function drawBack():void
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(900, 535, Math.PI / 2, 0, 0);
			this.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			this.graphics.drawRect(0, 0, 900, 535);
		}

		override protected function setScrollPane():void
		{
			this.scrollPane.x = 25;
			this.scrollPane.y = 40;
			this.scrollPane.setSize(860, 450);

			this.scrollPane.graphics.beginFill(0x000000, 0.05);
			this.scrollPane.graphics.drawRect(-2, -2, 844, 454);
		}

		override protected function createLeague():void
		{
			var view:LeagueFriendTapeView = new LeagueFriendTapeView();
			view.x = int((Config.GAME_WIDTH - view.width) * 0.5);
			view.y = 5;
			addChild(view);

			var field:GameField = new GameField(gls("Сезон закончится через:"), 0, 10, new TextFormat(null, 14, 0x084751, true));
			field.x = 445 - field.textWidth;
			addChild(field);

			this.fieldTimer = new GameField("", 455, 8, FORMAT);
			this.fieldTimer.filters = [FILTER_TIMER];
			addChild(this.fieldTimer);
		}

		override protected function updateView():void
		{
			super.updateView();

			this.buttonShowMore.visible = this.elements.length != 0;
		}

		override protected function listen():void
		{
			Game.event(GameEvent.ADD_FRIEND, onAddFriend);
			Game.event(GameEvent.REMOVE_FRIEND, onRemoveFriend);
		}

		override protected function onLeagueChange(e:GameEvent):void
		{}

		override protected function updateLeague():void
		{}

		override protected function get ids():Vector.<int>
		{
			if (Game.friendsIds.length == 0)
				return new Vector.<int>();
			var answer:Vector.<int> = ArrayUtil.valuesToUnicVec(Game.friendsIds);
			answer = answer.slice(0, this.showMax);
			answer.push(Game.selfId);

			return answer;
		}

		override protected function get timeUpdate():int
		{
			return TIME_UPDATE;
		}

		override protected function getElement(id:int):RatingElementView
		{
			var answer:RatingElementView = new RatingElementViewFriend(this.type, id);
			answer.addEventListener(RatingElementView.VALUE_CHANGE, onElementChange);
			return answer;
		}

		override protected function onTimer():void
		{
			if (Screens.active is ScreenRating)
				super.onTimer();

			this.fieldTimer.text = DateUtil.durationDayTime(RatingManager.seasonTime);
		}

		private function onShowMore(e:MouseEvent):void
		{
			this.showMax += COUNT_STEP;

			this.buttonShowMore.enabled = this.showMax < ArrayUtil.valuesToUnic(Game.friendsIds).length;
			this.buttonShowMore.filters = this.buttonShowMore.enabled ? [] : FiltersUtil.GREY_FILTER;

			onDivisionChange(new GameEvent(GameEvent.DIVISION_CHANGED, {'type': this.type}));
		}

		private function onRemoveFriend(e:GameEvent):void
		{
			onDivisionChange(new GameEvent(GameEvent.DIVISION_CHANGED, {'type': this.type, 'reason': RatingManager.LEAVE, 'delta': e.data['value']}));
		}

		private function onAddFriend(e:GameEvent):void
		{
			onDivisionChange(new GameEvent(GameEvent.DIVISION_CHANGED, {'type': this.type, 'reason': RatingManager.JOIN, 'delta': e.data['value']}));
		}
	}
}