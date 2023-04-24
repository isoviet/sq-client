package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import events.GameEvent;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;

	import utils.ArrayUtil;

	public class AccessoriesView extends Sprite
	{
		private var _back:DisplayObject = null;

		private var slots:Array = [];
		private var imageLoaders:Object = {};
		private var buttonCrosses:Object = {};

		private var callback:Function = null;

		private var lastState:Array = [];

		public function AccessoriesView(callback:Function)
		{
			this.callback = callback;

			this.back.x = 15;
			this.back.y = 15;
			addChild(this.back);

			this.slots.push(this.back.imageSlot0, this.back.imageSlot1, this.back.imageSlot2,
				this.back.imageSlot3, this.back.imageSlot4, this.back.imageSlot5);

			for (var i:int = 0; i < this.slots.length; i++)
			{
				var sprite:Sprite = new Sprite();
				sprite.graphics.beginFill(0x000000, 0);
				sprite.graphics.drawRect(0, 0, 70, 60);
				sprite.x = 9 + (i % 2) * 96;
				sprite.y = 5 + int(i / 2) * 84;
				sprite.name = i.toString();
				sprite.buttonMode = true;
				sprite.addEventListener(MouseEvent.CLICK, select);
				addChild(sprite);
			}

			ClothesManager.addEventListener(GameEvent.CLOTHES_HERO_CHANGE, update);
			update();
		}

		private function select(e:MouseEvent):void
		{
			this.callback(int(e.currentTarget.name));
		}

		private function update(e:GameEvent = null):void
		{
			var toAdd:Array = ArrayUtil.getDifference(ClothesManager.wornAccessories, this.lastState);
			var toRemove:Array = ArrayUtil.getDifference(this.lastState, ClothesManager.wornAccessories);

			for (var i:int = 0; i < toRemove.length; i++)
			{
				var index:int = GameConfig.getAccessoryType(toRemove[i]);

				this.slots[index].visible = true;
				if (index in this.imageLoaders)
				{
					this.imageLoaders[index].visible = false;
					this.buttonCrosses[index].visible = false;
				}
			}

			for (i = 0; i < toAdd.length; i++)
			{
				index = GameConfig.getAccessoryType(toAdd[i]);
				this.slots[index].visible = false;

				if (index in this.imageLoaders)
					removeChild(this.imageLoaders[index]);
				this.imageLoaders[index] = new ClothesImageSmallLoader(toAdd[i]);
				this.imageLoaders[index].x = 9 + (index % 2) * 94;
				this.imageLoaders[index].y = 5 + int(index / 2) * 84;
				addChildAt(this.imageLoaders[index], 0);

				if (!(index in this.buttonCrosses))
				{
					this.buttonCrosses[index] = new ButtonRedCross();
					this.buttonCrosses[index].x = 77 + (index % 2) * 94;
					this.buttonCrosses[index].y = 10 + int(index / 2) * 84;
					this.buttonCrosses[index].addEventListener(MouseEvent.CLICK, onClose);
					addChild(this.buttonCrosses[index]);
				}
				this.buttonCrosses[index].name = toAdd[i].toString();
				this.buttonCrosses[index].visible = true;
			}

			this.lastState = ClothesManager.wornAccessories.concat();
		}

		private function onClose(e:MouseEvent):void
		{
			ClothesManager.tryOn(ClothesManager.KIND_ACCESORIES, int(e.currentTarget.name));
		}

		private function get back():WardrobeClothesSlots
		{
			if (!this._back)
				this._back = new WardrobeClothesSlots();
			return this._back as WardrobeClothesSlots;
		}
	}
}