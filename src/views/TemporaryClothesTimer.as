package views
{
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	import events.GameEvent;
	import game.gameData.ClothesManager;

	import utils.DateUtil;

	public class TemporaryClothesTimer extends Sprite
	{
		static private const FORMAT_VALUE:TextFormat = new TextFormat(null, 14, 0x877735, true);

		private var id:int = 0;
		private var time:int = 0;

		private var fieldTime:GameField = null;

		public function TemporaryClothesTimer(id:int):void
		{
			this.id = id;

			addChild(new TemporaryClothesTimerBack);

			this.mouseEnabled = false;

			this.fieldTime = new GameField("00:00:00", 0, 5, FORMAT_VALUE);
			addChild(this.fieldTime);

			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, update);
			update();
		}

		public function update(e:GameEvent = null):void
		{
			this.time = ClothesManager.getPackageTime(this.id);
			if (this.time == 0)
				EnterFrameManager.removePerSecondTimer(onTimer);
			else
				EnterFrameManager.addPerSecondTimer(onTimer);
			onTimer();
		}

		private function onTimer():void
		{
			var timeLeft:int = this.time - int(getTimer() / 1000) - Game.unix_time;
			this.visible = timeLeft > 0 && this.time != 0;

			if (timeLeft < 0)
			{
				EnterFrameManager.removePerSecondTimer(onTimer);
				return;
			}

			this.fieldTime.text = DateUtil.durationDayTime(timeLeft);
			this.fieldTime.x = 70 - int(this.fieldTime.textWidth * 0.5);
		}
	}
}