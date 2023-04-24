package views
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import views.storage.CollectionExchangeElement;
	import views.storage.CollectionExchangeView;

	import com.api.Player;

	public class CollectionPlayerExchangeView extends Sprite
	{
		private var player:Player = null;
		private var elements:Array = [];
		private var selectedElement:CollectionExchangeElement = null;

		public function CollectionPlayerExchangeView(isSelf:Boolean):void
		{
			init(isSelf);
		}

		public function setPlayer(player:Player, level:int):void
		{
			this.player = player;

			if ((this.player == null) || !("collection_exchange" in this.player))
				return;

			var playerExchange:Array = this.player['collection_exchange'];
			if (!playerExchange || playerExchange.length == 0)
				return;

			this.selectedElement = null;

			for (var i:int = 0; i < this.elements.length; i++)
			{
				(this.elements[i] as CollectionExchangeElement).level = level;
				(this.elements[i] as CollectionExchangeElement).id = i < playerExchange.length ? playerExchange[i] : -1;
			}
		}

		public function get selectedId():int
		{
			return this.selectedElement != null ? this.selectedElement.elementId : -1;
		}

		private function init(isSelf:Boolean):void
		{
			this.graphics.beginFill(0xDDC9AF);
			this.graphics.drawRoundRect(isSelf ? 0 : 136, 0, isSelf ? 625 : 489, 55, 5, 5);

			for (var i:int = 0; i < CollectionExchangeView.ELEMENTS_COUNT; i++)
			{
				var element:CollectionExchangeElement = new CollectionExchangeElement();
				element.id = -1;
				element.x = 150 + i * 52;
				element.y = 5;
				element.addEventListener(MouseEvent.CLICK, select);
				addChild(element);
				this.elements.push(element);
			}

			if (isSelf)
				addChild(new GameField(gls("Коллекции\nна обмен"), 20, 10, new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF, true, null, null, null, null, "center")));
		}

		private function select(e:MouseEvent):void
		{
			if (this.selectedElement)
				this.selectedElement.sticked = false;
			this.selectedElement = (this.selectedElement == e.currentTarget) ? null : (e.currentTarget as CollectionExchangeElement);
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}