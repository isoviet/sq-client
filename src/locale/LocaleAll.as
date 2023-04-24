package locale
{
	import loaders.LocaleLoader;

	public class LocaleAll
	{
		static private var base:Locale = null;

		static public function gls(input:String, ...rest):String
		{
			if (base == null)
				base = new Locale(Config.RU_LOCALE, LocaleLoader.data);
			return base.gls(input, rest);
		}
	}
}