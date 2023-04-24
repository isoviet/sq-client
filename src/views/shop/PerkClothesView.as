package views.shop
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import game.mainGame.perks.clothes.PerkClothesFactory;

	public class PerkClothesView extends Sprite
	{
		private var _id:int = -1;

		private var fieldCaption:GameField = null;
		private var fieldText:GameField = null;

		private var image:DisplayObject = null;

		public function PerkClothesView(id:int = -1):void
		{
			this.fieldCaption = new GameField("", 25, 0, new TextFormat(null, 12, 0x68361B, true));
			addChild(this.fieldCaption);

			this.fieldText = new GameField("", 25, 15, new TextFormat(null, 12, 0x68361B), 365);
			addChild(this.fieldText);

			this.id = id;
		}

		public function set id(value:int):void
		{
			if (this.id == value)
				return;
			this._id = value;

			if (this.image)
				removeChild(this.image);
			this.image = PerkClothesFactory.getNewImage(this.id);
			this.image.y = 20;
			addChild(this.image);

			this.fieldCaption.text = PerkClothesFactory.getName(this.id);
			this.fieldText.text = PerkClothesFactory.getDescription(this.id);
		}

		public function get id():int
		{
			return this._id;
		}
	}
}