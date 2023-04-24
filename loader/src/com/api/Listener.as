package com.api
{
	public dynamic class Listener
	{
		private var listeners:Array = new Array();
		private var load:int = 0;
		private var loaded:int = 0;

		public function Listener(load:int):void
		{
			super();

			this.load = load;
		}

		public function listen(callback:Function, param:*):void
		{
			if (!notify(callback, param))
				this.listeners.push({'callback': callback, 'param': param});
		}

		public function needLoad():Boolean
		{
			if (this.loaded != 0)
				return false;
			if (this.listeners.length != 0)
				return false;
			return true;
		}

		public function setLoaded(type:int):void
		{
			this.loaded |= type;
			notifyAll();
		}

		public function loadData(data:Object):void
		{
			for (var key:String in data)
				this[key] = data[key];
		}

		protected function notify(callback:Function, param:*):Boolean
		{
			if (this.loaded != this.load)
				return false;

			if (param != null)
				callback(this, param);
			else
				callback(this);

			return true;
		}

		protected function notifyAll():void
		{
			var stale:Array = new Array();

			for each (var listener:Object in this.listeners)
			{
				if (notify(listener['callback'], listener['param']))
					continue;

				stale.push(listener);
			}

			this.listeners = stale;
		}
	}
}