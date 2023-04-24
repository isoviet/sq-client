package tape.shopTapes
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import game.gameData.GameConfig;
	import tape.TapeData;
	import tape.TapeSelectableObject;
	import tape.TapeSelectableView;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class TapeShopCast extends TapeSelectableView
	{
		static private var _instance:TapeShopCast = null;

		static private const TEXT_FORMAT:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 13, 0x9F9172, true);

		public var fieldName:GameField = null;
		public var fieldInfo:GameField = null;
		public var fieldCount:GameField = null;

		private var preview:Loader = null;

		private var buttonOne:ButtonBase = null;
		private var buttonPack:ButtonBase = null;

		private var fieldOne:GameField = null;
		private var fieldPack:GameField = null;

		private var moviePreload:MovieClip = null;

		private var currentId:int = 0;

		static public function update():void
		{
			if (_instance)
				_instance.updateInfo(_instance.lastSticked);
		}

		public function TapeShopCast():void
		{
			super(4, 3, 30, 70, 15, 15, 110, 115, true, true, false);

			_instance = this;
		}

		override public function setData(data:TapeData):void
		{
			super.setData(data);

			if (data.objects.length != 0)
				select(data.objects[0] as TapeSelectableObject);
			else
				select(null);
		}

		override protected function init():void
		{
			super.init();

			this.moviePreload = new MoviePreload();
			this.moviePreload.x = 711;
			this.moviePreload.y = 161;
			addChild(this.moviePreload);

			addChildAt(new ImageShopCastBack(), 0);

			this.buttonOne = new ButtonBase("", 71, 14, buyOne);
			this.buttonOne.y = 438;
			addChild(this.buttonOne);

			this.buttonPack = new ButtonBase("", 71, 14, buyPack);
			this.buttonPack.y = 438;
			addChild(this.buttonPack);

			this.fieldOne = new GameField("1" + gls(" шт."), 0, 415, TEXT_FORMAT);
			addChild(this.fieldOne);

			this.fieldPack = new GameField("10" + gls(" шт."), 0, 415, TEXT_FORMAT);
			addChild(this.fieldPack);

			this.preview = new Loader();
			this.preview.scrollRect = new Rectangle(0,0,150,150);
			this.preview.x = 652;
			this.preview.y = 106;
			this.preview.addEventListener(Event.COMPLETE, onGIFLoadComplete);
			this.preview.addEventListener(IOErrorEvent.IO_ERROR, onGIFLoadError);
			addChild(this.preview);

			this.fieldName = new GameField("", 578, 51, new TextFormat(GameField.DEFAULT_FONT, 19, 0x663300, false, null, null, null, null, TextFormatAlign.CENTER), 302);
			addChild(this.fieldName);

			this.fieldCount = new GameField("", 580, 320, new TextFormat(GameField.DEFAULT_FONT, 12, 0x9F9172, false), 302);
			addChild(this.fieldCount);

			this.fieldInfo = new GameField("", 580, 308, new TextFormat(GameField.DEFAULT_FONT, 12, 0x68361B, false), 302);
			addChild(this.fieldInfo);
		}

		protected function get coins():int
		{
			return GameConfig.getItemCoinsPrice(this.currentId);
		}

		protected function get nuts():int
		{
			return GameConfig.getItemNutsPrice(this.currentId);
		}

		private function buyPack(e:Event):void
		{
			Game.buyWithoutPay(PacketClient.BUY_ITEM_SET, this.coins, 0, Game.selfId, this.currentId);
		}

		private function buyOne(e:Event):void
		{
			Game.buyWithoutPay(PacketClient.BUY_ITEMS, 0, this.nuts, Game.selfId, this.currentId);
		}

		private function onGIFLoadError(event:IOErrorEvent):void
		{
			Logger.add("Error load cast preview file");
		}

		private function onGIFLoadComplete(event:Event):void
		{
			this.moviePreload.visible = false;
		}

		override protected function updateInfo(selected:TapeSelectableObject):void
		{
			if (selected == null)
				return;

			this.currentId = selected.id;

			this.preview.load(new URLRequest(Config.PREVIEWS_CAST_URL + CastItemsData.getPreviewFileName(this.currentId) + '.swf'));

			this.buttonOne.field.text = nuts.toString() + " - ";
			this.buttonOne.clear();
			this.buttonOne.redraw();
			FieldUtils.replaceSign(this.buttonOne.field, "-", ImageIconNut, 0.7, 0.7, -this.buttonOne.field.x, -3, false, true);
			this.buttonOne.visible = this.fieldOne.visible = nuts > 0;
			this.buttonOne.x = this.nuts > 0 ? 618 : 693;
			this.fieldOne.x = this.buttonOne.x + this.buttonOne.width / 2 - this.fieldOne.width / 2;

			this.buttonPack.field.text = coins.toString() + " - ";
			this.buttonPack.clear();
			this.buttonPack.redraw();
			FieldUtils.replaceSign(this.buttonPack.field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonPack.field.x, -3, false, true);
			this.buttonPack.visible = this.fieldPack.visible = coins > 0;
			this.buttonPack.x = this.coins > 0 ? 763 : 693;
			this.fieldPack.x = this.buttonPack.x + this.buttonPack.width / 2 - this.fieldPack.width / 2;

			this.fieldName.text = CastItemsData.getTitle(selected.id);
			this.fieldInfo.text = CastItemsData.getText(selected.id);

			this.fieldCount.text = gls("В наличии: ") + Game.selfCastItems[selected.id].toString() + gls(" шт.");
			this.fieldCount.setTextFormat(new TextFormat(GameField.DEFAULT_FONT, 12, 0xFF5617, true), 11, this.fieldCount.text.length);

			this.fieldCount.y = this.fieldInfo.y + this.fieldInfo.height + 20;
		}
	}
}