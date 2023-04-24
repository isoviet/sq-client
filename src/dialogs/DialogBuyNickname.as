package dialogs
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import loaders.RuntimeLoader;

	import com.api.Services;

	import protocol.Connection;
	import protocol.packages.server.PacketRename;

	import utils.FieldUtils;

	public class DialogBuyNickname extends Dialog
	{
		private var saveFunction:Function;
		private var cancelFunction:Function;

		private var fieldText:GameField;

		private var buttonCancel:ButtonBase;
		private var buttonOK:ButtonBase;

		private var images:Vector.<DisplayObject> = null;

		public function DialogBuyNickname(saveFunction:Function, cancelFunction:Function):void
		{
			super(gls("Изменить имя"), true, false);

			this.saveFunction = saveFunction;
			this.cancelFunction = cancelFunction;

			this.fieldText = new GameField("", 0, 5, new TextFormat(null, 14, 0x1f1f1f));
			addChild(this.fieldText);

			this.buttonOK = new ButtonBase(gls("Ок"));
			this.buttonOK.addEventListener(MouseEvent.CLICK, onAccess);

			this.buttonCancel = new ButtonBase(gls("Отмена"));
			this.buttonCancel.addEventListener(MouseEvent.CLICK, onCancel);

			place(this.buttonOK, this.buttonCancel);

			Connection.listen(onPacket, PacketRename.PACKET_ID);
		}

		static private function get price():int
		{
			return Game.NICKNAME_CHANGE_COST;
		}

		static private function onPacket(packet:PacketRename):void
		{
			if (packet) {}

			Game.request(Game.selfId, PlayerInfoParser.NAME, true);
			Game.freeChangeNick = false;
		}

		override public function show():void
		{
			this.width = Game.freeChangeNick ? 310 : 270;
			this.height = Game.freeChangeNick ? 160 : 110;

			this.fieldText.htmlText = this.text;

			if (this.images)
			{
				for each (var image:DisplayObject in this.images)
					removeChild(image);
			}

			this.images = FieldUtils.replaceSign(this.fieldText, "#Co", ImageIconCoins, 0.6, 0.6, -this.fieldText.x - 2, -this.fieldText.y, true);

			super.show();
		}

		private function get text():String
		{
			if (!Game.freeChangeNick)
				return gls("Поменять имя за <b>{0}</b> #Co   ?", price);
			return gls("После <b>{0}</b> уровня у тебя есть возможность\nодин раз поменять имя бесплатно, после\nиспользования которой изменить имя\nможно будет за <b>{1}</b> #Co  .", Game.LEVEL_TO_PAY_FOR_NICK, Game.NICKNAME_CHANGE_COST);
		}

		private function onCancel(e:MouseEvent):void
		{
			this.cancelFunction();

			hide();
		}

		private function onAccess(e:MouseEvent):void
		{
			if (Game.freeChangeNick)
				Game.freeChangeNick = false;
			else
			{
				if (Game.balanceCoins < price)
				{
					RuntimeLoader.load(function():void
					{
						Services.bank.open();
					});
					return;
				}
			}

			this.saveFunction();
			hide();
		}
	}
}