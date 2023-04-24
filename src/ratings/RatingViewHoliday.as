package ratings
{
	import flash.filters.ColorMatrixFilter;

	import clans.ClanManager;
	import game.gameData.RatingManager;

	import utils.ArrayUtil;
	import utils.ColorMatrix;

	public class RatingViewHoliday extends RatingViewFriend
	{
		static public const INFO:uint = PlayerInfoParser.NAME | PlayerInfoParser.RATING_HOLIDAY | PlayerInfoParser.EXPERIENCE | PlayerInfoParser.CLAN;

		public function RatingViewHoliday(type:int)
		{
			super(type);
		}

		override protected function createLeague():void
		{
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(-75, 0, 10, 80);

			var view:LeagueHolidayTapeView = new LeagueHolidayTapeView();
			view.x = int((Config.GAME_WIDTH - view.width) * 0.5);
			view.y = 5;
			//view.filters = [new ColorMatrixFilter(colorMatrix)];
			addChild(view);

			var field:GameField = new GameField(gls("Cоревнуйся с друзьями и стань лучшим!"), 0, 10, FORMAT);
			field.x = int((Config.GAME_WIDTH - field.textWidth) * 0.5);
			addChild(field);

			this.fieldTimer = new GameField("", 0, 0, FORMAT);
		}

		override protected function getElement(id:int):RatingElementView
		{
			var answer:RatingElementView = new RatingElementViewHoliday(this.type, id);
			answer.addEventListener(RatingElementView.VALUE_CHANGE, onElementChange);
			return answer;
		}

		override protected function requestElements(ids:Vector.<int>):void
		{
			switch (this.type)
			{
				case RatingManager.PLAYER_TYPE:
					Game.request(ArrayUtil.parseIntVector(ids), INFO, true);
					break;
				case RatingManager.CLAN_TYPE:
					ClanManager.request(ArrayUtil.parseIntVector(ids), true, LOAD_MASK[this.type]);
					break;
			}
		}
	}
}