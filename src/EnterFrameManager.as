package
{
	import flash.events.Event;
	import flash.utils.getTimer;

	import dragonBones.animation.WorldClock;

	public class EnterFrameManager
	{
		static private var _instance:EnterFrameManager = new EnterFrameManager();

		static private var listeners:Vector.<Function> = new Vector.<Function>();
		static private var listenersPriorities:Vector.<int> = new Vector.<int>();

		static private var listenersPerSoncond:Vector.<Function> = new Vector.<Function>();

		static private var lastUpdate:int = 0;
		static private var elapsedTime:int = 0;
		static private var lastDelay:int = 0;

		public function EnterFrameManager():void
		{
			if (_instance)
				return;

			Game.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		static public function addListener(listener:Function, priority:int = 0):void
		{
			if (listeners.indexOf(listener) != -1)
				return;

			if (listeners.length == 0)
			{
				listeners.push(listener);
				listenersPriorities.push(priority);
				return;
			}

			for (var i:int = listenersPriorities.length - 1; i >= 0; i--)
			{
				if (i == listenersPriorities.length - 1 && listenersPriorities[i] <= priority)
				{
					listeners.push(listener);
					listenersPriorities.push(priority);
					break;
				}

				if (listenersPriorities[i] <= priority)
				{
					listenersPriorities.splice(i + 1, 0, priority);
					listeners.splice(i + 1, 0, listener);
					break;
				}

				if (i != 0)
					continue;

				listenersPriorities.splice(0, 0, priority);
				listeners.splice(0, 0, listener);
			}
		}

		static public function removeListener(listener:Function):void
		{
			var index:int = listeners.indexOf(listener);
			if (index == -1)
				return;

			listeners.splice(index, 1);
			listenersPriorities.splice(index, 1);
		}

		static public function addPerSecondTimer(listener:Function):void
		{
			if (listenersPerSoncond.indexOf(listener) != -1)
				return;
			listenersPerSoncond.push(listener);
		}

		static public function removePerSecondTimer(listener:Function):void
		{
			var index:int = listenersPerSoncond.indexOf(listener);
			if (index == -1)
				return;
			listenersPerSoncond.splice(index, 1);
		}

		static public function get delay():Number
		{
			return lastDelay / 1000;
		}

		static private function onEnterFrame(e:Event):void
		{
			WorldClock.clock.advanceTime(-1);

			lastDelay = getTimer() - lastUpdate;
			lastUpdate = getTimer();

			var listenersCopy:Vector.<Function> = listeners.concat();
			for (var i:int = listenersCopy.length - 1; i >= 0; i--)
				if (listenersCopy[i] is Function)
					listenersCopy[i]();

			elapsedTime += lastDelay;
			if (elapsedTime >= 1000)
			{
				elapsedTime -= 1000;
				listenersCopy = listenersPerSoncond.concat();

				for (i = listenersCopy.length - 1; i >= 0; i--)
					if (listenersCopy[i] is Function) listenersCopy[i]();
			}
		}
	}
}