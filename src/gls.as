package
{
	import locale.Locale;

	CONFIG::client{import locale.LocaleAll;}

	public function gls(input:String, ...rest):String
	{
		CONFIG::client{
			rest.unshift(input);
			return LocaleAll.gls.apply(null, rest);
		}

		return Locale.replace(input, rest);
	}
}