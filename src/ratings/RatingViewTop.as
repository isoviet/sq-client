package ratings
{
	import flash.display.GradientType;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.GameConfig;
	import game.gameData.RatingManager;

	import utils.DateUtil;

	public class RatingViewTop extends RatingView
	{
		//TODO CONFIG
		static private const MAX_COUNT:int = 100;
		static private const TIME_UPDATE:int = 15;

		static private const CURRENT_UPDATE:int = 30;
		static private const FAST_UPDATE:int = 10;

		static protected const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFFFFF);
		static protected const FORMAT_SMALL:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF);

		static protected const FILTER_CAPTION:GlowFilter = new GlowFilter(0x663300, 1.0, 4, 4, 16);
		static protected const FILTER_TIMER:GlowFilter = new GlowFilter(0x19545E, 1.0, 4, 4, 16);

		private var filedTimer:GameField = null;
		private var timeTop:int = 0;

		public function RatingViewTop(type:int):void
		{
			super(type);

			this.timeTop = CURRENT_UPDATE;
		}

		override protected function createLeague():void
		{
			var view:LeagueTopTapeView = new LeagueTopTapeView();
			view.x = int((Config.GAME_WIDTH - view.width) * 0.5);
			view.y = 5;
			addChild(view);

			var field:GameField = new GameField(gls("Сезон закончится через:"), 0, 15, new TextFormat(null, 14, 0x084751, true));
			field.x = 695 - int(field.textWidth * 0.5);
			addChild(field);

			this.filedTimer = new GameField("", 0, 35, FORMAT);
			this.filedTimer.filters = [FILTER_TIMER];
			addChild(this.filedTimer);

			addChild(new GameField(gls("Лига чемпионов"), 160, 17, FORMAT)).filters = [FILTER_CAPTION];
			addChild(new GameField(gls("Лучшие из лучших"), 160, 42, FORMAT_SMALL));
		}

		override protected function get imageClass():Class
		{
			return RatingImageNoTop;
		}

		override protected function get imageText():String
		{
			return gls("Лучших чемпионов\nпока нет...\n\nПокажи на что ты\nспособен! Ты можешь\nстать лучшей белкой!\nУ тебя есть все шансы!\nПродолжай играть!");
		}

		override protected function drawBack():void
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(900, 75, Math.PI / 2, 0, 0);

			this.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			this.graphics.drawRect(0, 0, 900, 75);

			matrix.createGradientBox(900, 460, Math.PI / 2, 0, 75);
			this.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			this.graphics.drawRect(0, 75, 900, 460);
		}

		override protected function setScrollPane():void
		{
			this.scrollPane.x = 25;
			this.scrollPane.y = 90;
			this.scrollPane.setSize(860, 400);

			this.scrollPane.graphics.beginFill(0x000000, 0.05);
			this.scrollPane.graphics.drawRect(-2, -2, 844, 404);
		}

		override protected function listen():void
		{
			RatingManager.addEventListener(GameEvent.TOP_CHANGED, onDivisionChange);
		}

		override protected function onLeagueChange(e:GameEvent):void
		{
			if ((this.ids.indexOf(Game.selfId) != -1) || (RatingManager.getSelfLeague(this.type) != (GameConfig.getLeagueCount(this.type) - 1)))
				return;
			RatingManager.requestTop(this.type);
		}

		override protected function updateLeague():void
		{}

		override protected function get ids():Vector.<int>
		{
			return RatingManager.getTopIds(this.type);
		}

		override protected function getElement(id:int):RatingElementView
		{
			var answer:RatingElementView = new RatingElementViewTop(this.type, id);
			answer.addEventListener(RatingElementView.VALUE_CHANGE, onElementChange);
			return answer;
		}

		override protected function updateView():void
		{
			super.updateView();

			this.buttonShowMe.visible = this.buttonShowMe.visible && (this.ids.indexOf(Game.selfId) != -1);
		}

		override protected function get timeUpdate():int
		{
			return TIME_UPDATE;
		}

		override protected function onTimer():void
		{
			super.onTimer();

			this.filedTimer.text = DateUtil.durationDayTime(RatingManager.seasonTime);
			this.filedTimer.x = 695 - int(this.filedTimer.textWidth * 0.5);

			if (this.ids.length != 0 && this.elements.length != 0)
			{
				if (this.ids.indexOf(Game.selfId) == -1)
				{
					if (this.elements[this.elements.length - 1].value <= RatingManager.getScore(this.type))
					{
						RatingManager.requestTop(this.type);
						this.timeTop = CURRENT_UPDATE;
						return;
					}
				}
				else if (this.elements.length == MAX_COUNT && this.elements[MAX_COUNT - 1].id == Game.selfId)
					this.timeTop = Math.min(this.timeTop, FAST_UPDATE);
			}

			if (this.timeTop <= 0)
				return;
			this.timeTop--;
			if (timeTop > 0)
				return;
			this.timeTop = CURRENT_UPDATE;
			RatingManager.requestTop(this.type);
		}
	}
}