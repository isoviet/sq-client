package utils
{
	public class SaltValue
	{
		private var salt:int = 0;
		private var _value:int = 0;

		private var checkSalt:int = 0;
		private var checkValue:int = 0;

		public function SaltValue(v:int = 0)
		{
			value = v;
		}

		public function get value():int
		{
			var result:int = _value ^ salt;
			var check:int = checkValue ^ checkSalt;
			if (result != check)
				throw new VerifyError(result +":" + check);
			return _value ^ salt;
		}

		public function set value(value:int):void
		{
			salt = int(new Date().getTime());
			checkSalt = Math.random() * int.MAX_VALUE;
			checkValue = value ^ checkSalt;
			_value = value ^ salt;
		}
	}
}