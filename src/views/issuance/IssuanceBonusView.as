package views.issuance
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import game.gameData.CollectionsData;
	import game.gameData.HolidayManager;
	import sounds.GameSounds;
	import views.GameBonusImageView;
	import views.GameBonusValueView;
	import views.PackageImageLoader;

	import com.greensock.TweenMax;

	import utils.StringUtil;

	public class IssuanceBonusView extends Sprite
	{
		static protected const FORMAT_TEXT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFFFFF);
		static protected const FORMAT_TEXT_ICON:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 10, 0xFF0000);

		static public const PACKAGES:int = 0;
		static public const BALLOON:int = 1;
		static public const EXP:int = 2;
		static public const ITEMS:int = 3;
		static public const MANAREGEN:int = 4;
		static public const VIP:int = 5;
		static public const MANA:int = 6;
		static public const ENERGY:int = 7;
		static public const GOLD:int = 8;
		static public const COLLECTIONS:int = 9;

		static public const NUTS:int = 10;
		static public const HOLIDAY_RATING:int = 11;
		static public const HOLIDAY_TICKET:int = 12;

		static public const HOLIDAY_ELEMENTS:int = 13;
		static public const HOLIDAY_DOUBLE:int = 14;

		static protected var totalCount:int = 0;
		static protected var listeners:Array = [];
		static protected var elements:Vector.<IssuanceBonusView> = new <IssuanceBonusView>[];

		protected var parentIssuance:Sprite = null;

		protected var type:int = 0;
		protected var index:int = 0;
		protected var value:int = 0;
		protected var count:int = 0;

		protected var offsetX:int = 0;
		protected var offsetY:int = 0;

		private  var icon:DisplayObject;

		protected var tween:TweenMax = null;

		static public function onFinish(handler:Function):void
		{
			listeners.push(handler);
		}

		static public function hide():void
		{
			while (elements.length > 0)
				elements.shift().takeBonus();
		}

		public function IssuanceBonusView(type:int, index:int, value:int, count:int = 1, offsetX:int = 0, offsetY:int = 0):void
		{
			this.type = type;
			this.index = index;
			this.value = value;
			this.count = count;

			this.offsetX = offsetX;
			this.offsetY = offsetY;

			this.x = int(Config.GAME_WIDTH * 0.5);
			this.y = int(Config.GAME_HEIGHT * 0.5);

			addImage();
		}

		public function show(parentIssuance:Sprite):void
		{
			this.parentIssuance = parentIssuance;
			this.parentIssuance.addChildAt(this, 0);

			totalCount++;
			elements.push(this);

			if (this.type == COLLECTIONS)
			{
				this.offsetX += (50 - Math.random() * 100);
				this.offsetY += (50 - Math.random() * 100);
			}

			TweenMax.to(this, 0.2, {'x': this.posX + this.offsetX, 'y': this.posY + this.offsetY, 'delay': this.index * 0.1, 'onComplete': function():void
			{
				addEventListener(MouseEvent.MOUSE_OVER, takeBonus);
				glow();
			}});
		}

		protected function addImage():void
		{
			var currentImage:DisplayObject = image;
			currentImage.x = this.type == PACKAGES ? -104 : -(currentImage.width * 0.5);
			currentImage.y = this.type == PACKAGES ? -74 : -(currentImage.height * 0.5);
			currentImage.name = "image";
			addChild(currentImage);
		}

		/*private function  get bgImage():DisplayObject
		{
			var im:DisplayObjectContainer = this.getChildByName("image") as DisplayObjectContainer;
			if(im.getChildAt(1) is GameField) return im.getChildAt(0) as DisplayObject;
			return im.getChildAt(1) as DisplayObject;
		}*/

		protected function takeBonus(e:MouseEvent = null):void
		{
			if (!this.parentIssuance.contains(this))
				return;
			totalCount--;
			if (totalCount == 0)
			{
				var array:Array = listeners.slice();
				listeners = [];
				while(array.length > 0)
				{
					var listener:Function = array.shift();
					listener.apply();
				}
				elements = new <IssuanceBonusView>[];
			}

			removeEventListener(MouseEvent.MOUSE_OVER, takeBonus);
			this.parentIssuance.removeChild(this);

			var text:String = this.type == PACKAGES ? this.count + " " + gls("д.") : this.count.toString();
			var valueView:GameBonusValueView = new GameBonusValueView(text, x - 35, y, null, 1.5);
			Game.gameSprite.addChild(valueView);

			var imageView:GameBonusImageView = new GameBonusImageView(this.iconView, valueView.x + int(valueView.width)+ 1, valueView.y - 2, -1, -1, 1.5);
			Game.gameSprite.addChild(imageView);

			GameSounds.play("bundle_item_take");
		}

		protected function get image():DisplayObject
		{
			var answer:Sprite = new Sprite();
			switch (this.type)
			{
				case PACKAGES:
					icon = new PackageImageLoader(this.value);
					icon.scaleX = 0.6;
					icon.scaleY = 0.6;
					answer.addChild(icon);
					if (this.count > 0)
					{
						var field:GameField = new GameField(this.count + " " + StringUtil.word("день", this.count), 0, 0, FORMAT_TEXT);
						field.x = int((icon.width - field.textWidth) * 0.5);
						field.y = icon.height + 10;
						answer.addChild(field);
					}
					break;
				case BALLOON:
					icon = new ImageBundleBalloons();
					answer.addChild(icon);
					field = new GameField(this.count + " " + StringUtil.word("штука", this.count), 0, 0, FORMAT_TEXT);
					field.x = int((answer.width - field.textWidth) * 0.5);
					field.y = answer.height + 10;
					answer.addChild(field);
					break;
				case EXP:
					answer.addChild(icon = new ImageBundleExp);
					break;
				case ITEMS:
					answer.addChild(icon = new ImageBundleItems);

					field = new GameField(this.count + " " + StringUtil.word("штука", this.count), 0, 0, FORMAT_TEXT);
					field.x = int((answer.width - field.textWidth) * 0.5);
					field.y = answer.height + 10;
					answer.addChild(field);
					break;
				case MANAREGEN:
					answer.addChild(icon = new ManaRegenerationImage());

					field = new GameField(this.count + " " + StringUtil.word("день", this.count), 0, 0, FORMAT_TEXT);
					field.x = int((answer.width - field.textWidth) * 0.5);
					field.y = answer.height + 10;
					answer.addChild(field);
					break;
				case VIP:
					icon = new VIPShopSmallImage();
					icon.scaleX = icon.scaleY = 1.5;
					answer.addChild(icon);

					field = new GameField(this.count + " " + StringUtil.word("день", this.count), 0, 0, FORMAT_TEXT);
					field.x = int((answer.width - field.textWidth) * 0.5);
					field.y = icon.height + 10;
					answer.addChild(field);
					break;
				case MANA:
					icon = new ManaGlassBigImage();
					answer.addChild(icon);

					field = new GameField(this.count.toString(), 0, 0, FORMAT_TEXT);
					field.x = int((answer.width - field.textWidth) * 0.5) - 6;
					field.y = icon.height + 10;
					answer.addChild(field);

					var _icon:DisplayObject = new ImageIconMana();
					_icon.x = field.x + field.textWidth + 4;
					_icon.y = field.y;
					answer.addChild(_icon);
					break;
				case ENERGY:
					icon = new EnergyGlassBigImage();
					answer.addChild(icon);

					field = new GameField(this.count.toString(), 0, 0, FORMAT_TEXT);
					field.x = int((answer.width - field.textWidth) * 0.5) - 6;
					field.y = icon.height + 10;
					answer.addChild(field);

					_icon = new ImageIconEnergy();
					_icon.x = field.x + field.textWidth + 4;
					_icon.y = field.y;
					answer.addChild(_icon);
					break;
				case GOLD:
					icon = new PaymentResultImage();
					answer.addChild(icon);

					field = new GameField(this.count + " " + StringUtil.word("монет", this.count), 0, 0, FORMAT_TEXT);
					field.x = int((answer.width - field.textWidth) * 0.5);
					field.y = icon.height + 10;
					answer.addChild(field);
					break;
				case COLLECTIONS:
					var imageClass:Class = CollectionsData.getIconClass(this.value);
					answer.addChild(icon = new imageClass());
					break;
				case HOLIDAY_ELEMENTS:
					imageClass = HolidayManager.images[this.value];
					answer.addChild(icon = new imageClass());

					field = new GameField(this.count + " " + StringUtil.word("штука", this.count), 0, 0, FORMAT_TEXT);
					field.x = int((answer.width - field.textWidth) * 0.5);
					field.y = answer.height + 10;
					answer.addChild(field);
					break;
				case HOLIDAY_DOUBLE:
					answer.addChild(icon = new ImageIconHoliday());

					field = new GameField(this.count + " " + StringUtil.word("минута", this.count), 0, 0, FORMAT_TEXT);
					field.x = int((answer.width - field.textWidth) * 0.5);
					field.y = answer.height + 10;
					answer.addChild(field);
					break;
			}
			return answer;
		}

		protected function get iconView():DisplayObject
		{
			var answer:Sprite = new Sprite();
			switch (this.type)
			{
				case PACKAGES:
					var _icon:DisplayObject = new DailyBonusImagePackage();
					_icon.scaleX = _icon.scaleY = 0.35;
					_icon.filters = [new GlowFilter(0xFFFFFF, 1, 2, 2, 8)];
					answer.addChild(_icon);
					break;
				case BALLOON:
					_icon = new BalloonIcon();
					_icon.scaleX = _icon.scaleY = 0.5;
					answer.addChild(_icon);
					break;
				case EXP:
					answer.addChild(new ImageIconExp);
					break;
				case ITEMS:
					_icon = new ImageBundleItems();
					_icon.scaleX = _icon.scaleY = 0.2;
					_icon.filters = [new GlowFilter(0xFFFFFF, 1, 2, 2, 8)];
					answer.addChild(_icon);
					break;
				case MANAREGEN:
					_icon = new ManaRegenerationImage();
					_icon.scaleX = _icon.scaleY = 0.2;
					answer.addChild(_icon);
					break;
				case VIP:
					_icon = new ImageIconVIP();
					_icon.y = 5;
					answer.addChild(_icon);
					break;
				case MANA:
					answer.addChild(new ImageIconMana());
					break;
				case ENERGY:
					answer.addChild(new ImageIconEnergy());
					break;
				case GOLD:
					answer.addChild(new ImageIconCoins());
					break;
				case COLLECTIONS:
					var imageClass:Class = CollectionsData.getIconClass(this.value);
					_icon = new imageClass();
					_icon.scaleX = _icon.scaleY = 0.4;
					answer.addChild(_icon);
					break;
				case NUTS:
					answer.addChild(new ImageIconNut());
					break;
				case HOLIDAY_RATING:
					answer.addChild(new ImageIconHolidayRating());
					break;
				case HOLIDAY_TICKET:
					answer.addChild(new ImageIconHolidayTicket());
					break;
				case HOLIDAY_ELEMENTS:
					answer.addChild(new ImageIconHoliday());
					break;
				case HOLIDAY_DOUBLE:
					answer.addChild(new ImageIconHoliday());
					answer.addChild(new GameField("х2", 0, 0, FORMAT_TEXT_ICON));
					break;
			}
			return answer;
		}

		protected function glow():void
		{

			var target:Object = icon == null ? this : icon;
			var color:uint = this.colorGlow;
			this.tween = TweenMax.to(target, 0.2, {'glowFilter': {'color': color, 'alpha': 1, 'blurX': 0, 'blurY': 0, 'strength': 1}, 'onComplete': function():void
			{
				tween = TweenMax.to(target, 0.5, {'glowFilter': {'color': color, 'alpha': 1, 'blurX': 5, 'blurY': 5, 'strength': 1}, 'onComplete': function():void
				{
					tween = TweenMax.to(target, 0.5, {'glowFilter': {'color': color, 'alpha': 1, 'blurX': 15, 'blurY': 15, 'strength': 4}, 'onComplete': function():void
					{
						tween = TweenMax.to(target, 1.0, {'glowFilter': {'color':color, 'alpha': 1, 'blurX': 5, 'blurY': 5, 'strength': 1}, 'onComplete': glow});
					}});
				}});
			}});
		}

		protected function get colorGlow():uint
		{
			return 0xFFFFCC;
		}

		protected function get posX():int
		{
			return int(Config.GAME_WIDTH * 0.5) - 300 * ((this.index + 1) % 3 - 1);
		}

		protected function get posY():int
		{
			var offset:int = this.index % 3 == 0 ? 150 : 200;
			return this.index < 3 ? (Config.GAME_HEIGHT - offset) : offset;
		}
	}
}