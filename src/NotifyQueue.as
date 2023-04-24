package
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import dialogs.Dialog;
	import events.ScreenEvent;
	import screens.ScreenGame;
	import screens.Screens;

	import com.greensock.TweenMax;

	public class NotifyQueue
	{
		static private const DELAY:Number = 5000;

		static private var _instance:NotifyQueue;

		private var queue:Array = [];

		private var currentDialog:Dialog = null;
		private var timerShow:Timer = new Timer(DELAY, 1);

		public function NotifyQueue():void
		{
			_instance = this;

			this.timerShow.reset();
			this.timerShow.addEventListener(TimerEvent.TIMER_COMPLETE, onEndShow);

			Screens.instance.addEventListener(ScreenEvent.SHOW, onShowScreen);
		}

		static public function show(dialog:Dialog):void
		{
			if (!allowShow())
				return;

			_instance.queue.push(dialog);
			_instance.checkShow();
		}

		static private function allowShow():Boolean
		{
			return Screens.active is ScreenGame;
		}

		private function onShowScreen(e:ScreenEvent):void
		{
			if (allowShow())
				return;

			clearQueue();
		}

		private function onEndShow(e:TimerEvent):void
		{
			if (this.currentDialog == null)
			{
				checkShow();
				return;
			}

			TweenMax.to(this.currentDialog, 0.5, {'alpha': 0, 'onComplete': onCompleteTween, 'onCompleteParams': [this.currentDialog]});

			this.currentDialog = null;

			checkShow();
		}

		private function onCompleteTween(dialog:Dialog):void
		{
			if (dialog.parent == null)
				return;

			dialog.parent.removeChild(dialog);
		}

		private function checkShow():void
		{
			if (!allowShow())
			{
				clearQueue();
				return;
			}

			if (this.timerShow.running)
				return;

			if (this.queue.length == 0)
				return;

			this.currentDialog = this.queue.shift();
			this.currentDialog.show();

			this.timerShow.reset();
			this.timerShow.start();
		}

		private function clearQueue():void
		{
			this.queue = [];
			this.timerShow.stop();
		}
	}
}