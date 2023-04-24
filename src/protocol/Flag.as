package protocol
{
	public class Flag
	{
		static public const MUSIC:int = 1;
		static public const SOUND:int = 2;
		static public const VIRALITY_BONUS:int  = 3;

		static public const SNOWMAN_HELP:int = 9;

		static public const HIDE_LOW_FPS:int = 21;
		static public const HIDE_EXCHANGE:int = 33;

		static public const NOT_BE_SHAMAN:int = 47;
		static public const HIDE_CLAN_INVITES:int = 48;
		static public const NICKNAME_CHANGED:int = 50;

		static public const SHAMAN_SCHOOL_FINISH:int = 19;
		static public const SHAMAN_SCHOOL_STEP:int = 31;

		static public const BATTLE_SCHOOL_FINISH:int = 45;
		static public const BATTLE_SCHOOL_STEP:int = 51;

		static public const MAGIC_SCHOOL_FINISH:int = 5;
		static public const MAGIC_SCHOOL_STEP:int = 6;

		static public const CAMERA_TRACK:int = 52;

		public var type:int;

		private var _value:int;

		private var listeners:Vector.<Function> = new Vector.<Function>();

		public function Flag(type:int, value:int = 0)
		{
			this.type = type;
			this._value = value;
		}

		public function get value():int
		{
			return this._value;
		}

		public function setValue(flagValue:int, send:Boolean = true):void
		{
			if (this._value == flagValue)
				return;

			this._value = flagValue;

			if (send)
				Connection.sendData(PacketClient.FLAGS_SET, this.type, this._value);

			notify();
		}

		public function listen(listener:Function):void
		{
			this.listeners.push(listener);
		}

		public function forget(listener:Function):void
		{
			var index:int = this.listeners.indexOf(listener);

			if (index < 0)
				return;

			this.listeners.splice(index, 1);
		}

		private function notify():void
		{
			for each(var listener:Function in this.listeners)
				listener.apply(null, [this]);
		}
	}
}