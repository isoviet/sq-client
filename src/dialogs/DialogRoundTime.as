package dialogs
{
	import flash.events.MouseEvent;

	public class DialogRoundTime extends DialogNotify
	{
		static private var _instance:DialogRoundTime = null;

		private var _timeLeft:int = 0;

		static public function get instance():DialogRoundTime
		{
			if (!_instance)
				_instance = new DialogRoundTime();
			return _instance;
		}

		public function DialogRoundTime():void
		{
			super();
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			EnterFrameManager.removePerSecondTimer(countDown);
		}

		public function set timeLeft(delay:int):void
		{
			this._timeLeft = delay;
			this.text = gls("ПОТОРОПИСЬ, ОСТАЛОСЬ {0} сек.", this._timeLeft);

			EnterFrameManager.addPerSecondTimer(countDown);
		}

		private function countDown():void
		{
			this._timeLeft--;
			this.text = gls("ПОТОРОПИСЬ, ОСТАЛОСЬ {0} сек.", this._timeLeft);
		}
	}
}