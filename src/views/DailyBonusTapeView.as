package views
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	import buttons.ButtonBase;
	import dialogs.DialogDailyBonusPackage;
	import dialogs.site.DialogDailyBonusPackageSite;
	import events.GameEvent;
	import game.gameData.DailyBonusManager;
	import loaders.RuntimeLoader;
	import statuses.Status;

	import com.greensock.TweenMax;

	import protocol.Connection;
	import protocol.PacketClient;

	public class DailyBonusTapeView extends Sprite
	{
		static private const AWARD_FORMAT:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 16, 0xFFF52C, true);
		static private const TEXT_FORMAT:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 16, 0x62411A, true);

		static private const IMAGE:Array = [DailyBonusImageNuts, DailyBonusImageEnergy, DailyBonusImageMana, DailyBonusImageExp, DailyBonusImageVIP, DailyBonusImageCoins, DailyBonusImagePackage];
		static private const IMAGE_FOR_SITE:Array = [DailyBonusImageNutsSite, DailyBonusImageEnergySite, DailyBonusImageManaSite, DailyBonusImageExpSite, DailyBonusImageVIPSite, DailyBonusImageCoinsSite, DailyBonusImagePackageSite];

		static private const TOOLTIPS:Array = [gls("10 орехов"), gls("25 энергии"), gls("50 маны"), gls("50 опыта"), gls("VIP-статус на час"), gls("1 монетка"), gls("Костюм на сутки")];
		static private const TOOLTIPS_FOR_SITE:Array = [gls("500 орехов"), gls("300 энергии"), gls("300 маны"), gls("500 опыта"), gls("VIP-статус на сутки"), gls("5 монеток"), gls("Два костюма на сутки")];

		static private var _awards:Array = null;

		static private const FRAME_NO:String = "no";
		static private const FRAME_GET:String = "get";
		static private const FRAME_LAST:String = "last";
		static private const FRAME_PASSED:String = "passed";

		private var images:Vector.<Sprite> = new Vector.<Sprite>();

		private var packageImage:DisplayObject = null;
		private var movie:MovieClip = null;
		private var button:ButtonBase = null;

		private var fieldTimer:GameField = null;
		private var showDialog:Boolean = false;
		private var getAward:Boolean = false;

		static private function get awards():Array
		{
			if (_awards == null)
				_awards = [[Game.site? 500 : 10, ImageIconNut],
					[Game.site? 300 : 25, ImageIconEnergy],
					[Game.site? 300 : 50, ImageIconMana],
					[Game.site? 500 : 50, ImageIconExp],
					[(Game.site? "24 " : "1 ") + gls("ч."), ImageIconVIP],
					[Game.site? 5 : 1, ImageIconCoins]];
			return _awards;
		}

		public function DailyBonusTapeView():void
		{
			init();

			DailyBonusManager.addEventListener(GameEvent.DAILY_BONUS_UPDATE, update);
			DailyBonusManager.addEventListener(GameEvent.DAILY_BONUS_GET, showAward);
		}

		private function init():void
		{
			var images:Array = Game.site? IMAGE_FOR_SITE : IMAGE;
			var tooltips:Array = Game.site? TOOLTIPS_FOR_SITE : TOOLTIPS;

			for (var i:int = 0; i < images.length; i++)
			{
				var sprite:Sprite = new Sprite();
				sprite.x = 68 + 120 * i;
				sprite.mouseEnabled = false;
				addChild(sprite);

				var frame:DailyBonusFrame = new DailyBonusFrame();
				frame.gotoAndStop(FRAME_GET);
				frame.name = "bg";
				sprite.addChild(frame);

				new Status(frame, tooltips[i]);

				var field:GameField = new GameField(gls("День {0}", (i + 1)), 0, -50, TEXT_FORMAT);
				field.x = -int(field.textWidth * 0.5);
				field.mouseEnabled = false;
				sprite.addChild(field);

				var imageClass:Class = images[i];
				var image:DisplayObject = new imageClass();
				image.x = -int(image.width * 0.5);
				image.y = -int(image.height * 0.5) + 7;
				sprite.addChild(image);

				if(image is MovieClip && (image as MovieClip).totalFrames > 1)
					(image as MovieClip).gotoAndStop(Config.LOCALE);

				if (i == DailyBonusManager.PACKAGE)
					this.packageImage = image;
				new Status(image, tooltips[i]);

				this.images.push(sprite);
			}

			this.movie = new DailyBonusMovieGlow();
			this.movie.mouseChildren = false;
			this.movie.mouseEnabled = false;

			this.button = new ButtonBase(gls("Забрать"), 85);
			this.button.x = Config.isRus ? -47 : -40;
			this.button.y = 45;
			this.button.addEventListener(MouseEvent.CLICK, onClick);

			update();
		}

		private function update(e:GameEvent = null):void
		{
			this.movie.visible = DailyBonusManager.haveBonus;
			this.button.visible = DailyBonusManager.haveBonus;
			if (DailyBonusManager.haveBonus)
			{
				this.images[DailyBonusManager.currentDay].addChildAt(this.movie, 1);
				this.images[DailyBonusManager.currentDay].addChild(this.button);
				addChild(this.images[DailyBonusManager.currentDay]);
			}

			for (var i:int = 0; i < this.images.length; i++)
			{
				var bg:MovieClip = (this.images[i] as Sprite).getChildByName('bg') as MovieClip;

				if(i == 6 && i == DailyBonusManager.currentDay && !DailyBonusManager.haveBonus)
					bg.gotoAndStop(FRAME_PASSED);
				else if(i == 6)
					bg.gotoAndStop(FRAME_LAST);
				else if(i < DailyBonusManager.currentDay || (i == DailyBonusManager.currentDay && !DailyBonusManager.haveBonus))
					bg.gotoAndStop(FRAME_GET);
				else
					bg.gotoAndStop(FRAME_NO);
			}

			if (DailyBonusManager.packageIds.length <= 0)
				return;
			RuntimeLoader.load(function():void
			{
				showPackage();
			}, true);
		}

		private function showPackage():void
		{
			if (this.getAward)
				return;

			this.getAward = true;

			if(!Game.site)
				this.packageImage.visible = false;

			for (var i:int = 0; i < DailyBonusManager.packageIds.length && !Game.site; i++)
			{
				var image:PackageImageLoader = new PackageImageLoader(DailyBonusManager.packageIds[i]);
				image.scaleX = image.scaleY = 0.5;
				image.x = -int(image.width * 0.5);
				image.y = -int(image.height * 0.5);
				this.images[DailyBonusManager.PACKAGE].addChild(image);
			}

			this.fieldTimer = new GameField("", 0, 0, new TextFormat(GameField.PLAKAT_FONT, 20, 0xB80F0F));
			this.fieldTimer.filters = [new DropShadowFilter(0, 0, 0x000000, 1.0, 4, 4)];
			this.images[DailyBonusManager.PACKAGE].addChild(this.fieldTimer);

			if (this.showDialog)
			{
				this.showDialog = false;
				if(DailyBonusManager.packageIds.length == 1)
					new DialogDailyBonusPackage(DailyBonusManager.packageIds[0]).show();
				else
					new DialogDailyBonusPackageSite(DailyBonusManager.packageIds).show();

			}

			EnterFrameManager.addPerSecondTimer(onTimer);
			onTimer();
		}

		private function showAward(e:GameEvent = null):void
		{
			if (DailyBonusManager.currentDay >= awards.length)
				return;
			var imageClass:Class = awards[DailyBonusManager.currentDay][1];
			var image:DisplayObject = new imageClass();
			image.scaleX = image.scaleY = 1.2;

			var awardsValueView:GameBonusValueView = new GameBonusValueView(awards[DailyBonusManager.currentDay][0], this.x + this.images[DailyBonusManager.currentDay].x, this.y + this.images[DailyBonusManager.currentDay].y, AWARD_FORMAT);
			Game.gameSprite.addChild(awardsValueView);

			var awardImageView:GameBonusImageView = new GameBonusImageView(image, awardsValueView.x + int(awardsValueView.width) + 3, awardsValueView.y + int(0.5 * (awardsValueView.height - image.height)), 165, 7);
			Game.gameSprite.addChild(awardImageView);
		}

		private function onClick(e:MouseEvent):void
		{
			DailyBonusManager.haveBonus = false;
			this.button.visible = DailyBonusManager.haveBonus;

			var image:DisplayObject = this.images[DailyBonusManager.currentDay];
			TweenMax.to(image, 0.1, {'scaleX': 1.15, 'scaleY': 1.15, 'onComplete': function():void
			{
				TweenMax.to(image, 0.1, {'scaleX': 0.95, 'scaleY': 0.95, 'onComplete': function():void
				{
					TweenMax.to(image, 0.1, {'scaleX': 1.05, 'scaleY': 1.05, 'onComplete': function():void
					{
						TweenMax.to(image, 0.1, {'scaleX': 1, 'scaleY': 1});
					}});
				}});
			}});

			TweenMax.to(movie, 0.2, {'scaleX': 1.5, 'scaleY': 1.5, 'onComplete': function():void
			{
				TweenMax.to(movie, 0.2, {'scaleX': 0.25, 'scaleY': 0.25, 'onComplete': function():void
				{
					movie.visible = false;
				}});
			}});

			this.showDialog = true;
			Connection.sendData(PacketClient.EVERY_DAY_BONUS_GET);
		}

		private function onTimer():void
		{
			if (!this.fieldTimer)
				return;
			var timeLeft:int = Math.max(0, DailyBonusManager.timeleft - int(getTimer() / 1000));
			this.fieldTimer.text = new Date(0, 0, 0, 0, 0, timeLeft).toTimeString().slice(0, 8);
			this.fieldTimer.x = -int(fieldTimer.textWidth * 0.5);

			if (timeLeft == 0)
				EnterFrameManager.removePerSecondTimer(onTimer);
		}
	}
}