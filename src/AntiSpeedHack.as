package
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import protocol.Connection;

	public class AntiSpeedHack
	{
		public var date:Date;

		private var failCount:int = 0;

		public function AntiSpeedHack():void
		{
			var timer:Timer = new Timer(5000);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.reset();
			timer.start();
		}

		private function onTimer(e:Event):void
		{
			if (date == null)
			{
				date = new Date();
				return;
			}

			var curDate:Date = new Date();

			var value:Number = curDate.getTime() - date.getTime() - 5000;
			if (value < -10)
				failCount++;
			else
				failCount--;
			failCount = Math.max(failCount, 0);
			this.date = curDate;
			if (failCount >= 10)
			{
				Connection.disconnect();
				//throw new Error("SpeedHack Detected!!", 999);
			}
		}
	}
}