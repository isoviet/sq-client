package ratings
{
	import events.GameEvent;
	import game.gameData.HolidayManager;

	import com.api.Player;

	public class RatingElementViewHoliday extends RatingElementViewFriend
	{
		public function RatingElementViewHoliday(type:int, id:int)
		{
			super(type, id);

			this.fieldValueOld.visible = false;
			this.fieldWins.visible = false;
			this.fieldShamanWins.visible = false;
		}

		override protected function eventDelta(value:int):void
		{
			if (this.isSelf)
				HolidayManager.setSelfDelta(value);
		}

		override protected function initListener():void
		{
			if (this.isSelf)
			{
				HolidayManager.addEventListener(GameEvent.HOLIDAY_RATINGS, onChanged);
				HolidayManager.addEventListener(GameEvent.HOLIDAY_ELEMENTS, onChanged);
				Experience.addEventListener(GameEvent.LEVEL_CHANGED, onChanged);
			}
			Game.getPlayer(this.id).addEventListener(RatingViewHoliday.INFO, onPlayerLoaded);
		}

		override protected function get currentRatingCaption():String
		{
			return HolidayManager.ratingCaption;
		}

		override protected function get ratingCaption():String
		{
			return HolidayManager.ratingCaption;
		}

		override protected function get ratingText():String
		{
			return HolidayManager.ratingText;
		}

		override protected function get winsText():String
		{
			return "";
		}

		override protected function get shamanWinsText():String
		{
			return "";
		}

		override protected function setPlayer(player:Player):void
		{
			update(player.name, this.isSelf ? HolidayManager.rating : player['rating_holiday'], player['level'], 0, 0, []);
		}

		override protected function onChanged(e:GameEvent):void
		{
			update(Game.self.name, HolidayManager.rating, Experience.selfLevel, 0, 0, []);
		}

		override protected function get league():int
		{
			return 0;
		}

		override protected function set league(value:int):void
		{}
	}
}