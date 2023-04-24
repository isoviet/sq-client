package loaders
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	import locale.Locale;

	public class LocaleLoader extends LibLoader
	{
		[Embed(source = "en_loader.lp", mimeType = "application/octet-stream")]
		static private const EN_LANG_PACK:Class;

		static private var base:Locale = null;

		static public var data:ByteArray = null;

		static public function gls(input:String, ...rest):String
		{
			if (base == null)
				base = new Locale(Config.RU_LOCALE, getLangPack());
			return base.gls(input, rest);
		}

		static private function getLangPack():ByteArray
		{
			return new EN_LANG_PACK();
		}

		override public function loadBytes(dataClass:Class):void
		{
			data = new dataClass();

			onComplete(new Event(Event.COMPLETE));
		}

		override protected function onLoaded(e:Event):void
		{
			data = this.urlLoader.data;

			onComplete(e);
		}
	}
}