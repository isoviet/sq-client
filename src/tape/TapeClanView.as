package tape
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	import buttons.ButtonDouble;
	import events.GameEvent;
	import statuses.Status;

	import utils.EditField;

	public class TapeClanView extends TapeView
	{
		static private const INPUT_DELAY_MSEC:int = 500;

		private var tapeData:TapeClanData = null;
		private var findField:EditField = null;

		private var findTimer:Timer = null;

		public function TapeClanView():void
		{
			super(5, 2, 200, 5, 5, 0, 128, 31, false, false);
		}

		public function clear():void
		{
			this.tapeData.clear();
		}

		override protected function placeButtons():void
		{
			this.buttonPrevious = new ButtonDouble(new ButtonRewindLeft, new ButtonRewindLeftInactive);
			this.buttonRewindPrevious = new ButtonDouble(new ButtonRewindLeftDouble, new ButtonRewindLeftDoubleInactive);
			this.buttonNext = new ButtonDouble(new ButtonRewindRight, new ButtonRewindRightInactive);
			this.buttonRewindNext = new ButtonDouble(new ButtonRewindRightDouble, new ButtonRewindRightDoubleInactive);

			this.buttonPrevious.setState(true);
			this.buttonRewindPrevious.setState(true);
			this.buttonNext.setState(true);
			this.buttonRewindNext.setState(true);

			this.buttonPrevious.x = 10;
			this.buttonPrevious.y = 7;

			this.buttonRewindPrevious.x = 10;
			this.buttonRewindPrevious.y = 38;

			this.buttonNext.x = 862;
			this.buttonNext.y = 7;

			this.buttonRewindNext.x = 862;
			this.buttonRewindNext.y = 38;

			super.placeButtons();

			var findImage:FindPlayerImage = new FindPlayerImage();
			findImage.x = 219;
			findImage.y = -11;
			addChild(findImage);

			this.findField = new EditField(gls("Поиск"), 237, -11, 57, 15, new TextFormat(GameField.DEFAULT_FONT, 11, 0xFFFFFF));
			this.findField.background = false;
			this.findField.addEventListener(Event.CHANGE, find);
			addChild(this.findField);

			new Status(this.findField, gls("Поиск по имени"));

			this.findTimer = new Timer(INPUT_DELAY_MSEC, 1);
			this.findTimer.addEventListener(TimerEvent.TIMER_COMPLETE, updateClanMembers);

			this.tapeData = new TapeClanData();
			this.tapeData.addEventListener(GameEvent.FRIENDS_UPDATE, updateData);
			setData(this.tapeData);
		}

		private function updateClanMembers(e:TimerEvent = null):void
		{
			if (this.findField.text == "")
			{
				setData(this.tapeData);
				return;
			}

			var newData:TapeClanData = new TapeClanData(this.findField.text);
			newData.loadData(this.tapeData.getIdsByName(this.findField.text));
			setData(newData);
		}

		private function find(e:Event):void
		{
			this.findTimer.reset();
			this.findTimer.start();
		}

		private function updateData(e:GameEvent):void
		{
			this.tapeData.clanLeaderPlace.x = 41;
			this.tapeData.clanLeaderPlace.y = 7;
			addChild(this.tapeData.clanLeaderPlace);
		}
	}
}