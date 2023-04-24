package tape.collectionTapes
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;

	import game.gameData.CollectionManager;
	import game.gameData.CollectionsData;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.StatusCollectionItem;
	import tape.TapeObject;

	public class TapeCollectionExchangeElement extends TapeObject
	{
		static public const ELEMENT_WIDTH:int = 45;
		static public const ELEMENT_HEIGHT:int = 45;

		private var _elementId:int = -1;

		private var crossButton:SimpleButton = null;
		private var background:DisplayObject = null;

		private var icon:DisplayObject = null;

		private var status:StatusCollectionItem = null;

		public function TapeCollectionExchangeElement():void
		{
			this.graphics.beginFill(0xF0DAB9);
			this.graphics.drawRoundRect(0, 0, ELEMENT_WIDTH, ELEMENT_HEIGHT, 5, 5);

			this.background = new ElementSlotBack();
			this.background.width = ELEMENT_WIDTH;
			this.background.height = ELEMENT_HEIGHT;
			addChild(this.background);

			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);

			clear();
		}

		public function get isEmpty():Boolean
		{
			return (this.elementId == -1);
		}

		public function get elementId():int
		{
			return _elementId;
		}

		public function set elementId(value:int):void
		{
			if (this._elementId == value)
				return;

			clear();

			this._elementId = value;

			if (this.elementId == -1)
				return;

			var iconClass:Class = CollectionsData.getIconClass(this.elementId);
			this.icon = new iconClass();
			this.icon.scaleX = this.icon.scaleY = 0.6;
			this.icon.x += int((ELEMENT_WIDTH - this.icon.width) * 0.5);
			this.icon.y += int((ELEMENT_HEIGHT - this.icon.height) * 0.5);
			addChild(this.icon);

			addChild(this.crossButton);

			this.background.visible = true;

			this.status = new StatusCollectionItem(this, CollectionsData.TYPE_REGULAR, this.elementId);
		}

		public function remove():void
		{
			clear();
		}

		private function onOver(e:MouseEvent):void
		{
			if (this.icon != null && this.contains(this.icon))
				this.crossButton.visible = true;
		}

		private function onOut(e:MouseEvent):void
		{
			if (this.icon != null && this.contains(this.icon))
				this.crossButton.visible = false;
		}

		private function clearPlace(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK);
			CollectionManager.removeFromExchange(this.elementId);
		}

		private function clear():void
		{
			if (this.icon != null && this.contains(this.icon))
				removeChild(this.icon);

			if (this.crossButton != null && contains(this.crossButton))
			{
				this.crossButton.removeEventListener(MouseEvent.CLICK, clearPlace);
				removeChild(this.crossButton);
			}

			this.crossButton = new ButtonCross();
			this.crossButton.scaleX = this.crossButton.scaleY = 0.8;
			this.crossButton.x = 27;
			this.crossButton.y = 4;
			this.crossButton.visible = false;
			this.crossButton.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 3)];
			this.crossButton.addEventListener(MouseEvent.CLICK, clearPlace);
			addChild(this.crossButton);

			this.background.visible = false;

			this._elementId = -1;

			if (this.status == null)
				return;

			this.status.remove();
		}
	}
}