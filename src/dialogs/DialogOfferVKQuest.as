package dialogs
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import fl.containers.ScrollPane;

	import buttons.ButtonBase;
	import dialogs.bank.DialogBankVK;
	import sounds.GameSounds;
	import statuses.Status;
	import views.GradientText;

	import com.api.Services;

	import utils.StringUtil;

	public class DialogOfferVKQuest extends DialogOfferQuest
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #3C1D07;
				font-weight: bold;
			}
			.instruction {
				font-weight: normal;
			}
		]]>).toString();

		private var offers:Array = null;

		private var current:int = 0;

		private var textCaption:GradientText = null;
		private var textAward:GradientText = null;

		private var descriptionField:GameField = null;
		private var instructionField:GameField = null;

		private var buttonsSprite:Sprite;

		private var scrollPaneFAQ:ScrollPane = new ScrollPane();

		public function DialogOfferVKQuest():void
		{
			super();

			init();
		}

		override public function setOffers(offers:Array, success:Function):void
		{
			this.offers = offers;

			this.buttonsSprite.visible = (this.offers.length > 1);

			this.success = success;
			setCurrent(0);
		}

		override protected function showOffer(e:MouseEvent):void
		{
			Services.showOfferBox(this.offers[this.current]['id']);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var format:TextFormat = new TextFormat(null, 24, 0x3C1D07, true, null, null, null, null, "center");

			this.textCaption = new GradientText("", format, [0xFAE8CE, 0xBD955A], [new GlowFilter(0x463030, 1, 5, 5, 8)]);
			this.textCaption.x = 140;
			this.textCaption.width = 340;
			this.textCaption.y = 100;
			addChild(this.textCaption);

			this.descriptionField = new GameField("", 155, 135, style);
			this.descriptionField.width = 340;
			this.descriptionField.wordWrap = true;
			this.descriptionField.multiline = true;
			addChild(this.descriptionField);

			this.scrollPaneFAQ = new ScrollPane();
			this.scrollPaneFAQ.setSize(255, 200);
			this.scrollPaneFAQ.x = 250;
			this.scrollPaneFAQ.y = 140;

			var spriteFAQ:Sprite = new Sprite();

			this.instructionField = new GameField("11", 0, 0, style);
			this.instructionField.width = 240;
			this.instructionField.wordWrap = true;
			this.instructionField.multiline = true;
			spriteFAQ.addChild(this.instructionField);

			this.scrollPaneFAQ.source = spriteFAQ;
			addChild(this.scrollPaneFAQ);

			var formatAward:TextFormat = new TextFormat(null, 20, 0x3C1D07, true);

			var awardImage:OfferVKAwardImage = new OfferVKAwardImage();
			awardImage.x = 240;
			awardImage.y = 330;
			addChild(awardImage);

			this.textAward = new GradientText("", formatAward, [0xF4CE95, 0xF4CE95], [new GlowFilter(0x663300, 1, 5, 5, 8)]);
			this.textAward.x = 230;
			this.textAward.y = 385;
			addChild(this.textAward);

			this.bannerWidth = 100;
			this.bannerHeight = 60;

			this.banner.x = 130;
			this.banner.y = 224 - 5;

			this.buttonsSprite = new Sprite();
			addChild(this.buttonsSprite);

			var buttonLeft:ButtonRewindLeft = new ButtonRewindLeft();
			buttonLeft.x = 150;
			buttonLeft.y = 360;
			buttonLeft.addEventListener(MouseEvent.CLICK, nextLeft);
			new Status(buttonLeft, gls("Предыдущее предложение"));
			this.buttonsSprite.addChild(buttonLeft);

			var buttonRight:ButtonRewindRight = new ButtonRewindRight();
			buttonRight.x = 480;
			buttonRight.y = 360;
			buttonRight.addEventListener(MouseEvent.CLICK, nextRight);
			new Status(buttonRight, gls("Следующее предложение"));
			this.buttonsSprite.addChild(buttonRight);

			GameSounds.handSoundControll([buttonLeft, buttonRight]);

			var button:ButtonBase = new ButtonBase(gls("Выполнять"));
			button.x = this.banner.x + 20;
			button.y = this.banner.y + 90;
			button.addEventListener(MouseEvent.CLICK, showOffer);
			addChild(button);
		}

		private function setCurrent(id:int):void
		{
			this.current = id;

			if (this.current < 0)
				this.current = this.offers.length - 1;
			if (this.current > this.offers.length - 1)
				this.current = 0;

			loadPhoto(this.offers[this.current]['img']);
			updateDescription();
		}

		private function updateDescription():void
		{
			this.textCaption.text = this.offers[this.current]['title'];

			this.descriptionField.y = this.textCaption.y + this.textCaption.height - 5;
			this.descriptionField.text = "<body>" + this.offers[this.current]['short_description'] + "</body>";

			this.scrollPaneFAQ.y = this.descriptionField.y + this.descriptionField.height + 5;
			this.scrollPaneFAQ.height = 329 - this.scrollPaneFAQ.y;
			trace(this.offers[this.current]['instruction']);
			this.instructionField.text = "<body><span class='instruction'>" + this.offers[this.current]['instruction'] + "</span></body>";

			var award:int = getCoins(this.offers[this.current]['price']);
			this.textAward.text = String(award) + " " + StringUtil.word("монет", award);
			this.textAward.x = 240 + 78 - this.textAward.width;

			this.scrollPaneFAQ.update();
		}

		private function nextLeft(e:MouseEvent):void
		{
			setCurrent(this.current - 1);
		}

		private function nextRight(e:MouseEvent):void
		{
			setCurrent(this.current + 1);
		}

		private function getCoins(price:int):int
		{
			return price * DialogBankVK.RATE_BY_COINS;
		}
	}
}