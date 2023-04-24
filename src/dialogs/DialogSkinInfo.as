package dialogs
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;
	import tape.TapeDataSelectable;
	import tape.wardrobeTapes.TapeWardrobeSkinElement;
	import tape.wardrobeTapes.TapeWardrobeSkinView;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class DialogSkinInfo extends Dialog
	{
		static private var _instance:DialogSkinInfo = null;

		private var id:int = -1;

		static public function show(id:int):void
		{
			if (!_instance)
				_instance = new DialogSkinInfo(id);
			else if (_instance.id != id)
			{
				_instance.hide();
				_instance = new DialogSkinInfo(id);
			}

			_instance.show();
		}

		public function DialogSkinInfo(id:int)
		{
			super("", false);

			this.id = id;

			var back:DisplayObject = addChildAt(new DialogSkinInfoBack(), 0);

			addChild(new GameField(gls("Внимание"), 0, 10, Dialog.FORMAT_CAPTION_18_CENTER, back.width)).filters = Dialog.FILTERS_CAPTION;
			//var currentString:String = ClothesData.getPackageTitleById(this.id);
			//var baseString:String = ClothesData.getPackageTitleById(OutfitData.getBaseSkin(this.id));

			addChild(new GameField(gls("Чтобы использовать образ, необходимо\nприобрести базовый костюм."), 50, 50, new TextFormat(null, 14, 0x5D280E, true, null, null, null, null, "center")));
			addChild(new GameField(gls("Мы даём тебе базовый\nкостюм на 24 часа,\nчтобы ты мог испытать\nвсе прелести нового образа!"), 140, 255, new TextFormat(null, 14, 0x5D280E, true, null, null, null, null, "center")));

			var data:TapeDataSelectable = new TapeDataSelectable(TapeWardrobeSkinElement);
			data.setData(GameConfig.getOutfitPackages(OutfitData.packageToOutfit(this.id)).filter(function(item:int, index:int, parentArray:Array):Boolean
			{
				if (index || parentArray) {/*unused*/}
				return GameConfig.getPackageCoinsPrice(item) != 0 || ClothesManager.haveItem(item, ClothesManager.KIND_PACKAGES);
			}));

			var tapeView:TapeWardrobeSkinView = new TapeWardrobeSkinView(60, 10, 2);
			tapeView.setData(data);
			tapeView.x = 145;
			tapeView.y = 130;
			tapeView.mouseEnabled = false;
			tapeView.mouseChildren = false;
			addChild(tapeView);

			var buttonBuy:ButtonBase = new ButtonBase(GameConfig.getPackageCoinsPrice(this.id) + " -");
			buttonBuy.x = int((back.width - buttonBuy.width) * 0.5);
			buttonBuy.y = 350;
			buttonBuy.addEventListener(MouseEvent.CLICK, buySkin);
			addChild(buttonBuy);
			FieldUtils.replaceSign(buttonBuy.field, "-", ImageIconCoins, 0.7, 0.7, -buttonBuy.field.x, -3, false, false);

			place();

			this.buttonClose.x -= 15;
			this.buttonClose.y += 5;
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 0;
			this.rightOffset = 0;
			this.topOffset = 0;
			this.bottomOffset = 0;
		}

		private function buySkin(e:MouseEvent):void
		{
			Game.buyWithoutPay(PacketClient.BUY_SKIN, GameConfig.getPackageCoinsPrice(this.id), 0, Game.selfId, this.id);
			hide();
		}
	}
}