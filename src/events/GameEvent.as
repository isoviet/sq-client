package events
{
	import flash.events.Event;

	public class GameEvent extends Event
	{

		//UNIVERSAL
		static public const SHOWED:String = "GameEvent.SHOWED";
		static public const HIDED:String = "GameEvent.HIDED";
		static public const CHANGED:String = "GameEvent.CHANGED";

		//PLAYER
		static public const BALANCE_CHANGED:String = "GameEvent.BALANCE_CHANGED";
		static public const ENERGY_CHANGED:String = "GameEvent.ENERGY_CHANGED";
		static public const MANA_CHANGED:String = "GameEvent.MANA_CHANGED";
		static public const MAX_POWERS_CHANGED:String = "GameEvent.MAX_POWERS_CHANGED";
		static public const EXPERIENCE_CHANGED:String = "GameEvent.EXPERIENCE_CHANGED";
		static public const LEVEL_CHANGED:String = "GameEvent.LEVEL_CHANGED";
		static public const FEATHERS_CHANGED:String = "GameEvent.FEATHERS_CHANGED";

		//AWARD
		static public const AWARD_CHANGED:String = "GameEvent.AWARD_CHANGED";
		static public const AWARD_UPDATE:String = "GameEvent.AWARD_UPDATE";

		//RATING
		static public const LEAGUE_CHANGED:String = "GameEvent.LEAGUE_CHANGED";
		static public const RATING_CHANGED:String = "GameEvent.RATING_CHANGED";
		static public const DIVISION_CHANGED:String = "GameEvent.DIVISION_CHANGED";
		static public const SEASON_CHANGED:String = "GameEvent.SEASON_CHANGED";
		static public const TOP_CHANGED:String = "GameEvent.TOP_CHANGED";
		static public const PLACE_CHANGED:String = "GameEvent.PLACE_CHANGED";

		//FRIENDS
		static public const ADD_FRIEND:String = "GameEvent.ADD_FRIEND";
		static public const REMOVE_FRIEND:String = "GameEvent.REMOVE_FRIEND";
		static public const FRIENDS_UPDATE:String = "GameEvent.FRIENDS_UPDATE";

		//PROFILE
		static public const INTERIOR_CHANGE:String = "GameEvent.INTERIOR_CHANGE";
		static public const PROFILE_PLAYER_CHANGED:String = "GameEvent.PROFILE_PLAYER_CHANGED";

		//VIP
		static public const VIP_START:String = "GameEvent.VIP_START";
		static public const VIP_END:String = "GameEvent.VIP_END";

		//CLOSEOUT
		static public const CLOSEOUT_START:String = "GameEvent.CLOSEOUT_START";
		static public const CLOSEOUT_END:String = "GameEvent.CLOSEOUT_END";

		//PRODUCE
		static public const PRODUCE_END:String = "GameEvent.PRODUCE_END";
		static public const PRODUCE_START:String = "GameEvent.PRODUCE_START";
		static public const PRODUCE_BONUS_END:String = "GameEvent.PRODUCE_BONUS_END";
		static public const PRODUCE_BONUS:String = "GameEvent.PRODUCE_BONUS";
		static public const PRODUCE_BONUS_START:String = "GameEvent.PRODUCE_BONUS_START";
		static public const PRODUCE_UPDATE:String = "GameEvent.PRODUCE_UPDATE";

		//DAILY_BOUNS
		static public const DAILY_BONUS_UPDATE:String = "GameEvent.DAILY_BONUS_UPDATE";
		static public const DAILY_BONUS_GET:String = "GameEvent.DAILY_BONUS_GET";

		//COLLECTIONS
		static public const COLLECTION_PICKUP:String = "GameEvent.COLLECTION_PICKUP";

		//MAIL
		static public const EVENT_CHANGE:String = "GameEvent.EVENT_CHANGE";
		static public const GIFT_CHANGE:String = "GameEvent.GIFT_CHANGE";
		static public const ON_CHANGE:String = "GameEvent.ON_CHANGE";

		//DAILY_QUEST
		static public const DAILY_QUEST_PROGRESS:String = "GameEvent.DAILY_QUEST_PROGRESS";
		static public const DAILY_QUEST_CHANGED:String = "GameEvent.DAILY_QUEST_CHANGED";
		static public const DAILY_QUEST_COMPLETE:String = "GameEvent.DAILY_QUEST_CHANGED";
		static public const DAILY_QUEST_FAIL:String = "GameEvent.DAILY_QUEST_CHANGED";

		//EDUCATION_QUEST
		static public const EDUCATION_QUEST_PROGRESS:String = "GameEvent.EDUCATION_QUEST_PROGRESS";
		static public const EDUCATION_QUEST_CHANGED:String = "GameEvent.EDUCATION_QUEST_CHANGED";
		static public const EDUCATION_QUEST_FINISH:String = "GameEvent.EDUCATION_QUEST_FINISH";

		//EXPIRATIONS
		static public const EXPIRATIONS_CHANGE:String = "GameEvent.EXPIRATIONS_CHANGE";

		//BUNDLE
		static public const BUNDLE_UPDATE:String = "GameEvent.BUNDLE_UPDATE";
		static public const BUNDLE_REFILL:String = "GameEvent.BUNDLE_REFILL";

		//HOLIDAY
		static public const HOLIDAY_RATINGS:String = "GameEvent.HOLIDAY_RATINGS";
		static public const HOLIDAY_ELEMENTS:String = "GameEvent.HOLIDAY_ELEMENTS";
		static public const HOLIDAY_LOTTERY:String = "GameEvent.HOLIDAY_LOTTERY";
		static public const HOLIDAY_TICKETS:String = "GameEvent.HOLIDAY_TICKETS";
		static public const HOLIDAY_CLOTHES:String = "GameEvent.HOLIDAY_CLOTHES";

		//DEFERRED_BONUS
		static public const DEFERRED_BONUS_UPDATE:String = "GameEvent.DEFERRED_BONUS_UPDATE";
		static public const DEFERRED_BONUS_ACCEPT:String = "GameEvent.DEFERRED_BONUS_ACCEPT";
		static public const DEFERRED_BONUS_REJECT:String = "GameEvent.DEFERRED_BONUS_REJECT";

		//CLOTHES
		static public const CLOTHES_STORAGE_CHANGE_MAGIC:String = "GameEvent.CLOTHES_STORAGE_CHANGE_MAGIC";
		static public const CLOTHES_STORAGE_CHANGE:String = "GameEvent.CLOTHES_STORAGE_CHANGE";
		static public const CLOTHES_HERO_CHANGE:String = "GameEvent.CLOTHES_HERO_CHANGE";

		//AMUR
		static public const AMUR_BALANCE_CHANGED:String = "GameEvent.AMUR_BALANCE_CHANGED";
		static public const AMUR_PAGE_LOADED:String = "GameEvent.AMUR_PAGE_LOADED";

		//HOT_WEEKEND
		static public const HOT_WEEKEND_CHANGED:String = "GameEvent.HOT_WEEKEND_CHANGED";

		//SMILES
		static public const SMILES_CHANGED:String = "GameEvent.SMILES_CHANGED";

		public var data:Object = null;

		public function GameEvent(type:String, data:Object = null):void
		{
			super(type, false, true);

			this.data = data;
		}
	}
}