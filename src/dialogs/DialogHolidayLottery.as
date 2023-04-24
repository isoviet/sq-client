package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import buttons.ButtonBaseMultiLine;
	import events.GameEvent;
	import game.gameData.DeferredBonusManager;
	import game.gameData.GameConfig;
	import game.gameData.HolidayManager;
	import game.gameData.OutfitData;
	import loaders.RuntimeLoader;
	import loaders.ScreensLoader;
	import screens.ScreenRating;
	import sounds.GameSounds;
	import statuses.Status;
	import statuses.StatusClothes;
	import views.ClothesImageSmallLoader;
	import views.HolidayBonusView;
	import views.HolidayBoosterView;
	import views.PackageImageLoader;
	import views.content.PerkWidget;
	import views.customUI.ScrollDotted;

	import com.api.Services;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;

	import protocol.packages.server.structs.PacketDeferredBonusItems;

	import utils.FieldUtils;
	import utils.FiltersUtil;
	import utils.HtmlTool;
	import utils.MovieClipUtils;

	public class DialogHolidayLottery extends Dialog
	{
		static private const FORMAT_TICKETS_BIG_INFO:TextFormat = new TextFormat(null, 14, 0x5D280E, true, null, null, null, null, "center");
		static private const FORMAT_TICKETS_INFO:TextFormat = new TextFormat(null, 11, 0x5D280E, true, null, null, null, null, "center");
		static private const FORMAT_ELEMENTS:TextFormat = new TextFormat(null, 16, 0x5D280E, true, null, null, null, null, TextFormatAlign.CENTER);
		static private const FORMAT_ELEMENTS_WHITE:TextFormat = new TextFormat(null, 16, 0xffffff, true);

		static public const FORMAT_EXPIRES_CAPTION:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 10, 0xFFFFFF, null, null, null, null, null, "center");
		static public const FORMAT_EXPIRES:TextFormat = new TextFormat(null, 14, 0xFF4A27, true);

		static public const ROLL_TIMES:int = 6;

		static private const TEXTS:Array = [
			gls("{0} опыта", 50),
			gls("{0} энергии", 30),
			gls("{0} очков Рейтинга Озеленения", 10),
			gls("Зелье Могущества на 30 минут"),
			gls("VIP-статус на 30 минут"),
			gls("Купон Озеленения\nСобери 5 купонов и получи костюм"),
			gls("Неудача"),
			gls("{0} маны", 50),
			gls("Случайный элемент коллекций"),
			gls("{0} монет", 5)
			];

		static private const TEXTS_TICKET:Array = [
			gls("Бонус за первый купон:\n {0} орехов и {1} маны", 500, 500),
			gls("Бонус за второй купон:\n{0}", ClothesData.getTitleById(OutfitData.FARMER_HANDS)),
			gls("Бонус за третий купон:\n{0}", ClothesData.getTitleById(OutfitData.FARMER_TAIL)),
			gls("Бонус за четвертый купон:\n{0}", ClothesData.getTitleById(OutfitData.FARMER_HAIR)),
			gls("Бонус за пятый купон:\n Крутой костюм Фермера."),
			gls("Бонус за шестой купон:\n {0} орехов и {1} маны", 500, 500),
			gls("Бонус за седьмой купон:\n{0}",ClothesData.getTitleById(OutfitData.HARLOCK_CLOAK)),
			gls("Бонус за восьмой купон:\n{0}",ClothesData.getTitleById(OutfitData.HARLOCK_HANDS)),
			gls("Бонус за девятый купон:\n{0}",ClothesData.getTitleById(OutfitData.HARLOCK_TAIL)),
			gls("Бонус за десятый купон:\n Крутой костюм Харлока."),
			gls("Бонус за одиннадцатый купон:\n {0} орехов и {1} маны", 500, 500),
			gls("Бонус за двенадцатый купон:\n{0}",ClothesData.getTitleById(OutfitData.MINION_GLASSES)),
			gls("Бонус за тринадцатый купон:\n{0}",ClothesData.getTitleById(OutfitData.MINION_HANDS)),
			gls("Бонус за четырнадцатый купон:\n{0}",ClothesData.getTitleById(OutfitData.MINION_TAIL)),
			gls("Бонус за пятнадцатый купон:\n Крутой костюм Миньона."),
			gls("Бонус за шестнадцатый купон:\n {0} орехов и {1} маны", 500, 500),
			gls("Бонус за семнадцатый купон:\n{0}",ClothesData.getTitleById(OutfitData.FAIRY_CAT_NECK)),
			gls("Бонус за восемндцатый купон:\n{0}",ClothesData.getTitleById(OutfitData.FAIRY_CAT_TAIL)),
			gls("Бонус за девятнадцатый купон:\n{0}",ClothesData.getTitleById(OutfitData.FAIRY_CAT_HAIRBAND)),
			gls("Бонус за двадцатый купон:\n Крутой костюм Чешира.")
		];

		static public const ACCESSORIES:Array = [null, OutfitData.FARMER_HANDS, OutfitData.FARMER_TAIL, OutfitData.FARMER_HAIR, gls("Костюм\nФермера"),
			null, OutfitData.HARLOCK_CLOAK, OutfitData.HARLOCK_HANDS, OutfitData.HARLOCK_TAIL, gls("Костюм\nХарлока"),
			null, OutfitData.MINION_GLASSES, OutfitData.MINION_HANDS, OutfitData.MINION_TAIL, gls("Костюм\nМиньона"),
			null, OutfitData.FAIRY_CAT_NECK, OutfitData.FAIRY_CAT_TAIL, OutfitData.FAIRY_CAT_HAIRBAND, gls("Костюм\nЧешира")];

		static private var _types:Array = null;

		private var buttonSpin:ButtonBase = null;
		private var _view:MovieClip = null;

		private var animate:MovieClip = null;

		private var statusArray:Vector.<Status> = new <Status>[];
		private var imagesTicket:Vector.<Sprite> = new <Sprite>[];
		private var infoTicket:Vector.<Sprite> = new <Sprite>[];

		private var fieldElements:GameField = null;
		private var fieldExpires:GameField = null;

		private var spriteExpires:Sprite = null;

		private var currentStep:int = 0;
		private var direct:int = 0;
		private var onSpinning:Boolean = false;

		private var bonuses:Array = null;
		private var statusClothes:StatusClothes = null;

		private var scrollDotted:ScrollDotted = null;
		private var iconClothesMage:PerkWidget = null;

		static private function get types():Array
		{
			if (!_types)
				_types = [DeferredBonusManager.EXPERIENCE, DeferredBonusManager.ENERGY,
					DeferredBonusManager.HOLIDAY_RATING, DeferredBonusManager.MIGTHY_POTION,
					DeferredBonusManager.VIP, DeferredBonusManager.HOLIDAY_TICKET, DeferredBonusManager.EMPTY,
					DeferredBonusManager.MANA, DeferredBonusManager.COLLECTIONS, DeferredBonusManager.COINS
					];
			return _types;
		}

		static private function convertType(type:int):int
		{
			return types.indexOf(type);
		}

		public function DialogHolidayLottery():void
		{
			super(gls(HolidayManager.holidayName), true, true, null, false);
			init();
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 5;
			this.rightOffset = 20;
			this.topOffset = 10;
			this.bottomOffset = 0;
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, 29, 0xFFCC00, null, null, null, null, null, "center");
		}

		override public function show():void
		{
			super.show();

			this.bonuses = [];

			if (HolidayManager.isHolidayEnd)
				onTime();
			else
				EnterFrameManager.addPerSecondTimer(onTime);

			GameSounds.playRepeatable("spring", 1000*60 + 1000*14);
			scrollDotted.setSelected(HolidayManager.currentClothes);

			onElements();
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			HolidayManager.receiveBonus();

			GameSounds.stopRepeatable("spring");
		}

		private function init():void
		{
			addChild(this.view);
			this.view.x = -5;

			this.imagesTicket.push(this.view.imageTicket0, this.view.imageTicket1, this.view.imageTicket2, this.view.imageTicket3, this.view.imageTicket4);
			for (var i:int = 0; i < TEXTS.length; i++)
			{
				var sprite:Sprite = new Sprite();
				sprite.x = 52 + i * 77;
				sprite.y = 80;
				sprite.graphics.beginFill(0xFFFFFF, 0);
				sprite.graphics.drawRect(0, 0, 77, 96);
				this.view.addChild(sprite);

				new Status(sprite, TEXTS[i]);
			}

			var headerGameField:GameField = new GameField(gls(HolidayManager.description), 45, 23, FORMAT_ELEMENTS_WHITE);
			this.view.addChild(headerGameField);
			headerGameField.filters = [new DropShadowFilter(0, 0, 0x5D280E, 1, 2, 2, 2, 2)];

			new Status(this.view.imageRollFAQ, gls(HolidayManager.faqDescription));
			//new Status(this.view.lottery.imageBalance, HolidayManager.balanceDescription);

			this.view.buttonRating.addEventListener(MouseEvent.CLICK, showRating);
			new Status(this.view.buttonRating, gls(HolidayManager.ratingName));

			var buttonBuy:ButtonBase = new ButtonBase(gls("Купить"));
			buttonBuy.x = 163;
			buttonBuy.y = 189;//202 + int((42 - buttonBuy.height) * 0.5);
			buttonBuy.addEventListener(MouseEvent.CLICK, showBankElements);
			this.view.addChild(buttonBuy);

			this.buttonSpin = new ButtonBaseMultiLine(gls("Крутить за {0} -", HolidayManager.SPIN_PRICE) + "   ", 0, 21, null, 1.5);
			this.buttonSpin.addEventListener(MouseEvent.CLICK, onSpin);
			this.buttonSpin.x = 326;//402 - int(this.buttonSpin.width * 0.5);
			this.buttonSpin.y = 183;//202 + int((42 - this.buttonSpin.height) * 0.5);
			this.buttonSpin.enabled = !HolidayManager.isHolidayEnd && HolidayManager.haveElements && !this.onSpinning;

			this.buttonSpin.filters = this.buttonSpin.enabled ? [] : FiltersUtil.GREY_FILTER;
			this.view.addChild(this.buttonSpin);
			FieldUtils.replaceSign(this.buttonSpin.field, "-", ImageIconHoliday, 1, 1, -this.buttonSpin.field.x, -5, false, false);

			this.spriteExpires = new Sprite();
			this.spriteExpires.addChild(new BundleExpiredBack);
			this.spriteExpires.x = 25;
			this.spriteExpires.y = 425;
			this.spriteExpires.visible = false;
			this.view.addChild(this.spriteExpires);

			this.animate = this.view.bg.clip as MovieClip;
			MovieClipUtils.stopAll(this.animate, 1);

			var field:GameField = new GameField(gls("Закончится\nчерез"), 0, 5, FORMAT_EXPIRES_CAPTION);
			field.x = int((this.spriteExpires.width - field.textWidth) * 0.5) - 4;
			this.spriteExpires.addChild(field);

			this.fieldExpires = new GameField("", 0, 50, FORMAT_EXPIRES);
			this.spriteExpires.addChild(this.fieldExpires);

			this.fieldElements = new GameField("", 112, 191, FORMAT_ELEMENTS, 50);
			this.view.addChild(this.fieldElements);

			this.scrollDotted = new ScrollDotted(4, 200);
			this.scrollDotted.setOnChangeIndex(onUpdateClothes);
			this.scrollDotted.x = int(this.view.imagePackage.width/2 - 100);
			this.scrollDotted.y = int(this.view.imagePackage.height - 20);
			this.scrollDotted.setSelected(HolidayManager.currentClothes);
			this.view.imagePackage.addChild(this.scrollDotted);

			place();

			this.width = 850;
			this.height = 578;

			this.graphics.beginFill(0x000000, 0.1);
			this.graphics.drawRect(-this.x, -this.y, Config.GAME_WIDTH, Config.GAME_HEIGHT);

			onTickets();
			onElements();

			HolidayManager.addEventListener(GameEvent.HOLIDAY_CLOTHES, onClothesChange);
			HolidayManager.addEventListener(GameEvent.HOLIDAY_ELEMENTS, onElements);
			HolidayManager.addEventListener(GameEvent.HOLIDAY_LOTTERY, onLottery);
			HolidayManager.addEventListener(GameEvent.HOLIDAY_TICKETS, onTickets);

			this.view.addChild(new HolidayBoosterView());
		}

		private function onClothesChange(event:GameEvent):void
		{
			this.scrollDotted.setSelected(HolidayManager.currentClothes);
		}

		private function onUpdateClothes(index:int, direction:int = 0):void
		{
			if (direction) {}

			index = HolidayManager.CLOTHES[index];
			if (this.statusClothes)
			{
				this.statusClothes.remove();
				this.statusClothes = null;
			}

			for (var i:int = 0; i < this.view.imagePackage.numChildren; i++)
				if (this.view.imagePackage.getChildAt(i) is PackageImageLoader)
					this.view.imagePackage.removeChildAt(i);

			this.statusClothes = new StatusClothes(this.view.imagePackage, "<body><b><span class = 'center'>" +
				HtmlTool.span(ClothesData.getPackageTitleById(index), "green") +
				"</span></b><br/>" + ClothesData.getPackageDescriptionById(index) + "</body>");

			if (this.iconClothesMage)
				this.view.removeChild(this.iconClothesMage);

			this.iconClothesMage = new PerkWidget(GameConfig.getPackageSkills(index)[0]);
			this.iconClothesMage.x = 811;//213;
			this.iconClothesMage.y = 271;//25;
			this.iconClothesMage.visible = GameConfig.getPackageSkills(index).length > 0;
			this.view.addChild(this.iconClothesMage);

			var clotheImage:PackageImageLoader = new PackageImageLoader(index);
			clotheImage.x = int((this.view.imagePackage.width - clotheImage.width) * 0.5);
			clotheImage.y = int((this.view.imagePackage.height - clotheImage.height) * 0.5) - 15;
			this.view.imagePackage.addChild(clotheImage);
		}

		private function showRating(e:MouseEvent):void
		{
			hide();

			ScreenRating.selected = ScreenRating.HOLIDAY_TAB;
			ScreensLoader.load(ScreenRating.instance);
		}

		private function showBankElements(e:MouseEvent):void
		{
			RuntimeLoader.load(function():void
			{
				Services.bank.open();
			});
			DialogBank.setTab(DialogBank.TAB_INGREDIENTS);
		}

		private function onTime():void
		{
			this.spriteExpires.visible = HolidayManager.isShowTimer;
			this.fieldExpires.text = HolidayManager.timeLeftString;
			this.fieldExpires.x = int((72 - this.fieldExpires.textWidth) * 0.5);

			if (!HolidayManager.isHolidayEnd)
				return;

			this.buttonSpin.enabled = false;
			this.buttonSpin.filters = FiltersUtil.GREY_FILTER;
			EnterFrameManager.removePerSecondTimer(onTime);
		}

		private function onTickets(e:GameEvent = null):void
		{
			if (this.statusArray.length == 0 || (this.statusArray.length % HolidayManager.TICKETS_TO_PACKAGE == 0))
			{
				while (this.statusArray.length > 0)
					this.statusArray.shift().remove();
				while (this.infoTicket.length > 0)
				{
					var info:Sprite = this.infoTicket.shift();
					info.parent.removeChild(info);
				}
				for (var i:int = 0; i < this.imagesTicket.length; i++)
				{
					var id:int = HolidayManager.tickets < HolidayManager.MAX_TICKETS ?
						int(HolidayManager.tickets / HolidayManager.TICKETS_TO_PACKAGE) *
						HolidayManager.TICKETS_TO_PACKAGE + i :
						(HolidayManager.MAX_TICKETS - HolidayManager.TICKETS_TO_PACKAGE + i);
					this.statusArray.push(new Status(this.imagesTicket[i], TEXTS_TICKET[id]));

					info = getTicketImage(id);
					info.x = -int(info.width * 0.5) - 2;
					info.y = 50 - int(info.height * 0.5);
					this.imagesTicket[i].addChild(info);

					this.infoTicket.push(info);
				}
			}
			for (i = 0; i < this.imagesTicket.length; i++)
				this.imagesTicket[i].filters = ((HolidayManager.tickets % HolidayManager.TICKETS_TO_PACKAGE) > i) || HolidayManager.tickets == HolidayManager.MAX_TICKETS ? [] : FiltersUtil.GREY_FILTER;
		}

		private function onElements(e:GameEvent = null):void
		{
			this.fieldElements.text = HolidayManager.elements.toString();

			this.buttonSpin.enabled = !HolidayManager.isHolidayEnd && HolidayManager.haveElements && !this.onSpinning;
			this.buttonSpin.filters = this.buttonSpin.enabled ? [] : FiltersUtil.GREY_FILTER;
		}

		private function onSpin(e:MouseEvent):void
		{
			HolidayManager.spinLottery();
		}

		private function onLottery(e:GameEvent):void
		{
			this.buttonSpin.enabled = false;
			this.buttonSpin.filters = FiltersUtil.GREY_FILTER;
			this.buttonClose.enabled = false;

			GameSounds.play("halloween_roll_start");

			this.direct = ROLL_TIMES;
			this.currentStep = convertType(HolidayManager.currentBonus.type);
			this.onSpinning = true;
			EnterFrameManager.addListener(animationSpin);
		}

		private function animationSpin():void
		{
			var w:int = 77;
			var l:int = 31;

			var dX:int = this.speed * EnterFrameManager.delay;
			var dMax:int = this.direct % 2 == 0 ? (765 - this.view.lottery.viewRoll.x) : (this.view.lottery.viewRoll.x - l);
			if (this.direct == 0)
			{
				var pos:Number = l + w * this.currentStep;
				dMax = (pos) - this.view.lottery.viewRoll.x;
				dX = dX * (0.5 + 0.5 * (dMax / (pos)));
			}

			var currentDirect:int = (this.direct % 2 == 0 ? 1 : -1);
			if (dX > dMax)
			{
				dX = dMax;
				this.direct--;

				if (this.direct != -1)
					GameSounds.play("halloween_roll");
			}

			this.view.lottery.viewRoll.x += dX * currentDirect;

			if (this.direct == -1)
			{
				this.onSpinning = false;
				EnterFrameManager.removeListener(animationSpin);

				this.buttonSpin.enabled = !HolidayManager.isHolidayEnd && HolidayManager.haveElements && !this.onSpinning;
				this.buttonSpin.filters = this.buttonSpin.enabled ? [] : FiltersUtil.GREY_FILTER;
				this.buttonClose.enabled = true;

				if(this.currentStep != 6)
					onAnimationBag(HolidayManager.currentBonus);
			}
		}

		private function onDropGift():void
		{
			if (!HolidayManager.currentBonus)
				return;

			GameSounds.play("gift");

			if (!this.visible)
				HolidayManager.receiveBonus();
			else
				for each(var bonus:HolidayBonusView in this.bonuses)
					bonus.show(this.view);

			this.bonuses = [];

			TweenMax.to(this.animate, 30 / Game.stage.frameRate, {frame: 50, repeat: 0, ease: Linear.easeNone,
				onComplete: onEndAnimation, overwrite: true});
		}

		private function onAnimationBag(bonus:PacketDeferredBonusItems):void
		{
			GameSounds.play("sprout");
			MovieClipUtils.playAll(this.animate);

			var gift:HolidayBonusView = new HolidayBonusView(bonus.id, bonus.type, bonus.bonusId);
			this.bonuses.push(gift);

			var stopFrame:Number = 20;
			TweenMax.to(this.animate, stopFrame / Game.stage.frameRate, {frame: stopFrame, repeat: 0,
				ease: Linear.easeNone, onComplete: onDropGift, overwrite: true});
		}

		private function onEndAnimation():void
		{
			MovieClipUtils.stopAll(this.animate, this.animate.totalFrames-1);
		}

		private function get speed():int
		{
			return 386 + 770 * int((this.direct + 1) * 0.5);
		}

		private function getTicketImage(id:int):Sprite
		{
			var answer:Sprite = new Sprite();
			if (id % 5 == 0)
			{
				var field:GameField = new GameField("500", 0, 0, FORMAT_TICKETS_BIG_INFO);
				answer.addChild(field);
				var icon:DisplayObject = new ImageIconNut();
				icon.scaleX = icon.scaleY = 0.7;
				icon.x = field.textWidth + 5;
				answer.addChild(icon);

				field = new GameField("500", 0, 20, FORMAT_TICKETS_BIG_INFO);
				answer.addChild(field);
				icon = new ImageIconMana();
				icon.scaleX = icon.scaleY = 0.7;
				icon.x = field.textWidth + 5;
				icon.y = 20;
				answer.addChild(icon);
			}
			else if (id % 5 == 4)
			{
				field = new GameField(ACCESSORIES[id], 0, 0, FORMAT_TICKETS_INFO);
				answer.addChild(field);
			}
			else
			{
				icon = new ClothesImageSmallLoader(ACCESSORIES[id]);
				icon.scaleX = icon.scaleY = 0.7;
				icon.x = -10;
				icon.y = -15;
				answer.addChild(icon);
			}
			return answer;
		}

		private function get view():DialogHolidayLotteryView
		{
			if (!this._view)
				this._view = new DialogHolidayLotteryView();
			return this._view as DialogHolidayLotteryView;
		}
	}
}