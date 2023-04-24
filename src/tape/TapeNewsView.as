package tape
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import footers.FooterTop;
	import game.gameData.DialogOfferManager;
	import loaders.DiscountsLoader;
	import loaders.RuntimeLoader;
	import loaders.ScreensLoader;
	import screens.ScreenCollection;
	import screens.ScreenProfile;
	import screens.ScreenShamanTree;
	import tape.events.TapeElementEvent;
	import views.DiscountTimerView;
	import views.TvView;

	import com.api.Services;

	import protocol.PacketClient;

	import utils.HScrollBar;

	public class TapeNewsView extends TapeView
	{
		protected var lastSticked:TapeNewsElement = null;

		private var image:Sprite = null;
		private var imageMask:Sprite = null;

		private var timersDiscount:Vector.<DiscountTimerView> = new <DiscountTimerView>[];
		private var buttonsDiscount:Vector.<SimpleButton> = new <SimpleButton>[];
		private var buttonOfferOK:SimpleButton = null;

		private var scroll:HScrollBar = null;

		private var changeCallback:Function = null;

		public function TapeNewsView(changeCallback:Function):void
		{
			super(1, 4, 718, 37, 0, 0, 90, 100, false, false);

			removeChild(this.buttonNext);
			removeChild(this.buttonPrevious);

			init();

			this.changeCallback = changeCallback;
		}

		override public function setData(data:TapeData):void
		{
			if (this.data != null)
				this.data.removeEventListener(TapeElementEvent.STICKED, onStickElement);

			initOffers(data);
			super.setData(data);
			select(this.data.objects.length > 0 ? this.data.objects[0] as TapeNewsElement : null);
			this.scroll.visible = this.data.objects.length > this.numRows;

			this.data.addEventListener(TapeElementEvent.STICKED, onStickElement);
		}

		override protected function update():void
		{
			super.update();

			this.scroll.setWithoutEvent(this.data ? this.offset / (this.data.objects.length - this.numRows) : 0);
		}

		public function getImage():Sprite
		{
			return this.image;
		}

		public function removeObject(id:int = 0, type:int = 0):void
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				var object:TapeNewsElement = this.data.objects[i] as TapeNewsElement;
				if (object.id != id || object.type != type)
					continue;
				if (this.data.objects.splice(i, 1)[0] == this.lastSticked)
					select(this.data.objects.length > 0 ? this.data.objects[0] as TapeNewsElement : null);
				this.scroll.visible = this.data.objects.length > this.numRows;
				break;
			}

			if (type == TapeNewsElement.DISCOUNT)
			{
				var removed:Boolean = false;
				for (i = 0; i < this.buttonsDiscount.length; i++)
				{
					this.buttonsDiscount[i].x -= removed ? 75 : 0;
					if (this.buttonsDiscount[i].name != id.toString())
						continue;
					removeChild(this.buttonsDiscount[i]);
					this.buttonsDiscount.splice(i, 1);
					i--;

					removed = true;
				}
			}
			this.offset = Math.min(this.offset, this.data.objects.length - this.numRows);
			update();
		}

		private function init():void
		{
			this.scroll = new HScrollBar(400);
			this.scroll.x = 822;
			this.scroll.y = 37;
			this.scroll.addEventListener(HScrollBar.ON_SCROLL, onScroll);
			addChild(this.scroll);

			var image:ImageNewsFrame = new ImageNewsFrame();
			image.mouseEnabled = false;
			addChild(image);

			this.imageMask = new Sprite();
			this.imageMask.graphics.beginFill(0x000000);
			this.imageMask.graphics.drawRect(0, 0, 760, 500);

			if (DiscountManager.haveDiscounts)
			{
				TvView.have_action = true;

				DiscountsLoader.load(onDiscountsLoad);
			}
		}

		private function initOffers(data:TapeData):void
		{
			if (Game.self.type == Config.API_OK_ID)
			{
				this.buttonOfferOK = DialogOfferManager.getButtonOfferOK();
				if (this.buttonOfferOK != null)
				{
					this.buttonOfferOK.x = 25;
					this.buttonOfferOK.y = 490;
					this.buttonOfferOK.addEventListener(MouseEvent.CLICK, showOfferOK);
					addChild(this.buttonOfferOK);

					data.pushObject(new TapeNewsElementOK());
				}

				TvView.have_action = true;
			}
		}

		private function onDiscountsLoad():void
		{
			var index:int = this.shiftIndex;
			var ids:Array = DiscountManager.ids;

			for (var i:int = 0; i < ids.length; i++)
			{
				var buttonClass:Class = DiscountManager.getButtonClass(ids[i]);
				var button:SimpleButton = new buttonClass();
				button.x = 25 + (this.buttonOfferOK == null ? 0 : 75) + i * 75;
				button.y = 490;
				button.name = ids[i];
				button.addEventListener(MouseEvent.CLICK, showDiscount);
				addChild(button);
				this.buttonsDiscount.push(button);

				var object:TapeNewsElement = new TapeNewsElement(ids[i], TapeNewsElement.DISCOUNT);
				this.data.insertObject(object, index);

				var timer:DiscountTimerView = new DiscountTimerView();
				timer.name = ids[i];
				this.timersDiscount.push(timer);
				object.addChild(timer);
			}
			this.scroll.visible = this.data.objects.length > this.numRows;

			select(this.data.objects.length > 0 ? this.data.objects[0] as TapeNewsElement : null);
			this.offset = 0;

			DiscountManager.addEventListener(Event.CHANGE, updateTimers);
		}

		private function showOfferOK(e:MouseEvent):void
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				if (!(this.data.objects[i] is TapeNewsElementOK))
					continue;
				select(this.data.objects[i] as TapeNewsElement);
				this.offset = Math.max(0, Math.min(i, this.data.objects.length - this.numRows));
				break;
			}
		}

		private function showDiscount(e:MouseEvent):void
		{
			var id:int = int(e.currentTarget.name);

			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				var object:TapeNewsElement = this.data.objects[i] as TapeNewsElement;
				if (object.id != id || object.type != TapeNewsElement.DISCOUNT)
					continue;
				select(object);
				this.offset = Math.max(0, Math.min(i, this.data.objects.length - this.numRows));
				break;
			}
		}

		private function get shiftIndex():int
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				if ((this.data.objects[i] as TapeNewsElement).type != TapeNewsElement.NEWS)
					continue;
				return i + 1;
			}
			return 0;
		}

		private function onScroll(e:Event):void
		{
			if (this.data)
			{
				var nValue:Number = this.scroll.value;
				var value:int = int(this.scroll.value * (this.data.objects.length - this.numRows));
				if (value != this.offset)
				{
					this.offset = value;
					this.scroll.setWithoutEvent(nValue);
				}
			}
		}

		private function updateInfo(selected:TapeNewsElement):void
		{
			if (!selected)
				return;
			if (this.image)
				removeChild(this.image);

			switch (selected.type)
			{
				case TapeNewsElement.NEWS:
					this.image = TvView.getNews(selected.id);
					break;
				case TapeNewsElement.DISCOUNT:
					var imageClass:Class = DiscountManager.getImageClass(selected.id);
					this.image = new imageClass();
					this.image.width = 700;
					this.image.height = 460;
					(this.image as MovieClip).buttonBuy.addEventListener(MouseEvent.CLICK, onClick);
					break;
				case TapeNewsElement.OFFER_OK:
					this.image = DialogOfferManager.getViewOfferOK();
					break;
			}
			this.image.x = this.image.y = 10;
			this.image.mask = this.imageMask;
			addChildAt(this.image, 0);
		}

		private function onStickElement(e:TapeElementEvent):void
		{
			select(e.element as TapeNewsElement);
		}

		private function select(selected:TapeNewsElement):void
		{
			if (this.lastSticked == selected)
				return;

			if (this.lastSticked != null)
				this.lastSticked.selected = false;
			this.lastSticked = selected;

			if (this.lastSticked != null)
				this.lastSticked.selected = true;
			updateInfo(this.lastSticked);

			this.changeCallback(this.lastSticked ? this.lastSticked.id : 0, this.lastSticked.isDiscount);
		}

		private function updateTimers(e:Event):void
		{
			for each (var timer:DiscountTimerView in this.timersDiscount)
				timer.time = DiscountManager.getTime(int(timer.name));
		}

		private function onClick(e:MouseEvent):void
		{
			switch (this.lastSticked.id)
			{
				case DiscountManager.COLLECTIONS:
				case DiscountManager.COLLECTIONS_NP:
					ScreensLoader.load(ScreenCollection.instance);
					break;
				case DiscountManager.DOUBLE_MANA:
					Game.buyWithoutPay(PacketClient.BUY_DISCOUNT, DiscountManager.COST_DOUBLE_MANA, 0, Game.selfId, DiscountManager.DOUBLE_MANA);
					break;
				case DiscountManager.DOUBLE_MANA_NP:
					Game.buyWithoutPay(PacketClient.BUY_MANA_BIG, DrinkItemsData.DATA[DrinkItemsData.MANA_BIG_ID]['gold_cost'], 0, Game.selfId);
					break;
				/*case DiscountManager.SMILES:
					if (TapeShopMiscElement.miscData == null)
						TapeShopMiscElement.init();
					Game.buyWithoutPay(PacketClient.BUY_MISC, int(TapeShopMiscElement.miscData[0]['gold_cost'] * DiscountManager.DISCOUNT_SMILES), 0, Game.selfId, 0);
					break;
				case DiscountManager.SMILES_NP:
					if (TapeShopMiscElement.miscData == null)
						TapeShopMiscElement.init();
					Game.buyWithoutPay(PacketClient.BUY_MISC, int(TapeShopMiscElement.miscData[0]['gold_cost'] * DiscountManager.DISCOUNT_SMILES_NP), 0, Game.selfId, 0);
					break;*/
				case DiscountManager.DECORATION:
					FooterTop.showDecorations();
					ScreensLoader.load(ScreenProfile.instance);
					ScreenProfile.setPlayerId(Game.selfId);
					break;
				case DiscountManager.SHAMAN_ITEMS_PACK:
					Game.buyWithoutPay(PacketClient.BUY_DISCOUNT, DiscountManager.COST_SHAMAN_ITEMS_PACK, 0, Game.selfId, DiscountManager.SHAMAN_ITEMS_PACK);
					break;
				case DiscountManager.SHAMAN_ITEMS_PACK_NP:
					Game.buyWithoutPay(PacketClient.BUY_DISCOUNT, DiscountManager.COST_SHAMAN_ITEMS_PACK_NP, 0, Game.selfId, DiscountManager.SHAMAN_ITEMS_PACK_NP);
					break;
				case DiscountManager.SHAMAN_BRANCH:
				case DiscountManager.SHAMAN_SKILL:
					ScreensLoader.load(ScreenShamanTree.instance);
					break;
				case DiscountManager.LOCATIONS:
				case DiscountManager.LOCATIONS_NP:
				case DiscountManager.DOUBLE_COINS_SMALL:
				case DiscountManager.FREE_SHAMAN_ITEMS_NP:
				case DiscountManager.FREE_MANA:
				case DiscountManager.FREE_MANA_NP:
				case DiscountManager.DOUBLE_COINS_ALL_NP:
					RuntimeLoader.load(function():void
					{
						Services.bank.open();
					});
					break;
			}
		}
	}
}