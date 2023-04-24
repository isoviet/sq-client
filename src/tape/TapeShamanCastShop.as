package tape
{
	import events.GameEvent;
	import game.gameData.GameConfig;
	import game.mainGame.entity.cast.BodyDestructor;
	import game.mainGame.entity.simple.Balk;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.Box;
	import game.mainGame.entity.simple.PoiseRight;
	import game.mainGame.entity.simple.Trampoline;

	public class TapeShamanCastShop extends TapeView
	{
		static public const NUM_COLUMNS:int = 3;

		static public var sorted:Array = null;

		static private var _instance:TapeShamanCastShop = null;

		private var items:TapeData = new TapeData();
		private var showingItems:TapeData = new TapeData();
		private var existingItemsIds:Object = null;

		public function TapeShamanCastShop():void
		{
			super(NUM_COLUMNS, 1, 0, 0, 7, 0, 42, 38);

			setData(showingItems);
			init();
			update();

			_instance = this;
		}

		static public function resetButton(id:int):void
		{
			for (var i:int = 0; i < _instance.showingItems.objects.length; i++)
			{
				if ((_instance.showingItems.objects[i] as TapeShamanShopButton).id == id)
				{
					(_instance.showingItems.objects[i] as TapeShamanShopButton).resetButton();
					return;
				}
			}
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			Game.removeEvent(GameEvent.BALANCE_CHANGED, updateBuyButtons);
			if (!value)
				return;

			updateBuyButtons();
			Game.event(GameEvent.BALANCE_CHANGED, updateBuyButtons);
		}

		public function get showingItemsCount():int
		{
			return this.showingItems.objects.length;
		}

		public function set existingItems(items:Vector.<TapeObject>):void
		{
			if (!this.visible)
				return;

			this.existingItemsIds = {};
			for (var i:int = 0; i < items.length; i++)
				this.existingItemsIds[CastItemsData.getId((items[i] as TapeCastElement).castItem.itemClass)] = true;

			updateShowing();
		}

		override protected function placeButtons():void
		{}

		override protected function updateButtons():void
		{}

		private function init():void
		{
			this.visible = false;
			for (var i:int = 0; i < this.numColumns * this.numRows; i++)
				this.items.addObject(new TapeShamanShopButton());

			TapeShamanCastShop.sorted = [
				{'id': CastItemsData.getId(Balk),		'used':false},
				{'id': CastItemsData.getId(BodyDestructor),	'used':false},
				{'id': CastItemsData.getId(BalloonBody),	'used':false},
				{'id': CastItemsData.getId(PoiseRight),		'used':false},
				{'id': CastItemsData.getId(Box),		'used':false},
				{'id': CastItemsData.getId(Trampoline),		'used':false},
			];
		}

		private function filterExist(item:TapeShamanShopButton, index:int, parentArray:Vector.<TapeObject>):Boolean
		{
			if (index || parentArray) {/*unused*/}

			return item.id != -1;
		}

		private function findNextPopular():int
		{
			for (var j:int = 0; j < TapeShamanCastShop.sorted.length; j++)
			{
				var castItem:Object = TapeShamanCastShop.sorted[j];
				if (!(castItem.id in this.existingItemsIds) && !(castItem.used))
				{
					castItem.used = true;
					return j;
				}
			}
			return -1;
		}

		private function updateShowing():void
		{
			for (var i:int = 0; i < TapeShamanCastShop.sorted.length; i++)
				TapeShamanCastShop.sorted[i].used = false;

			for (i = 0; i < this.items.objects.length; i++)
				if ((this.items.objects[i] as TapeShamanShopButton).blocked)
					TapeShamanCastShop.sorted[(this.items.objects[i] as TapeShamanShopButton).localId].used = true;

			for (i = 0; i < this.items.objects.length; i++)
			{
				if ((this.items.objects[i] as TapeShamanShopButton).blocked)
					continue;
				(this.items.objects[i] as TapeShamanShopButton).id = findNextPopular();
			}

			this.showingItems.objects = this.items.objects.filter(filterExist);

			update();
			updateBuyButtons();
		}

		private function updateBuyButtons(e:GameEvent = null):void
		{
			for (var i:int = 0; i < this.showingItems.objects.length; i++)
			{
				var id:int = (this.showingItems.objects[i] as TapeShamanShopButton).id;
				if (id == -1)
					continue;

				var object:TapeShamanShopButton = this.showingItems.objects[i] as TapeShamanShopButton;
				var showCoins:Boolean = Game.balanceCoins >= GameConfig.getItemFastCoinsPrice(id) || Game.balanceNuts < GameConfig.getItemNutsPrice(id);
				object.coinsCostSprite.visible = showCoins;
				object.nutsCostSprite.visible = !showCoins;
			}
		}
	}
}