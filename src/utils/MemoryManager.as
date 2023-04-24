package utils
{
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.system.System;

	public class MemoryManager
	{
		static public const LIMIT_CRITICAL:Number = 1024*1024*600;
		static public const LIMIT_WARNING:Number = 1024*1024*500;

		static public const IMMINENCE_DEFAULT:Number = 0.75;
		static public const IMMINENCE_SAVE_MEMORY:Number = 0.25;
		static public const IMMINENCE_SAVE_PROCESSOR:Number = 1;

		static private const FORCED_ITERATION:int = 1;

		static public var availible:Boolean = true;
		static private var current:Number = IMMINENCE_DEFAULT;

		/**
		 * попытка принудительного вызова GC
		 */
		static public function forceClean():void
		{
			if (!availible)
				return;
			System.pauseForGCIfCollectionImminent(0);
			//вызов через исключения
			for (var i:int = 0; i < FORCED_ITERATION; i++)
			{
				try
				{
					new LocalConnection().connect('Crio');
					new LocalConnection().connect('Crio');
				}
				catch (er2:*)
				{
					Logger.add("force clean memory");
				}
			}
			System.pauseForGCIfCollectionImminent(current);
		}

		/**
		 * контроль памяти
		 */
		static public function control():void
		{
			if (!availible)
				return;

			if(exceeded(MemoryManager.LIMIT_CRITICAL))
				forceClean();
			else if(exceeded(MemoryManager.LIMIT_WARNING))
				safeClean();
		}

		/**
		 * установить порог срабатывания GC
		 * @param value порог срабатывания GC
		 */
		static public function imminence(value:Number):void
		{
			if (!availible)
				return;

			current = value;
			System.pauseForGCIfCollectionImminent(value);
		}

		/**
		 * превышение некоторого порога памяти
		 * @param compare порог сравнения
		 * @return true порог превышен
		 */
		static public function exceeded(compare:Number):Boolean
		{
			return System.totalMemory >= compare;
		}

		/**
		 * мягкая попытка запустить GC
		 */
		static private function safeClean():void
		{
			System.pauseForGCIfCollectionImminent(0);
			var A:Point = new Point();
			A = null;
			var B:String = new String('1234567812345678');
			B = null;
			var C:Array = new Array();
			for (var i:int = 0; i < 256; i++)
				C.push(new String('a'));
			for (i = 0; i < 256; i++)
				delete C[i];
			C = null;
			System.pauseForGCIfCollectionImminent(current);
		}
	}
}