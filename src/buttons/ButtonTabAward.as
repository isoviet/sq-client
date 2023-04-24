package buttons
{
	import flash.text.TextFormat;

	import views.AwardBar;

	public class ButtonTabAward extends ButtonTab
	{
		public var bar:AwardBar;
		private var field:GameField;

		public function ButtonTabAward(caption:String):void
		{
			super(new ButtonAwardBack);

			var fieldCaption:GameField = new GameField(caption, 0, 5, new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653));
			fieldCaption.x = 100 - int(fieldCaption.textWidth * 0.5);
			addChild(fieldCaption);

			this.bar = new AwardBar([
					{'image': new AwardTypeBack(), 'X': 0, 'Y': 0},
					{'image': new AwardTypeActive(), 'X': 0, 'Y': 0},
					{'image': new AwardTypeActive(), 'X': 0, 'Y': 0}
					], 170);
			this.bar.addBackSelect(new AwardTypeBack);
			this.bar.x = 15;
			this.bar.y = 30;
			this.bar.mouseEnabled = false;
			addChild(this.bar);

			this.field = new GameField("", 0, 30, new TextFormat(null, 16, 0xFFFFFF, true));
			addChild(this.field);
		}

		public function setValues(current:int, max:int):void
		{
			this.bar.setValues(current, max);
			this.field.text = current + "/" + max;
			this.field.x = 100 - int(this.field.textWidth * 0.5);
		}

		override protected function doUp():void
		{
			super.doUp();
			if (this.bar != null)
				this.bar.switchBack(false);
		}

		override protected function doOver():void
		{
			super.doOver();
			if (this.bar != null)
				this.bar.switchBack(true);
		}
	}
}