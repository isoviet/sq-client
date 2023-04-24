package tape
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import game.gameData.GameConfig;

	import protocol.PacketClient;

	import utils.FieldUtils;
	import utils.FiltersUtil;
	import utils.starling.IStarlingAdapter;

	public class TapeShamanShopButton extends TapeObject
	{
		private var button:SimpleButton = null;
		private var _id:int = -1;

		public var localId:int = -1;
		public var blocked:Boolean = false;

		public var nutsCostSprite:Sprite = null;
		public var coinsCostSprite:Sprite = null;

		static private const DATA:Array = [
			{'iconX': 12,	'iconY': 7,	'scaleX': 0.25,		'scaleY': 0.5,	'rotate': 23},
			{'iconX': 22,	'iconY': 16,	'scaleX': 0.6,		'scaleY': 0.6},
			{'iconX': 10,	'iconY': 5,	'scaleX': 0.55,		'scaleY': 0.50},
			{'iconX': 7,	'iconY': 4,	'scaleX': 0.85,		'scaleY': 0.85},
			{'iconX': 10,	'iconY': 9,	'scaleX': 0.38,		'scaleY': 0.38},
			{'iconX': 22,	'iconY': 20,	'scaleX': 0.4,		'scaleY': 0.4},
			{'iconX': 7,	'iconY': 4,	'scaleX': 0.5,		'scaleY': 0.5},
			{'iconX': 19,	'iconY': 18,	'scaleX': 0.4,		'scaleY': 0.4},
			{'iconX': 19,	'iconY': 18,	'scaleX': 0.4,		'scaleY': 0.4},
			{'iconX': 7,	'iconY': 6,	'scaleX': 0.6,		'scaleY': 0.6}
		];

		public function TapeShamanShopButton():void
		{
			super();

			init();
		}

		public function blockButton():void
		{
			this.button.enabled = false;
			this.button.mouseEnabled = false;
			this.filters = FiltersUtil.GREY_FILTER;
			this.blocked = true;
		}

		public function resetButton():void
		{
			this.filters = [];
			this.button.enabled = true;
			this.button.mouseEnabled = true;
			this.blocked = false;
		}

		public function set id(value:int):void
		{
			this.button.removeEventListener(MouseEvent.CLICK, buyItem);
			while (this.numChildren > 1)
				removeChildAt(1);

			this.localId = value;
			if (value == -1)
			{
				this._id = -1;
				return;
			}

			this.button.addEventListener(MouseEvent.CLICK, buyItem);

			this._id = TapeShamanCastShop.sorted[value]['id'];

			var classIcon:Class = CastItemsData.getImageClass(this.id);
			var icon: * = new classIcon();
			if (icon is MovieClip)
				(icon as MovieClip).gotoAndStop(0);
			icon.scaleX = DATA[value]['scaleX'];
			icon.scaleY = DATA[value]['scaleY'];
			if (icon is IStarlingAdapter)
			{
				icon.scaleFlashX = DATA[value]['scaleX'];
				icon.scaleFlashY = DATA[value]['scaleY'];
			}
			icon.x = DATA[value]['iconX'];
			icon.y = DATA[value]['iconY'];
			icon.cacheAsBitmap = true;
			icon.mouseEnabled = false;
			icon.rotation = 'rotate' in DATA[value] ? DATA[value]['rotate'] : 0;
			addChild(icon);

			var formatCost:TextFormat = new TextFormat(null, 11, 0x231400, true);

			this.nutsCostSprite = new Sprite();
			this.nutsCostSprite.mouseEnabled = false;
			this.nutsCostSprite.mouseChildren = false;

			var fieldAmountNuts:GameField = new GameField("", 28, -2, new TextFormat(null, 12, 0x802134, true));
			fieldAmountNuts.text = "+" + GameConfig.itemFastCount;
			this.nutsCostSprite.addChild(fieldAmountNuts);

			var fieldNutsCost:GameField = new GameField("", 0, 23, formatCost);
			fieldNutsCost.text = GameConfig.getItemNutsPrice(this.id) + " *";
			fieldNutsCost.x = this.button.width - fieldNutsCost.width - 5;
			this.nutsCostSprite.addChild(fieldNutsCost);
			FieldUtils.replaceSign(fieldNutsCost, "*", ImageIconNut, 0.4, 0.4, -fieldNutsCost.x - 1, -fieldNutsCost.y, false, false);

			addChild(this.nutsCostSprite);
			this.nutsCostSprite.cacheAsBitmap = true;

			this.coinsCostSprite = new Sprite();
			this.coinsCostSprite.mouseEnabled = false;
			this.coinsCostSprite.mouseChildren = false;

			var fieldAmountCoins:GameField = new GameField("", 28, -2, new TextFormat(null, 12, 0x802134, true));
			fieldAmountCoins.text = "+" + GameConfig.getItemFastCoinsCount(this.id);
			this.coinsCostSprite.addChild(fieldAmountCoins);

			var fieldCoinsCost:GameField = new GameField("", 0, 22, formatCost);
			fieldCoinsCost.text = GameConfig.getItemFastCoinsPrice(this.id) + " .";
			fieldCoinsCost.x = this.button.width - fieldCoinsCost.width - 7;
			this.coinsCostSprite.addChild(fieldCoinsCost);
			FieldUtils.replaceSign(fieldCoinsCost, ".", ImageIconCoins, 0.4, 0.4, -fieldCoinsCost.x + 2, -fieldCoinsCost.y - 2, false, false);

			addChild(this.coinsCostSprite);
			this.coinsCostSprite.cacheAsBitmap = true;
		}

		public function get id():int
		{
			return this._id;
		}

		private function buyItem(e:MouseEvent):void
		{
			var coinsPrice:int = Game.balanceCoins >= GameConfig.getItemFastCoinsPrice(this.id) ? GameConfig.getItemFastCoinsPrice(this.id) : 0;
			var nutsPrice:int = Game.balanceCoins >= GameConfig.getItemFastCoinsPrice(this.id) ? 0 : GameConfig.getItemNutsPrice(this.id);
			if (!Game.buyWithoutPay(PacketClient.BUY_ITEMS_FAST, coinsPrice, nutsPrice, Game.selfId, this.id))
				return;
			blockButton();
		}

		private function init():void
		{
			this.button = new ShamanCastShopButton();
			this.button.upState.cacheAsBitmap = true;
			addChild(this.button);

			this.id = -1;
		}
	}
}