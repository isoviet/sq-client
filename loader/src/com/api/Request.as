package com.api
{
	public class Request
	{
		private var _received:Boolean = false;
		private var _time:Number = 0;

		public var method:String;
		public var options:Object;
		public var onComplete:Function;

		public function Request(method:String, options:Object, onComplete:Function):void
		{
			if (options == null)
				options = new Object();

			this.method = method;
			this.options = options;
			this.onComplete = onComplete;
		}

		public function set received(value:Boolean):void
		{
			this._received = value;
			this._time = new Date().getTime();
		}

		public function get received():Boolean
		{
			return this._received;
		}

		public function get time():Number
		{
			return this._time;
		}
	}
}