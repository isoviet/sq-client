package views
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	import game.gameData.CollectionsData;
	import game.gameData.GameConfig;
	import game.gameData.HolidayManager;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import utils.FiltersUtil;

	public class GameEventElementView extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #623E19;
			}
				]]>).toString();

		static private var NUMBER_IMAGES:Array = null;
		static private var NUMBER_SCALING:Array = [1.0, 0.75, 0.6];

		static private const IMAGES_LEAGUES:Array = [RatingIconNone, RatingIconBronze, RatingIconSilver, RatingIconGold, RatingIconMaster, RatingIconDiamond, RatingIconChampion];

		static private const FORMAT_CAPTION:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14, 0xFC7927);

		static public const LEVEL:int = 0;
		static public const LEAGUE:int = 1;
		static public const COLLECTION:int = 2;
		static public const AWARD:int = 3;
		static public const HOLIDAY:int = 4;

		static private const LIFE_TIME:int = 30;

		static private var style:StyleSheet = null;

		private var lifeTime:int = 0;
		private var extraTime:Number = 0;

		private var button:SimpleButton = null;
		private var view:Sprite = null;

		private var tween:TweenMax = null;

		private var _stopped:Boolean = false;
		private var onAnim:Boolean = false;

		public var type:int = 0;
		public var id:int = 0;
		public var value:int = 0;

		static private function get numberImages():Array
		{
			if (!NUMBER_IMAGES)
				NUMBER_IMAGES = [ImageLevelUp0, ImageLevelUp1, ImageLevelUp2, ImageLevelUp3, ImageLevelUp4, ImageLevelUp5, ImageLevelUp6, ImageLevelUp7, ImageLevelUp8, ImageLevelUp9];
			return NUMBER_IMAGES;
		}

		public function GameEventElementView(type:int, id:int, value:int):void
		{
			if (!style)
			{
				style = new StyleSheet();
				style.parseCSS(CSS);
			}

			this.lifeTime = int(getTimer() / 1000);

			this.type = type;
			this.id = id;
			this.value = value;

			init();
		}

		public function start():void
		{
			TweenMax.to(this, 0.5, {'x': 0, 'ease': Back.easeOut, 'onComplete': onComplete});
		}

		public function stop():void
		{
			this.onAnim = true;
			this.view.visible = false;
			this.button.removeEventListener(MouseEvent.CLICK, switchView);

			Game.stage.removeEventListener(MouseEvent.CLICK, onClick);
			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			EnterFrameManager.removeListener(onTime);

			TweenMax.to(this, 0.5, {'x': -40, 'ease': Back.easeIn, 'onComplete': onStop});
		}

		public function set offsetY(value:int):void
		{
			if (this.tween)
				this.tween.kill();
			this.tween = TweenMax.to(this, 0.5, {'y': value});
		}

		public function get expired():Boolean
		{
			return !this.onAnim && (this.lifeTime + this.extraTime + LIFE_TIME < int(getTimer() / 1000));
		}

		public function get stopped():Boolean
		{
			return this._stopped;
		}

		private function init():void
		{
			this.x = -40;

			this.button = getButton();
			addChild(this.button);

			this.view = getView();
			this.view.x = 40;
			this.view.visible = false;
			this.view.alpha = 0;
			addChild(this.view);
		}

		private function onTime():void
		{
			this.extraTime += this.view.visible ? EnterFrameManager.delay : 0;
		}

		private function onComplete():void
		{
			this.button.addEventListener(MouseEvent.CLICK, switchView);
		}

		private function onStop():void
		{
			this._stopped = true;
		}

		private function switchView(e:MouseEvent):void
		{
			this.view.visible = !this.view.visible;

			if (this.view.visible)
			{
				Game.stage.addEventListener(MouseEvent.CLICK, onClick);
				Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
				EnterFrameManager.addListener(onTime);

				TweenMax.to(this.view, 0.2, {'alpha': 1.0});
			}
			else
				stop();
		}

		private function onClick(e:MouseEvent):void
		{
			var target:Object = e.target;
			while (target != null)
			{
				if (target == this)
					return;
				target = target.parent;
			}
			this.view.visible = false;

			stop();
		}

		private function onKey(e:KeyboardEvent):void
		{
			this.view.visible = false;

			stop();
		}

		private function getButton():SimpleButton
		{
			var spriteUp:Sprite = new Sprite();
			spriteUp.graphics.beginFill(0xF7F0DD);
			spriteUp.graphics.lineStyle(1, 0xDDC9AF);
			spriteUp.graphics.drawRect(0, 0, 40, 40);
			spriteUp.addChild(getImageSmall());

			var spriteOver:Sprite = new Sprite();
			spriteOver.graphics.beginFill(0xFAF3DF);
			spriteOver.graphics.lineStyle(1, 0xDDC9AF);
			spriteOver.graphics.drawRect(0, 0, 40, 40);
			spriteOver.addChild(getImageSmall());

			var spriteDown:Sprite = new Sprite();
			spriteDown.graphics.beginFill(0xF4ECDA);
			spriteDown.graphics.lineStyle(1, 0xDDC9AF);
			spriteDown.graphics.drawRect(0, 0, 40, 40);
			spriteDown.addChild(getImageSmall());

			var spriteHit:Sprite = new Sprite();
			spriteHit.graphics.beginFill(0x000000, 0);
			spriteHit.graphics.drawRect(0, 0, 40, 40);

			return new SimpleButton(spriteUp, spriteOver, spriteDown, spriteHit);
		}

		private function getView():Sprite
		{
			var answer:Sprite = new Sprite();
			answer.graphics.beginFill(0xF7F0DD);
			answer.graphics.lineStyle(1, 0xDDC9AF);
			answer.graphics.drawRoundRectComplex(0, 0, 290, 85, 0, 5, 0, 5);

			switch (type)
			{
				case LEVEL:
					var image:DisplayObject = new Sprite();
					(image as Sprite).addChild(new GameEventLevelBack);

					var subImage:Sprite = getImageFromNumber(this.value);
					subImage.x = 5 + int((image.width - subImage.width) * 0.5);
					subImage.y = int(image.height * 0.5);
					(image as Sprite).addChild(subImage);

					image.x = 5;
					image.y = 5;
					answer.addChild(image);

					answer.addChild(new GameField(gls("Новый Уровень!"), 80, 10, FORMAT_CAPTION));
					answer.addChild(new GameField("<body>" + gls("Тебе удалось достичь\n<b>{0} уровня!</b>", value) + "</body>", 80, 25, style, 205));
					break;
				case LEAGUE:
					image = new IMAGES_LEAGUES[this.value];
					image.scaleX = image.scaleY = 1.5;
					image.x = 40;
					image.y = 40;
					answer.addChild(image);

					answer.addChild(new GameField(gls("Новая Лига!"), 80, 10, FORMAT_CAPTION));
					answer.addChild(new GameField("<body>" + gls("Тебе удалось перейти в лигу <b>{0}!</b>", GameConfig.getLeagueName(value, id)) + "</body>", 80, 25, style, 205));
					break;
				case COLLECTION:
					var collectionView:CollectionSetDemoView = new CollectionSetDemoView();
					collectionView.setItem(this.id);
					collectionView.x = 27;
					collectionView.y = 5;
					answer.addChild(collectionView);
					break;
				case AWARD:
					image = Award.getImage(this.id);
					image.width = image.height = 65;
					image.x = image.y = 10;
					answer.addChild(image);

					if (this.value == 100)
					{
						answer.addChild(new GameField(gls("Получено достижение!"), 80, 10, FORMAT_CAPTION));
						answer.addChild(new GameField("<body>" + gls("Тебе удалось заработать достижение <b>{0}!</b>", Award.DATA[id]['name']) + "</body>", 80, 25, style, 205));
					}
					else
					{
						answer.addChild(new GameField(gls("Прогресс в достижении!"), 80, 10, FORMAT_CAPTION));
						answer.addChild(new GameField("<body>" + gls("Достижение <b>{0}</b> выполнено на {1}%.", Award.DATA[id]['name'], value) + "</body>", 80, 25, style, 205));
					}
					break;
				case HOLIDAY:
					image = new ImageIconHoliday();
					image.scaleX = image.scaleY = 2.5;
					image.x = 10;
					image.y = 15;
					answer.addChild(image);

					answer.addChild(new GameField(HolidayManager.elementEventName, 80, 10, FORMAT_CAPTION));
					answer.addChild(new GameField("<body>" + HolidayManager.elementEventDescription + "</body>", 80, 25, style, 205));
					break;
			}
			return answer;
		}

		private function getImageSmall():DisplayObject
		{
			var image:DisplayObject = null;
			switch (this.type)
			{
				case LEVEL:
					image = new Sprite();
					(image as Sprite).addChild(new GameEventLevelBack);

					var subImage:Sprite = getImageFromNumber(this.value);
					subImage.x = 5 + int((image.width - subImage.width) * 0.5);
					subImage.y = int(image.height * 0.5);
					(image as Sprite).addChild(subImage);

					image.scaleX = image.scaleY = 0.4;
					image.x = image.y = 5;
					break;
				case LEAGUE:
					var imageClass:Class = IMAGES_LEAGUES[this.value];
					image = new imageClass();
					image.scaleX = image.scaleY = 0.8;
					image.x = 20;
					image.y = 20;
					break;
				case COLLECTION:
					imageClass = CollectionsData.getIconClass(this.id);
					image = new imageClass();
					image.scaleX = image.scaleY = 0.5;
					image.x = 20 - int(image.width * 0.5);
					image.y = 20 - int(image.height * 0.5);
					break;
				case AWARD:
					image = new Sprite();
					var icon:DisplayObject = Award.getImage(this.id);
					icon.width = icon.height = 30;
					icon.filters = this.value == 100 ? [] : FiltersUtil.GREY_FILTER;
					icon.x = icon.y = 5;
					(image as Sprite).addChild(icon);
					if (this.value != 100)
					{
						var bar:Sprite = new Sprite();
						bar.x = 5;
						bar.y = 32;
						bar.graphics.beginFill(0x777777, 1);
						bar.graphics.drawRect(0, 0, 30, 3);
						bar.graphics.beginFill(0x00FF00, 1);
						bar.graphics.drawRect(0, 0, 15, 3);
						(image as Sprite).addChild(bar);
					}
					break;
				case HOLIDAY:
					image = new ImageIconHoliday();
					image.x = 20 - int(image.width * 0.5);
					image.y = 20 - int(image.height * 0.5);
					break;
			}
			return image;
		}

		private function getImageFromNumber(value:int):Sprite
		{
			var answer:Sprite = new Sprite();

			if (value == 0)
				answer.addChild(new ImageLevelUp0);
			else while (value > 0)
			{
				for (var i:int = 0; i < answer.numChildren; i++)
					answer.getChildAt(i).x += 35;
				answer.addChildAt(new numberImages[value % 10], 0).x = 15;
				value = int(value / 10);
			}
			answer.scaleX = answer.scaleY = NUMBER_SCALING[answer.numChildren - 1];
			return answer;
		}
	}
}