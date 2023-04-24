package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import loaders.ScreensLoader;
	import screens.ScreenAward;
	import screens.ScreenProfile;
	import statuses.StatusAward;

	public class DialogAwardPopup extends Dialog
	{
		static private const NAME:TextFormat = new TextFormat(null, 12, 0x443114, true);
		static private const TEXT:TextFormat = new TextFormat(null, 10, 0x756243, true);
		static private const BAR:TextFormat = new TextFormat(null, 8, 0xFFFFFF, true);

		public var isMouseOver:Boolean = false;
		private var awardId:int;
		private var percent:int;

		public function DialogAwardPopup(awardId:int, percent:int = 100):void
		{
			super(null);

			this.awardId = awardId;
			this.percent = percent;

			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);

			init();
		}

		private function init():void
		{
			var image:DisplayObject = Award.getImage(this.awardId);
			image.width = 60;
			image.height = 60;
			if (image is SimpleButton)
				(image as SimpleButton).addEventListener(MouseEvent.CLICK, onViewScreenAward);
			addChild(image);

			var captionField:GameField = new GameField((Award.DATA[this.awardId]['name'] as String).toUpperCase(), 63, 2, NAME);
			captionField.wordWrap = true;
			captionField.width = 130;
			addChild(captionField);

			var text:String = gls("У тебя новое достижение, поздравляем!");
			if (this.percent < 50)
				text = gls("Выполняется достижение {0}!", Award.DATA[this.awardId]['name']);
			else if (this.percent == 50)
				text = gls("Половина достижения {0} выполнена!", Award.DATA[this.awardId]['name']);
			else if (this.percent < 80)
				text = gls("Больше половины достижения {0} выполнено!", Award.DATA[this.awardId]['name']);
			else if (this.percent < 100)
				text = gls("Почти выполнено достижение {0}!", Award.DATA[this.awardId]['name']);

			var textField:GameField = new GameField(text, 63, 7 + captionField.textHeight, TEXT);
			textField.wordWrap = true;
			textField.width = 150;
			addChild(textField);

			if (this.percent != 100)
			{
				var bar:MovieClip = new AwardBarNotifyBack();
				bar.x = -2;
				bar.y = 72;
				addChild(bar);

				bar = new AwardBarNotifyActive();
				bar.width = int(220 * this.percent / 100);
				bar.x = -2;
				bar.y = 72;
				addChild(bar);

				var field:GameField = new GameField(this.percent + "%", 0, 74, BAR);
				field.x = int((216 - field.textWidth) * 0.5);
				addChild(field);
			}

			new StatusAward(this, Award.DATA[this.awardId]['text']);

			place();

			this.height += 10;

			if (this.percent == 100)
			{
				image = new ImageAwardStarNotify();
				image.x = -25;
				image.y = -20;
				addChild(image);
			}
		}

		private function onViewScreenAward(event:MouseEvent):void
		{
			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenAward.instance);
		}

		private function onOver(e:MouseEvent):void
		{
			this.isMouseOver = true;
		}

		private function onOut(e:MouseEvent):void
		{
			this.isMouseOver = false;
		}
	}
}