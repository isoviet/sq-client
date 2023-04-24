package tape.shopTapes
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import buttons.ButtonFooterTab;
	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import events.ButtonTabEvent;
	import events.GameEvent;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;
	import statuses.Status;
	import tape.TapeData;
	import tape.TapeDataSelectable;
	import tape.TapeSelectableObject;
	import tape.TapeSelectableView;
	import views.ClothesImageLoader;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class TapeShopClothes extends TapeSelectableView
	{
		static private const FORMATS:Array = [new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653),
			new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653),
			new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653)];

		static private var _instance:TapeShopClothes = null;
		static private var _type:int = 0;

		private var button:ButtonBase = null;
		private var buttonsGroup:ButtonTabGroup = null;

		private var fieldCaption:GameField = null;

		private var tapeDatas:Array = [];
		private var imageLoader:ClothesImageLoader = null;

		static public function selectType(type:int):void
		{
			if (_instance)
				_instance.buttonsGroup.setSelectedByIndex(type + 1);
			else
				_type = type + 1;
		}

		public function TapeShopClothes():void
		{
			super(4, 3, 10, 10, 15, 15, 110, 115, true, true, false);

			_instance = this;

			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, updateItem);
		}

		override public function setData(data:TapeData):void
		{
			super.setData(data);

			if (data.objects.length != 0)
				select(data.objects[0] as TapeSelectableObject);
			else
				select(null);
		}

		private function updateItem(e:GameEvent):void
		{
			this.button.visible = !ClothesManager.haveItem(this.lastSticked.id, ClothesManager.KIND_ACCESORIES);
		}

		override protected function updateInfo(selected:TapeSelectableObject):void
		{
			this.button.field.text = GameConfig.getAccessoryCoinsPrice(this.lastSticked.id) + " - ";
			this.button.clear();
			this.button.redraw();
			FieldUtils.replaceSign(this.button.field, "-", ImageIconCoins, 0.7, 0.7, -this.button.field.x, -3, false, false);

			this.button.visible = !ClothesManager.haveItem(this.lastSticked.id, ClothesManager.KIND_ACCESORIES);

			this.fieldCaption.text = ClothesData.getTitleById(this.lastSticked.id);
			this.fieldCaption.x = 540 + int((340 - this.fieldCaption.textWidth) * 0.5);

			if (this.imageLoader)
				removeChild(this.imageLoader);
			this.imageLoader = new ClothesImageLoader(this.lastSticked.id);
			this.imageLoader.x = 560;
			this.imageLoader.y = 100;
			addChild(this.imageLoader);
		}

		override protected function init():void
		{
			this.x = 20;
			this.y = 165;

			var back:ImageShopClothesBack = new ImageShopClothesBack();
			back.x = 520;
			back.y = -5;
			addChildAt(back, 0);

			this.button = new ButtonBase("", 80);
			this.button.x = 672;
			this.button.y = 400;
			this.button.addEventListener(MouseEvent.CLICK, buyClothes);
			addChild(this.button);

			this.fieldCaption = new GameField("", 540, 5, new TextFormat(GameField.PLAKAT_FONT, 20, 0x663300));
			addChild(this.fieldCaption);

			var accessories_ids:Array = [];
			for (var i:int = 0; i < GameConfig.accessoryCount; i++)
			{
				if (GameConfig.getAccessoryCoinsPrice(i) == 0)
					continue;
				accessories_ids.push(i);
			}

			var array:Array = [accessories_ids,
					getIdsByType(accessories_ids, OutfitData.ACCESSORY_CLOAK), getIdsByType(accessories_ids, OutfitData.ACCESSORY_GLASSES),
					getIdsByType(accessories_ids, OutfitData.ACCESSORY_HANDS), getIdsByType(accessories_ids, OutfitData.ACCESSORY_NECK),
					getIdsByType(accessories_ids, OutfitData.ACCESSORY_TAIL), getIdsByType(accessories_ids, OutfitData.ACCESSORY_HAIRBAND)];
			var names:Array = [gls("Плащи"), gls("Очки"), gls("Аксессуары в руки"),
				gls("Ожерелья"), gls("Аксессуары на хвост"), gls("Аксессуары на голову")];
			for (i = 0; i < array.length; i++)
			{
				var data:TapeDataSelectable = new TapeDataSelectable(TapeShopClothesElement);
				data.setData(array[i]);
				this.tapeDatas.push(data);
			}

			this.buttonsGroup = new ButtonTabGroup();
			this.buttonsGroup.x = 30;
			this.buttonsGroup.y = -60;
			var button:ButtonTab = new ButtonTab(new ButtonFooterTab(gls("Всё"), FORMATS, ButtonTabShopAll, 15));
			new Status(button, gls("Все аксессуары"));
			this.buttonsGroup.insert(button);

			array = [ButtonTabShopCloak, ButtonTabShopGlass, ButtonTabShopHands, ButtonTabShopNeck, ButtonTabShopTail, ButtonTabShopHair];
			for (i = 0; i < array.length; i++)
			{
				button = new ButtonTab(new array[i]);
				button.x = (i + 1) * 95;
				this.buttonsGroup.insert(button);
				new Status(button, names[i]);
			}
			this.buttonsGroup.addEventListener(ButtonTabEvent.SELECT, onSelect);
			addChild(this.buttonsGroup);

			setData(this.tapeDatas[0]);
			this.buttonsGroup.setSelectedByIndex(_type);
		}

		private function onSelect(e:ButtonTabEvent):void
		{
			var index:int = this.buttonsGroup.tabs.indexOf(e.button);
			setData(this.tapeDatas[index]);
		}

		private function buyClothes(e:MouseEvent):void
		{
			if (!this.lastSticked)
				return;
			Game.buyWithoutPay(PacketClient.BUY_ACCESSORY, GameConfig.getAccessoryCoinsPrice(this.lastSticked.id), 0, Game.selfId, this.lastSticked.id)
		}

		private function getIdsByType(ids:Array, type:int):Array
		{
			return ids.filter(function(item:int, index:int, array:Array):Boolean
			{
				return GameConfig.getAccessoryType(item) == type;
			});
		}
	}
}