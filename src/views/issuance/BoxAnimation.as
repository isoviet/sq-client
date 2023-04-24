package views.issuance
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;

	import buttons.ButtonBase;
	import buttons.ButtonBaseMultiLine;
	import sounds.GameSounds;
	import views.issuance.IssuanceBonusView;

	public class BoxAnimation extends Sprite
	{
		static private var queue:Vector.<BoxAnimation> = new <BoxAnimation>[];

		protected var issuanceImage:MovieClip = null;
		protected var index:int = 0;

		protected var buttonOpen:ButtonBase = null;
		protected var buttonTakeAll:ButtonBase = null;

		protected var type:int = 0;
		protected var collections:Vector.<int> = null;

		public function BoxAnimation(issuanceView:Class):void
		{
			super();

			this.graphics.beginFill(0x000000, 0.8);
			this.graphics.drawRect(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT);

			this.issuanceImage = new issuanceView();
			this.issuanceImage.addEventListener(MouseEvent.CLICK, onOpenIssuance);
			this.issuanceImage.buttonMode = true;
			addChild(this.issuanceImage);

			this.issuanceImage.x = int((this.width - this.issuanceImage.width) * 0.5);
			this.issuanceImage.y = int((this.height - this.issuanceImage.height) * 0.5);
			this.issuanceImage.addFrameScript(14, function():void
			{
				issuanceImage.gotoAndPlay(1);
			});
			this.issuanceImage.gotoAndPlay(0);

			this.buttonOpen = new ButtonBaseMultiLine(gls("Открыть"), 0, 28, null, 2);
			this.buttonOpen.x = int((this.width - this.buttonOpen.width) * 0.5);
			this.buttonOpen.y = this.issuanceImage.y + this.issuanceImage.height + 20;
			this.buttonOpen.addEventListener(MouseEvent.CLICK, onOpenIssuance);
			addChild(this.buttonOpen);

			this.buttonTakeAll = new ButtonBaseMultiLine(gls("Забрать всё"), 0, 28, null, 2);
			this.buttonTakeAll.x = int((this.width - this.buttonTakeAll.width) * 0.5);
			this.buttonTakeAll.y = int((this.height - this.buttonTakeAll.height) * 0.5);
			this.buttonTakeAll.visible = false;
			this.buttonTakeAll.addEventListener(MouseEvent.CLICK, onTakeBonuses);
			addChild(this.buttonTakeAll);

			if (queue.length == 0)
				showBundle();
			queue.push(this);
		}

		protected function onOpenIssuance(e:MouseEvent):void
		{
			this.buttonOpen.visible = false;
			this.issuanceImage.removeEventListener(MouseEvent.CLICK, onOpenIssuance);

			GameSounds.play("bundle_open");

			this.issuanceImage.addFrameScript(35, showBonuses);
			this.issuanceImage.addFrameScript(this.issuanceImage.totalFrames - 1, function():void
			{
				issuanceImage.stop();
				issuanceImage.visible = false;
			});
			this.issuanceImage.gotoAndPlay(16);
		}

		protected function onBonusShow():void
		{
			this.buttonTakeAll.visible = true;
		}

		protected function showHoliday(value:int):void
		{
			var dValue:int = 0;
			for (var i:int = 0; i < 5; i++)
			{
				var count:int = i == 4 ? -dValue : (Math.random() * 10 - 5 - dValue);
				dValue += count;
				new IssuanceBonusView(IssuanceBonusView.HOLIDAY_ELEMENTS, this.index, i, int(value / 5) + count).show(this);
				this.index++;
			}
		}

		protected function showBonuses():void
		{
			switch (this.type)
			{
				//...//
			}

			setTimeout(onBonusShow, this.index * 300);
		}

		protected function showByType(type:int, value:int, offsetX:int = 0, offsetY:int = 0):void
		{
			new IssuanceBonusView(type, this.index, 0, value, offsetX, offsetY).show(this);
			this.index++;
		}

		private function onTakeBonuses(e:MouseEvent):void
		{
			IssuanceBonusView.hide();
		}

		private function showBundle():void
		{
			Game.gameSprite.addChild(this);
			IssuanceBonusView.onFinish(hide);
		}

		private function hide():void
		{
			Game.gameSprite.removeChild(this);

			queue.shift();
			if (queue.length == 0)
				return;
			queue[0].showBundle();
		}
	}
}