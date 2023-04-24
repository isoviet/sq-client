package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import buttons.ButtonBase;
	import views.storage.CollectionExchangeElement;

	import utils.FieldUtils;
	import utils.FiltersUtil;

	public class CollectionResultExchangeView extends Sprite
	{
		private var selfElement:CollectionExchangeElement = null;
		private var playerElement:CollectionExchangeElement = null;

		private var arrows:MovieClip = null;

		private var buttonExchange:ButtonBase;

		public function CollectionResultExchangeView():void
		{
			init();
		}

		public function change(playerElement:int, selfElement:int):void
		{
			this.playerElement.id = playerElement;
			this.selfElement.id = selfElement;

			this.playerElement.mouseEnabled = this.selfElement.mouseEnabled = false;
			this.playerElement.mouseChildren = this.selfElement.mouseChildren = false;

			(this.arrows as ExchangeArrowsView).blueArrow.filters = (playerElement == -1 ? FiltersUtil.GREY_FILTER : []);
			(this.arrows as ExchangeArrowsView).greenArrow.filters = (selfElement == -1 ? FiltersUtil.GREY_FILTER : []);

			var exchangeEnabled:Boolean = (playerElement != -1 && selfElement != -1);

			this.buttonExchange.filters = (!exchangeEnabled ? FiltersUtil.GREY_FILTER : []);
			this.buttonExchange.enabled = exchangeEnabled;
		}

		private function init():void
		{
			this.graphics.beginFill(0xB68E6C, 0.4);
			this.graphics.drawRect(0, 0, 59, 59);
			this.graphics.drawRect(110, 0, 59, 59);

			this.selfElement = new CollectionExchangeElement();
			this.selfElement.x = this.selfElement.y = 7;
			addChild(this.selfElement);

			this.playerElement = new CollectionExchangeElement();
			this.playerElement.x = 117;
			this.playerElement.y = 7;
			addChild(this.playerElement);

			this.arrows = new ExchangeArrowsView();
			this.arrows.x = 65;
			this.arrows.y = 8;
			addChild(this.arrows);

			this.buttonExchange = new ButtonBase(gls("Обменять за") + " -    " + Game.COLLECTION_EXCHANGE_COST);
			this.buttonExchange.x = 200;
			this.buttonExchange.y = 15;
			this.buttonExchange.addEventListener(MouseEvent.CLICK, onExchange);
			addChild(this.buttonExchange);

			FieldUtils.replaceSign(this.buttonExchange.field, "-", ImageIconNut, 0.7, 0.7, -this.buttonExchange.field.x, -3, false, false);
		}

		private function onExchange(e:MouseEvent):void
		{
			if (!this.buttonExchange.enabled)
				return;

			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}