package utils
{
	import flash.events.Event;

	import by.blooddy.crypto.serialization.JSON;

	import com.api.PersonalOfferEvent;
	import com.api.Services;

	public class PersonalOfferUtil
	{
		static public var offers:Array = null;

		static public function getPersonalOffers():void
		{
			if (Game.self.type != Config.API_VK_ID || Services.isOAuth)
				return;

			Services.addEventListener(PersonalOfferEvent.OFFER, onPersonalOffer);
			Services.addEventListener(PersonalOfferEvent.OFFER, Offers.checkOffers);
			Services.showPersonalOffers();
		}

		static private function onPersonalOffer(e:PersonalOfferEvent):void
		{
			if (e.offers.length < 1)
				return;

			offers = e.offers;

			var offersIds:Array = [];
			for each (var offer:Object in offers)
			{
				if (!("id" in offer))
					continue;
				offersIds.push(offer['id']);
			}

			var variables:Object = {};
			variables['sid'] = 253;
			variables['uid'] = Game.self.nid;
			variables['sex'] = (Game.self['sex'] == 1 ? "f" : "m");

			if (Game.self['bdate'] == 0)
				variables['age'] = getYearsOld(Game.self['bdate']);

			variables['lead_ids'] = String(offersIds);

			LoaderUtil.load("http://www.freetopay.ru/get_vk_banners.php", false, variables, onLoadedOffers);
		}

		static private function onLoadedOffers(e:Event):void
		{
			try
			{
				var data:Object = by.blooddy.crypto.serialization.JSON.decode(e.currentTarget.data);

				if (data['Offers'].length == 0)
					return;

				Game.addOffersToQuest(data['Offers']);
			}
			catch(error: Error)
			{
				Logger.add('Error: PersonalOfferUtil/onLoadedOffers: ' + e.currentTarget.data);
			}
		}

		static private function getYearsOld(seconds:Number):int
		{
			if (seconds == 0)
				return 0;

			var now:Date = new Date();
			var birth:Date = new Date(seconds * 1000);
			var years:int = now.fullYear - birth.fullYear;

			if (birth.month > now.month || (birth.month == now.month && birth.date > now.date))
				years--;

			if (years < 0)
				return 0;
			return years;
		}
	}
}