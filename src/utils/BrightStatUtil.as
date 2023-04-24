package utils
{
	import screens.ScreenLocation;

	import com.api.Services;

	import ru.freetopay.brightstat.BrightStat;

	public class BrightStatUtil
	{
		static private var isAllow:Boolean = false;

		static public function init():void
		{
			Services.friends.get(onGet);
		}

		static public function canOffer():Boolean
		{
			return isAllow;
		}

		static public function get url():String
		{
			return ru.freetopay.brightstat.BrightStat.getRedirectURL("registration");
		}

		static public function count(key:String):void
		{
			if (Game.self.type != Config.API_VK_ID)
				return;
			ru.freetopay.brightstat.BrightStat.eventComplete(key);
		}

		static private function onGet(data:Array):void
		{
			var age:int = DateUtil.getYearsOld(Game.self["bdate"]);
			ru.freetopay.brightstat.BrightStat.onInit = onInit;
			ru.freetopay.brightstat.BrightStat.initWithFullUserInfo(brandingId, Services.session['viewer_id'], data.length, Game.self["sex"] == "1" ? "1" : "2", age, Game.self["city"], Game.self["country"]);
		}

		static private function onInit():void
		{
			BrightStat.checkAvailability(onCheck);
		}

		static private function onCheck(value:Boolean):void
		{
			isAllow = value;

			if (!value || Experience.selfLevel < Game.LEVEL_TO_SHOW_TV)
				return;
			ScreenLocation.addBrightStatOffer();
		}

		static private function get brandingId():String
		{
			return "vk_belki_cheetos";
		}
	}
}