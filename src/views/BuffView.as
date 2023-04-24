package views
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import game.mainGame.gameBattleNet.BuffRadialView;

	public class BuffView extends Sprite
	{
		private const TOP_OFFSET:int = 50;
		private const RIGHT_OFFSET:int = 60;

		private var buffArray:Array = [];

		private var completeListeners:Dictionary = new Dictionary();
		private var updateListeners:Dictionary = new Dictionary();

		public function BuffView():void
		{
			super();

			this.x = Config.GAME_WIDTH - RIGHT_OFFSET;
			this.y = TOP_OFFSET;
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
			onChangeScreenSize();
		}

		private function onChangeScreenSize(e: Event = null): void
		{
			this.x = Game.starling.stage.stageWidth - RIGHT_OFFSET;
			this.y = TOP_OFFSET;
		}

		public function addBuff(buff:BuffRadialView, buffTimer:Timer):void
		{
			for each (var obj:BuffRadialView in this.buffArray)
				obj.x -= 40;
			buff.x = 0;
			buff.y = 0;
			buff.update(0);
			this.buffArray.unshift(buff);
			addChild(buff);

			if (!buffTimer)
				return;

			buffTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
			this.completeListeners[buffTimer] = buff;

			buffTimer.addEventListener(TimerEvent.TIMER, buffUpdate);
			this.updateListeners[buffTimer] = buff;
		}

		public function resetBuff(buff:BuffRadialView, buffTimer:Timer):void
		{
			removeBuff(buff);

			if (!(buffTimer in this.completeListeners))
				return;

			buffTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
			delete this.completeListeners[buffTimer];

			if (!(buffTimer in this.updateListeners))
				return;

			buffTimer.removeEventListener(TimerEvent.TIMER, buffUpdate);
			delete this.updateListeners[buffTimer];
		}

		public function dispose():void
		{
			for (var timer:* in this.completeListeners)
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			for (timer in this.updateListeners)
				timer.removeEventListener(TimerEvent.TIMER, buffUpdate);

			FullScreenManager.instance().removeEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
		}

		private function onComplete(e:TimerEvent):void
		{
			var timer:Timer = e.target as Timer;

			if (!(timer in this.completeListeners))
				return;

			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
			removeBuff(this.completeListeners[timer]);
			delete this.completeListeners[timer];

			if (!(timer in this.updateListeners))
				return;

			timer.removeEventListener(TimerEvent.TIMER, buffUpdate);
			delete this.updateListeners[timer];
		}

		private function removeBuff(buff:BuffRadialView):void
		{
			var index:int = this.buffArray.indexOf(buff);
			if (index == -1)
				return;
			this.buffArray.splice(index, 1);
			if (contains(buff))
				removeChild(buff);
			for (var i:int = index; i < this.buffArray.length; i++)
				this.buffArray[i].x += 40;
		}

		private function buffUpdate(e:TimerEvent):void
		{
			var timer:Timer = e.target as Timer;

			if (!(timer in this.updateListeners))
				return;

			this.updateListeners[timer].update(int(timer.currentCount / timer.repeatCount * 100));
		}
	}
}