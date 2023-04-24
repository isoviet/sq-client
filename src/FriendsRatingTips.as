package
{
	import flash.display.DisplayObject;
	import flash.text.TextFormat;

	import statuses.Status;

	public class FriendsRatingTips extends Status
	{
		private var fieldRatingPlace:GameField;
		private var fieldExp:GameField;
		private var tipWidth:int = -1;

		public function FriendsRatingTips(owner:DisplayObject, name:String, score:String, ratingPlace:String = ""):void
		{
			super(owner, name, true);

			this.visible = false;
			this.tipWidth = width;

			init(score, ratingPlace);
		}

		public function load(name:String, exp:String, ratingPlace:String):void
		{
			super.field.wordWrap = false;
			super.setStatus(name);
			this.fieldRatingPlace.text =  int(ratingPlace) > 0 ? gls("{0} место среди друзей", ratingPlace) : "";
			this.fieldExp.text = gls("Опыт: {0}", exp);

			draw();
		}

		override protected function draw():void
		{
			this.field.y = this.fieldRatingPlace.text == "" ? 2 : 15;
			this.fieldExp.y = this.field.y + 15;

			var newWidth:int = int(Math.max(this.field.textWidth, this.fieldRatingPlace.textWidth, this.fieldExp.textWidth)) + 15;
			var newHeight:int = int(this.field.textHeight) + 10 + this.fieldRatingPlace.textHeight + this.fieldExp.textHeight;

			this.graphics.clear();
			this.graphics.lineStyle(2, 0x0453a8);
			this.graphics.beginFill(0xd3e2ec);
			this.graphics.drawRoundRectComplex(0, 0, newWidth, newHeight, 5, 5, 5, 5);
			this.graphics.endFill();
		}

		private function init(score:String, ratingPlace:String):void
		{
			this.fieldRatingPlace = new GameField(ratingPlace, 5, 2, new TextFormat(null, 12, 0x4D3302, true));
			addChild(this.fieldRatingPlace);

			this.field.y = 15;

			this.fieldExp = new GameField(score, 5, this.field.y + 15, new TextFormat(null, 10, 0x037C01, true));
			addChild(this.fieldExp);

			draw();
		}
	}
}