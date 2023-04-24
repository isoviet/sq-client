package tape.collectionTapes
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import events.DiscountEvent;
	import game.gameData.CollectionManager;
	import game.gameData.CollectionsData;
	import game.gameData.GameConfig;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.StatusCollection;
	import statuses.StatusCollectionItem;
	import tape.TapeObject;

	import protocol.PacketClient;

	import utils.Counter;
	import utils.FiltersUtil;
	import utils.StringUtil;

	public class TapeCollectionCommonElement extends TapeObject
	{
		static private const BUTTON_WIDTH:int = 58;
		static private const BUTTON_HEIGHT:int = 58;

		private var status:StatusCollectionItem = null;

		private var _counter:Counter = null;

		private var countField:GameField = null;

		private var icon:DisplayObject = null;
		private var background:DisplayObject = null;

		private var exchangeButton:SimpleButton = null;
		private var crossButton:SimpleButton = null;
		private var buyButton:SimpleButton = null;
		private var statusBuy:StatusCollection;

		private var exchange:Boolean = false;

		public var elementId:int;

		public function TapeCollectionCommonElement(id:int):void
		{
			super();

			this.elementId = id;

			this.background = new ElementSlotBack();
			this.background.width = this.background.height = BUTTON_WIDTH;
			addChild(this.background);

			var iconClass:Class = CollectionsData.getIconClass(id);
			this.icon = new iconClass();
			this.icon.scaleX = this.icon.scaleY = 0.7;
			this.icon.x += int((BUTTON_WIDTH - this.icon.width) * 0.5);
			this.icon.y += int((BUTTON_HEIGHT - this.icon.height) * 0.5);
			(this.icon as MovieClip).mouseEnabled = false;
			addChild(this.icon);

			var countFormat:TextFormat = new TextFormat(null, 12, 0x663300, true);
			countFormat.align = TextFormatAlign.RIGHT;

			this.countField = new GameField("0", 0, 38, countFormat);
			this.countField.autoSize = TextFieldAutoSize.RIGHT;
			this.countField.width = 60;
			this.countField.mouseEnabled = false;
			addChild(this.countField);

			this.exchangeButton = new CollectionItemExchangeButton();
			this.exchangeButton.x = 37;
			this.exchangeButton.y = 4;
			this.exchangeButton.width = this.exchangeButton.height = 20;
			this.exchangeButton.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 3)];
			this.exchangeButton.addEventListener(MouseEvent.CLICK, addToExchange);
			addChild(this.exchangeButton);
			new StatusCollection(this.exchangeButton, gls("Добавить на обмен"));

			this.buyButton = new ButtonPlusYellowShort();
			this.buyButton.scaleX = this.buyButton.scaleY = 1.2;
			this.buyButton.x = 50;
			this.buyButton.y = 50;
			this.buyButton.addEventListener(MouseEvent.CLICK, buyItem);
			addChild(this.buyButton);
			this.statusBuy = new StatusCollection(this.buyButton, gls("Купить за {0} {1}", this.price.toString(), StringUtil.word("монет", this.price)), true);

			this.crossButton = new ButtonCross();
			this.crossButton.x = 37;
			this.crossButton.y = 4;
			this.crossButton.scaleX = this.crossButton.scaleY = 0.8;
			this.crossButton.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 3)];
			this.crossButton.addEventListener(MouseEvent.CLICK, removeFromExchange);
			addChild(this.crossButton);
			new StatusCollection(this.crossButton, gls("Удалить из обмена"));

			this.status = new StatusCollectionItem(this.background, CollectionsData.TYPE_REGULAR, id);

			updateState();

			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);

			DiscountManager.addEventListener(DiscountEvent.START, onDiscount);
			DiscountManager.addEventListener(DiscountEvent.END, onDiscountEnd);
		}

		public function onConvert():void
		{
			CollectionManager.decItem(CollectionsData.TYPE_REGULAR, this.elementId);
			CollectionManager.removeFromExchange(this.elementId);
		}

		public function set isAnExchange(value:Boolean):void
		{
			this.exchange = value;

			this.exchangeButton.visible = !this.exchange && this.counter != null && this.counter.count > 1;
			this.crossButton.visible = this.exchange && this.counter != null && this.counter.count > 1;
			this.buyButton.visible = this.counter == null || this.counter.count < 1;

			dispatchEvent(new Event(Event.CHANGE));
		}

		public function get isCollected():Boolean
		{
			if (this.counter == null)
				return false;

			return (this.counter.count > 0);
		}

		public function get counter():Counter
		{
			return this._counter;
		}

		public function set counter(value:Counter):void
		{
			if (this._counter == value)
				return;

			if (this._counter != null)
				this._counter.removeEventListener(Event.CHANGE, updateState);

			this._counter = value;
			this._counter.addEventListener(Event.CHANGE, updateState);

			updateState();
		}

		private function onDiscount(e:DiscountEvent):void
		{
			if (e.id != DiscountManager.COLLECTIONS && e.id != DiscountManager.COLLECTIONS_NP)
				return;
			if (this.statusBuy)
				this.statusBuy.remove();
			this.statusBuy = new StatusCollection(this.buyButton, gls("Купить за {0} {1}", this.price.toString(), StringUtil.word("монет", this.price)), true);
		}

		private function onDiscountEnd(e:DiscountEvent):void
		{
			if (e.id != DiscountManager.COLLECTIONS && e.id != DiscountManager.COLLECTIONS_NP)
				return;
			if (this.statusBuy)
				this.statusBuy.remove();
			this.statusBuy = new StatusCollection(this.buyButton, gls("Купить за {0} {1}", this.price.toString(), StringUtil.word("монет", this.price)), true);
		}

		private function get price():int
		{
			return GameConfig.getCollectionRegularPrice(this.elementId);
		}

		private function onOver(e:MouseEvent):void
		{
			this.buyButton.visible = true;
			this.countField.visible = false;
		}

		private function onOut(e:MouseEvent):void
		{
			this.buyButton.visible = this.counter == null || this.counter.count < 1;
			this.countField.visible = true;
		}

		private function updateState(e:Event = null):void
		{
			dispatchEvent(new Event(Event.CHANGE));

			this.exchangeButton.visible = false;
			this.crossButton.visible = false;
			this.buyButton.visible = false;

			if (this.counter == null || this.counter.count == 0)
			{
				this.background.filters = FiltersUtil.GREY_FILTER;
				this.icon.filters = FiltersUtil.GREY_FILTER;

				this.exchangeButton.visible = false;
				this.crossButton.visible = false;
				this.buyButton.visible = true;

				this.countField.text = "";
				return;
			}

			this.background.filters = [];
			this.icon.filters = [];

			if (this.counter.count > 1)
			{
				this.exchangeButton.visible = !this.exchange;
				this.crossButton.visible = this.exchange;
			}

			this.countField.text = this.counter.count.toString();
		}

		private function buyItem(e:MouseEvent):void
		{
			Game.buy(PacketClient.BUY_COLLECTION_ITEM, this.price, 0, Game.selfId, this.elementId);
		}

		private function addToExchange(e:MouseEvent):void
		{
			CollectionManager.addToExchange(this.elementId);
		}

		private function removeFromExchange(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK);
			CollectionManager.removeFromExchange(this.elementId);
		}
	}
}