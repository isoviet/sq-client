package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.DialogBank;
	import events.GameEvent;
	import game.gameData.BundleInsidesInfo;
	import game.gameData.BundleManager;
	import game.gameData.BundleModel;
	import game.gameData.ExpirationsManager;
	import statuses.Status;
	import views.customUI.ScrollDotted;
	import views.widgets.DiscountWidget;

	import com.greensock.TweenMax;

	public class BankBundleView extends Sprite
	{
		static public const FORMAT_CAPTION:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF);
		static public const FORMAT_EXPIRES_CAPTION:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 13, 0xFFFFFF, null, null, null, null, null, "center");
		static public const FORMAT_EXPIRES:TextFormat = new TextFormat(null, 14, 0xFF4A27, true);
		static public const FORMAT_DISCOUNT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 24, 0xFFFFFF);
		static public const FORMAT_PRICE:TextFormat = new TextFormat(null, 18, 0x63421B, true);
		static public const FORMAT_TEXT:TextFormat = new TextFormat(null, 12, 0x673401, true);

		static private var AUTO_SCROLL_DELAY: Number = 3000;

		static private var _instance:BankBundleView = null;
		static private var startValue:int = 17;

		private var bundleBuy:Function = null;

		private var fieldCaption:GameField = null;
		private var fieldPrice:GameField = null;
		private var fieldExpires:GameField = null;

		private var discountWidget:DiscountWidget = null;
		private var spriteSelect:Sprite = null;
		private var imageBundle:DisplayObject = null;
		private var spriteDetails:Sprite = null;
		private var spriteExpires:Sprite = null;

		private var statusAreas:Array = [];

		private var tweenImage:TweenMax = null;
		private var tweenDetails:TweenMax = null;
		private var tweenExpires:TweenMax = null;
		private var buttonBuy:ButtonBase = null;

		private var _current:int = -1;
		private var index:int = 0;
		private var selectedBundle: BundleModel = null;
		private var scrollView: ScrollDotted;
		private var imageBundleClone: DisplayObject = null;

		public function BankBundleView(bundleBuy:Function):void
		{
			_instance = this;

			this.bundleBuy = bundleBuy;

			startValue = BundleManager.ids != null && BundleManager.ids.length > 0 ? BundleManager.ids[0] : 1;

			init();

			BundleManager.addEventListener(GameEvent.BUNDLE_UPDATE, updateList);

			selectCurrent(BundleManager.ids[1]);
			this.scrollView.setSelected(BundleManager.ids[1]);
		}

		static public function selectCurrent(value:int):void
		{
			if (_instance)
			{
				_instance.current = value;
				_instance.index = BundleManager.ids.indexOf(_instance.current);
			}
			else
				startValue = value;
		}

		static public function getStatus(imageClass:Class):String
		{
			switch (imageClass)
			{
				case ImageGetBalloon:
					return gls("С помощью шариков можно попадать в недоступные для других места и сокращать путь до дупла или ореха! Рождённый лазать сможеть летать!");
				case ImageGetCoins:
					return gls("Монеты нужны в игре, чтобы стать сильнее, быстрее и иметь доступ к недоступным за орехи покупкам. Толще карман - больше возможностей!");
				case ImageGetCollections:
					return gls("Из элементов коллекции собираются наборы - за это даётся опыт. А за наборы коллекций можно получить уникальных персонажей - Скрэта и Скрэтти.");
				case ImageGetCollectionsRare:
					return gls("Редкие элементы коллекции не часто можно встретить на локации. Каждый из них поможет тебе собрать набор или несколько!");
				case ImageGetEnergy:
					return gls("Энергия используется для доступа на локации. Чем больше у тебя энергии, тем дольше сможешь играть без перерыва!");
				case ImageGetExp:
					return gls("Опыт позволяет получать новые уровни и открывать доступ к новым локациям и захватывающим режимам!");
				case ImageGetItemsPack:
					return gls("Набор предметов шамана всех типов сделает из тебя перспективного помощника шамана или грозу других белок... Решать тебе!");
				case ImageGetMana:
					return gls("Мана позволяет тебе творить заклинания и использовать способности костюмов. С такой магией любые преграды будут по плечу!");
				case ImageGetManaRegenDrink:
					return gls("Зелье могущества делает невозможное - позволяет мане восстанавливаться со временем! Это же неограниченные возможности в колдовстве!");
				case ImageGetPackage:
					return gls("Костюмы, наделяющие способностями и уникальной магией.. Ты получишь один из костюмов, который сейчас доступен в магазине.");
				case ImageGetPackageRare:
					return gls("Редкий костюм - это невероятная привелегия! Это один из костюмов, который был когда-то в игре, но сейчас уже недоступен для приобретения.");
				case ImageGetPackageVampire:
					return gls("Стильный и красочный костюм Вампира! Позволяет призвать стаю летучих мышей, которые принесут предмет коллекции на раунде своему хозяину.");
				case ImageGetPackageVendigo:
					return gls("Костюм Вендиго позволяет превратиться в быстрого Оборотня и забрать элемент коллекции у случайной белки.");
				case ImageGetPackageWizard:
					return gls("Уникальные костюмы Волшебника и Волшебницы, которые позволяют копировать заклинания других белок! Ты практически непобедим и всегда на шаг впереди других колдунов!");
				case ImageGetPackageWolf:
					return gls("Невероятно редкий костюм Снежного Волка. Позволяет вызывать снежную бурю, которая замедляет других белок, и замораживать элементы коллекций.");
				case ImageGetPowers:
					return gls("Энергия и мана в одном флаконе! Играй дольше и колдуй чаще. Получаемые энергия и мана пополняются сверх максимума.");
				case ImageGetVip:
					return gls("VIP-статус увеличивает максимум энергии, восстанавливает ману ежедневно, даёт одно воскрешение, удваивает получаемый на локации опыт и многое другое.");
				case ImageGetHolidayElements:
					return gls("Семена, необходимые для участия в Рулетке Озеленения, в которой можно выиграть восхитительные призы.");
				case ImageGetHolidayDouble:
					return gls("Удвоение собираемых ингредиентов на локации. Торопись! Время действия ограничено!");
			}
			return "";
		}

		private function init():void
		{
			var back:ImageBundleBack = new ImageBundleBack();
			back.scaleY = 1.15;

			back.width += 5;
			addChild(back);

			this.discountWidget = new DiscountWidget();
			addChild(this.discountWidget);

			this.fieldCaption = new GameField("", 0, 15, FORMAT_CAPTION);
			addChild(this.fieldCaption);

			this.fieldPrice = new GameField("", 0, 270, FORMAT_PRICE);
			addChild(this.fieldPrice);

			this.spriteExpires = new Sprite();
			this.spriteExpires.addChild(new BundleExpiredBack);
			this.spriteExpires.x = 408 - this.spriteExpires.width;
			this.spriteExpires.y = 50;
			addChild(this.spriteExpires);

			var field:GameField = new GameField(gls("Исчезнет\nчерез"), 0, 5, FORMAT_EXPIRES_CAPTION);
			field.x = int((this.spriteExpires.width - field.textWidth) * 0.5) - 4;
			this.spriteExpires.addChild(field);

			this.fieldExpires = new GameField("", 0, 50, FORMAT_EXPIRES);
			this.spriteExpires.addChild(this.fieldExpires);

			this.buttonBuy = new ButtonBase(gls("Купить"), 85);
			this.buttonBuy.x = 220;
			this.buttonBuy.y = 270;
			this.buttonBuy.addEventListener(MouseEvent.CLICK, onBuyItem);
			addChild(this.buttonBuy);

			this.spriteDetails = new Sprite();
			this.spriteDetails.alpha = 0;
			addChild(this.spriteDetails);

			this.spriteSelect = new Sprite();
			this.spriteSelect.graphics.beginFill(0xFFFFFF, 0);
			this.spriteSelect.graphics.drawRect(35, 45, 348, 210);
			this.spriteSelect.buttonMode = true;
			this.spriteSelect.addEventListener(MouseEvent.ROLL_OVER, onOver);
			this.spriteSelect.addEventListener(MouseEvent.ROLL_OUT, onOut);
			addChild(this.spriteSelect);

			var image:DisplayObject = new ImageBundleInfo();
			image.x = int((418 - image.width) * 0.5);
			image.y = 250;
			this.spriteSelect.addChild(image);

			field = new GameField(gls("Заглянуть внутрь"), 0, 245, new TextFormat(null, 14, 0x2CA7BB, true));
			field.x = image.x + 15 + int((image.width - field.textWidth - 15) * 0.5);
			this.spriteSelect.addChild(field);

			this.scrollView = new ScrollDotted(BundleManager.ids.length);
			this.scrollView.setOnChangeIndex(onScroll);
			this.scrollView.x = int((back.width - this.scrollView.width) * 0.5);
			this.scrollView.y = this.height - scrollView.height - 20;
			addChild(this.scrollView);

			updateList();

			var shape: Sprite = new Sprite();
			shape.graphics.beginFill(0x0000ff, 1);
			shape.graphics.drawRect(0, 0, back.width, this.height);
			shape.graphics.endFill();

			this.mask = shape;
			this.addChild(shape);
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;

			if (value)
				this.scrollView.startAutoScroll(AUTO_SCROLL_DELAY, ScrollDotted.DIRECTION_RIGHT);
			else
				this.scrollView.stopAutoScroll();
		}

		private function updateList(e:GameEvent = null):void
		{
			if (startValue == -1)
			{
				if (this.current != -1 && (BundleManager.ids.indexOf(this.current) != -1))
					this.index = BundleManager.ids.indexOf(this.current);
				this.current = BundleManager.ids[Math.min(this.index, BundleManager.ids.length - 1)];
			}
			else
				this.current = startValue;

			this.index = BundleManager.ids.indexOf(this.current);
			startValue = -1;
		}

		private function onBuyItem(e:MouseEvent):void
		{
			this.bundleBuy(this.current);
		}

		private function onScroll(index:int, direction:int): void
		{
			animScroll();

			this.imageBundleClone = BundleManager.getBundleById(BundleManager.ids[index]).image;
			this.imageBundleClone.y = int((300 - this.imageBundleClone.height) * 0.5);
			this.spriteSelect.addChild(this.imageBundleClone);

			var transLast:int = direction == ScrollDotted.DIRECTION_RIGHT ?  -200 : 500;
			var transNewStart:int = direction == ScrollDotted.DIRECTION_RIGHT ?  500 : -200;

			this.imageBundleClone.x = transNewStart;

			this.index = index;

			TweenMax.to(this.imageBundle, 0.2, {x: transLast, onComplete: animScroll});
			TweenMax.to(this.imageBundleClone, 0.2, {x: int((418 - this.imageBundleClone.width) * 0.5)});
		}

		private function animScroll(): void
		{
			if (this.imageBundleClone && this.spriteSelect.contains(this.imageBundleClone))
				this.spriteSelect.removeChild(this.imageBundleClone);
			this.imageBundleClone = null;

			this.current = BundleManager.ids[this.index];
		}

		private function onOut(e:MouseEvent):void
		{
			this.scrollView.startAutoScroll(AUTO_SCROLL_DELAY, ScrollDotted.DIRECTION_RIGHT);

			if (this.tweenImage)
				this.tweenImage.kill();
			this.tweenImage = TweenMax.to(this.spriteSelect, 0.1, {'alpha': 1});

			this.tweenExpires = TweenMax.to(this.spriteExpires, 0.1, {'alpha': 1});
			if (this.tweenDetails)
				this.tweenDetails.kill();
			this.tweenDetails = TweenMax.to(this.spriteDetails, 0.1, {'alpha': 0});
		}

		private function onOver(e:MouseEvent):void
		{
			this.scrollView.stopAutoScroll();

			if (this.tweenImage)
				this.tweenImage.kill();
			this.tweenImage = TweenMax.to(this.spriteSelect, 0.1, {'alpha': 0});
			if (this.tweenExpires)
				this.tweenExpires.kill();
			this.tweenExpires = TweenMax.to(this.spriteExpires, 0.1, {'alpha': 0});
			if (this.tweenDetails)
				this.tweenDetails.kill();
			this.tweenDetails = TweenMax.to(this.spriteDetails, 0.1, {'alpha': 1});
		}

		private function get current():int
		{
			return this._current;
		}

		private function set current(value:int):void
		{
			if (this._current == value)
				return;
			this._current = value > 0 ? value : 0;

			this.selectedBundle = BundleManager.getBundleById(value);

			if (this.visible)
				BundleManager.onShow(this.current);

			update();
		}

		private function update():void
		{
			if (this.imageBundle && this.spriteSelect.contains(this.imageBundle))
				this.spriteSelect.removeChild(this.imageBundle);
			this.imageBundle = selectedBundle.image;
			this.imageBundle.x = int((418 - this.imageBundle.width) * 0.5);
			this.imageBundle.y = int((300 - this.imageBundle.height) * 0.5);
			this.spriteSelect.addChild(this.imageBundle);

			var expired:Boolean = (this.current == BundleManager.NEWBIE_POOR || this.current == BundleManager.NEWBIE_RICH);
			this.spriteExpires.visible = expired;
			if (expired)
			{
				ExpirationsManager.addEventListener(GameEvent.ON_CHANGE, onChange);
				onChange(null);
			}
			else
				ExpirationsManager.removeEventListener(GameEvent.ON_CHANGE, onChange);

			updateDetails();

			this.fieldCaption.text = selectedBundle.name;
			this.fieldCaption.x = int((418 - this.fieldCaption.textWidth) * 0.5);

			this.discountWidget.discount = selectedBundle.discount;

			var bundle:BundleModel = BundleManager.getBundleById(this.current);
			this.fieldPrice.text = DialogBank.getPriceString(bundle.price);
			this.fieldPrice.x = 210 - this.fieldPrice.textWidth;
		}

		private function updateDetails():void
		{
			while (this.spriteDetails.numChildren > 0)
				this.spriteDetails.removeChildAt(0);
			while (this.statusAreas.length > 0)
				this.spriteSelect.removeChild(this.statusAreas.shift());

			var object:Vector.<BundleInsidesInfo> = selectedBundle.insidesInfo;

			for (var i:int = 0; i < object.length; i++)
			{
				var sprite:Sprite = new Sprite();
				sprite.x = (i % 2) * 180;
				sprite.y = int(i / 2) * 50;
				this.spriteDetails.addChild(sprite);

				var image:DisplayObject = new object[i].imageClass();
				sprite.addChild(image);

				var statusArea:Sprite = new Sprite();
				statusArea.x = sprite.x;
				statusArea.y = sprite.y;
				statusArea.graphics.beginFill(0xFFFFFF, 0);
				statusArea.graphics.drawRect(0, 0, 50, 50);
				this.spriteSelect.addChild(statusArea);
				this.statusAreas.push(statusArea);
				new Status(statusArea, getStatus(object[i].imageClass));

				var field:GameField = new GameField(object[i].description, image.width + 5, 0, FORMAT_TEXT);
				field.wordWrap = true;
				field.width = 145;
				field.y = (image.height - field.textHeight) * 0.5 - 2;
				sprite.addChild(field);
			}

			if (object.length > 1 && object.length % 2 == 1)
			{
				sprite.x += 90;
				statusArea.x += 90;
			}

			this.spriteDetails.graphics.clear();
			this.spriteDetails.graphics.beginFill(0x000000, 0);
			this.spriteDetails.graphics.drawRect(0, 0, object.length > 1 ? 360 : 180, (1 + int((object.length - 1) / 2)) * 60 - 10);

			this.spriteDetails.x = int((445 - this.spriteDetails.width) * 0.5);
			this.spriteDetails.y = int((380 - this.spriteDetails.height) * 0.5);

			for (i = 0; i < this.statusAreas.length; i++)
			{
				this.statusAreas[i].x += this.spriteDetails.x - this.spriteSelect.x;
				this.statusAreas[i].y += this.spriteDetails.y - this.spriteSelect.y;
			}
		}

		private function onChange(e:GameEvent):void
		{
			var type:int = -1;
			switch (this.current)
			{
				case BundleManager.NEWBIE_RICH:
					type = ExpirationsManager.BUNDLE_NEWBIE_RICH;
					break;
				case BundleManager.NEWBIE_POOR:
					type = ExpirationsManager.BUNDLE_NEWBIE_POOR;
					break;
				default:
					return;
			}
			this.fieldExpires.text = ExpirationsManager.getDurationString(type);
			this.fieldExpires.x = int((72 - this.fieldExpires.textWidth) * 0.5);
		}
	}
}