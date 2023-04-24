package utils
{
	public class EmailValidatorUtil
	{
		static private const EMAIL_REGEX:RegExp = /^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/i;

		static public function validateEmail(email:String):Boolean
		{
			return Boolean(email.match(EMAIL_REGEX));
		}
	}
}