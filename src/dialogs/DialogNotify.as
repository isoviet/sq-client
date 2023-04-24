package dialogs
{
	import flash.events.Event;
	import flash.text.TextFormat;

	import dialogs.Dialog;

	import com.greensock.TweenMax;

	public class DialogNotify extends Dialog
	{
		static private const TIME:Number = 8.0;
		static private const TOP_OFFSET:int = 50;

		private var fieldText:GameField;
		private var tween:TweenMax;

		public function DialogNotify():void
		{
			super("", false, false, null, false);

			init();
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
		}

		private function onChangeScreenSize(e: Event = null): void
		{
			this.x = Game.starling.stage.stageWidth / 2;
			this.y = TOP_OFFSET + this.height / 2;
		}

		public function set text(value:String):void
		{
			this.fieldText.text = value;

			this.width = this.fieldText.textWidth + 40;
			this.height = this.fieldText.textHeight + 40;

			this.graphics.clear();
			this.graphics.beginFill(0x133E69, 0.6);
			this.graphics.drawRoundRect(-((this.fieldText.textWidth + 40) * 0.5), -int((this.fieldText.textHeight + 40) * 0.5), this.fieldText.textWidth + 40, this.fieldText.textHeight + 40, 50, 50);

			this.fieldText.x = -int(this.fieldText.textWidth * 0.5) - 4;
			this.fieldText.y = -int(this.fieldText.textHeight * 0.5) - 4;
		}

		private function init():void
		{
			this.fieldText = new GameField("", 0, 0, new TextFormat(null, 20, 0xFFFFFF, null, null, null, null, null, "center"));
			addChild(this.fieldText);

			place();
		}

		override protected function effectOpen():void
		{}

		override public function show():void
		{
			super.show();

			if (this.tween != null)
			{
				this.tween.kill();
				this.tween = null;
			}
			onChangeScreenSize();
			this.alpha = 1.0;
			this.tween = TweenMax.to(this, 1.0, {'alpha': 0, 'delay': TIME, 'onComplete': hide});
		}
	}
}