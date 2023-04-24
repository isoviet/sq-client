package com.sa
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import com.api.Request;

	public class Processor
	{
		static private const MAX_REQUESTS:int = 3;
		static private const MAX_THRESHOLD:int = 1200;

		static private var _instance:Processor;

		private var provider:Provider = new Provider();

		private var executed:Array = new Array();
		private var queued:Array = new Array();

		private var timer:Timer = new Timer(Processor.MAX_THRESHOLD, 1);

		public function Processor():void
		{
			_instance = this;

			super();

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, sendQueued);
		}

		static public function execute(method:String, options:Object = null, onComplete:Function = null):void
		{
			_instance.startRequest(method, options, onComplete);
		}

		private function startRequest(method:String, options:Object, onComplete:Function):void
		{
			var request:Request = new Request(method, options, onComplete);
			request.received = false;

			if (!checkCanExecute())
				doQueue(request);
			else
				doExecute(request);
		}

		private function doQueue(request:Request):void
		{
			this.queued.push(request);
			this.timer.start();
		}

		private function doExecute(request:Request):void
		{
			this.executed.push(request);
			this.provider.execute(request);
		}

		private function sendQueued(e:TimerEvent):void
		{
			while (checkCanExecute() && this.queued.length != 0)
			{
				var request:Request = this.queued.shift();
				doExecute(request);
			}

			if (this.queued.length == 0)
				return;

			this.timer.start();
		}

		private function checkCanExecute():Boolean
		{
			var time:Number = new Date().getTime();
			var count:int = 0;

			for (var i:int = 0; i < this.executed.length; i++)
			{
				var request:Request = this.executed[i];

				if (!request.received || time - request.time < Processor.MAX_THRESHOLD)
				{
					count++;
					continue;
				}

				this.executed.splice(i, 1);
				i--;
			}

			return (count < Processor.MAX_REQUESTS);
		}
	}
}