package tape
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;

	import buttons.ButtonDouble;
	import buttons.ButtonEditableText;
	import statuses.Status;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class TapeDecorationsElement extends TapeObject
	{
		static private const BUTTON_WIDTH:int = 74;
		static private const BUTTON_HEIGHT:int = 59;

		public var id:int;

		private var active:DisplayObject;
		private var noactive:DisplayObject;

		private var setButton:ButtonDouble;
		private var setButtonStatus:Status;

		private var buyButtonAc:ButtonEditableText = null;
		private var buyButtonCo:ButtonEditableText = null;

		public function TapeDecorationsElement(itemId:int):void
		{
			this.id = itemId;

			super();

			var states:TapeEditButton = new TapeEditButton;
			this.noactive = states.upState;
			this.noactive.scaleX = this.noactive.scaleY = 1.5;
			addChild(this.noactive);

			this.active = states.downState;
			this.active.scaleX = this.active.scaleY = 1.5;
			this.active.visible = false;
			addChild(this.active);

			var icon:MovieClip = new (InteriorData.getTapeClass(itemId))();
			var scale:Number = 50 / Math.max(icon.width, icon.height);
			var rect:Rectangle = icon.getRect(icon);
			icon.scaleX = scale;
			icon.scaleY = scale;
			icon.x = -rect.left * scale + int((BUTTON_WIDTH - icon.width) / 2);
			icon.y = -rect.top * scale + int((BUTTON_HEIGHT - icon.height) / 2);
			icon.mouseChildren = false;
			icon.mouseEnabled = false;
			addChild(icon);

			var hitSprite:Sprite = new Sprite();
			hitSprite.graphics.beginFill(0x000000, 0);
			hitSprite.graphics.drawRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
			hitSprite.graphics.endFill();
			addChild(hitSprite);

			var setDecorationButton:SetDecorationButton = new SetDecorationButton();
			setDecorationButton.addEventListener(MouseEvent.CLICK, setDecoration);

			var hideDecorationButton:HideDecorationButton = new HideDecorationButton();
			hideDecorationButton.addEventListener(MouseEvent.CLICK, hideDecoration);

			this.setButton = new ButtonDouble(setDecorationButton, hideDecorationButton, true);
			this.setButton.x = 60;
			this.setButton.y = -3;
			this.setButton.alpha = 0;
			addChild(this.setButton);
			this.setButtonStatus = new Status(this.setButton, gls("Скрыть"));

			var context:String = "";
			if (InteriorData.getType(itemId) == InteriorData.VASE)
				context = gls("<br>Для установки требуется стол");
			if (InteriorData.getType(itemId) == InteriorData.CURTAINS)
				context = gls("<br>Для установки требуется окно");
			new Status(hitSprite, "<body>" + InteriorData.getTitle(itemId) + "<span class='small'>" + context + "</span></body>", false, true);

			var priceFormat:TextFormat = new TextFormat(null, 14, 0x302101, true);

			if (this.item['gold_cost'] > 0)
			{
				this.buyButtonCo = new ButtonEditableText(new ButtonBuySmall, priceFormat, -1, 1);
				this.buyButtonCo.textField.wordWrap = true;
				this.buyButtonCo.textField.multiline = true;
				this.buyButtonCo.x = (this.item['acorn_cost'] > 0) ? -1 : 16;
				this.buyButtonCo.y = 53;
				this.buyButtonCo.textField.text = " -" + this.item['gold_cost'];
				this.buyButtonCo.addEventListener(MouseEvent.CLICK, buy, false, 0, true);
				addChild(this.buyButtonCo);
				FieldUtils.replaceSign(this.buyButtonCo.textField, "-", ImageIconCoins, 0.6, 0.6, -this.buyButtonCo.textField.x + 5, -2, false);
				this.buyButtonCo.scaleX = this.buyButtonCo.scaleY = 0.75;
			}

			if (this.item['acorn_cost'] > 0)
			{
				this.buyButtonAc = new ButtonEditableText(new ButtonBuySmall, priceFormat, -1, 1);
				this.buyButtonAc.textField.wordWrap = true;
				this.buyButtonAc.textField.multiline = true;
				this.buyButtonAc.x = (this.item['gold_cost'] > 0) ? 39 : 16;
				this.buyButtonAc.y = 53;
				this.buyButtonAc.textField.text = " -" + (this.item['acorn_cost'] >= 1000 ? int(this.item['acorn_cost'] / 1000) + "к" : this.item['acorn_cost']);
				this.buyButtonAc.addEventListener(MouseEvent.CLICK, buyAcorn, false, 0, true);
				addChild(this.buyButtonAc);
				FieldUtils.replaceSign(this.buyButtonAc.textField, "-", ImageIconNut, 0.6, 0.6, -this.buyButtonAc.textField.x + 5, -2, false);
				this.buyButtonAc.scaleX = this.buyButtonAc.scaleY = 0.75;
			}

			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}

		public function get selected():Boolean
		{
			return this.active.visible;
		}

		public function set selected(value:Boolean):void
		{
			this.noactive.visible = !value;
			this.active.visible = value;
			this.setButton.setState(!value);
			this.setButtonStatus.setStatus(value ? gls("Скрыть") : gls("Установить"));
			this.setButton.visible = (value ? InteriorManager.getHideAvailable(this.id) : InteriorManager.getSetAvailable(this.id));
		}

		public function get bougth():Boolean
		{
			return InteriorManager.haveDecoration(this.id);
		}

		public function set bougth(value:Boolean):void
		{
			if (this.buyButtonAc)
				this.buyButtonAc.visible = !value;
			if (this.buyButtonCo)
				this.buyButtonCo.visible = !value;
			this.setButton.visible = this.setButton.visible && value;
		}

		private function get item():Object
		{
			return InteriorData.DATA[this.id];
		}

		private function setDecoration(e:MouseEvent):void
		{
			e.stopImmediatePropagation();

			InteriorManager.setDecoration(this.id);
		}

		private function hideDecoration(e:MouseEvent):void
		{
			e.stopImmediatePropagation();

			InteriorManager.hideDecoration(this.id);
		}

		private function onOver(e:MouseEvent):void
		{
			this.setButton.alpha = this.bougth ? 1 : 0;

			InteriorManager.previewId = this.id;
		}

		private function onOut(e:MouseEvent):void
		{
			this.setButton.alpha = 0;

			InteriorManager.previewId = -1;
		}

		private function buy(e:MouseEvent):void
		{
			var cost:int = ("gold_cost" in this.item ? this.item['gold_cost'] : 0);

			Game.buyWithoutPay(PacketClient.BUY_DECORATION, cost, 0, Game.selfId, this.id);
		}

		private function buyAcorn(e:MouseEvent):void
		{
			var cost:int = ("acorn_cost" in this.item ? this.item['acorn_cost'] : 0);

			Game.buyWithoutPay(PacketClient.BUY_DECORATION, 0, cost, Game.selfId, this.id);
		}
	}
}