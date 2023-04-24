package
{
	import flash.display.DisplayObject;

	import screens.ScreenLocation;
	import views.ButtonBanner;

	import com.api.PersonalOfferEvent;

	public class Offers
	{
		static private const OFFERS:Array = [];

		static private var activeOffers:Array = [];

		static public function checkOffers(e:PersonalOfferEvent):void
		{
			var offers:Array = e.offers;
			if (offers.length == 0)
				return;

			for (var i:int = 0, length:int = offers.length; i < length; i++)
			{
				if (OFFERS.indexOf(int(offers[i].id)) != -1)
					addOffer(int(offers[i].id));
			}
		}

		static public function haveOffer(id:int):Boolean
		{
			return activeOffers.indexOf(id) != -1;
		}

		static private function addOffer(id:int):void
		{
			activeOffers.push(id);

			var offerButton:DisplayObject;

			switch (id)
			{
				//case:
				//	break;
				default:
					return;
			}

			ScreenLocation.addThzOffer(new ButtonBanner(offerButton));
		}
	}
}