package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import events.GameEvent;
	import game.gameData.CollectionsData;
	import game.gameData.DeferredBonusManager;
	import sounds.GameSounds;
	import views.issuance.IssuanceBonusView;

	import com.greensock.TweenMax;
	import com.greensock.TweenNano;
	import com.greensock.easing.Sine;

	public class HolidayBonusView extends IssuanceBonusView
	{
		private var defferedBonusId:int = 0;

		private var sended:Boolean = false;

		static private const START_POSITION:Point = new Point(327, 417);
		static private const TOP:Number = 100;
		static private const AREA:Number = 100;
		static private const OFFSET:Number = 70;

		static private function convertType(type:int):int
		{
			switch (type)
			{
				case DeferredBonusManager.EXPERIENCE:
					return EXP;
				case DeferredBonusManager.EMPTY:
					return NUTS;
				case DeferredBonusManager.ENERGY:
					return ENERGY;
				case DeferredBonusManager.MANA:
					return MANA;
				case DeferredBonusManager.MIGTHY_POTION:
					return MANAREGEN;
				case DeferredBonusManager.VIP:
					return VIP;
				case DeferredBonusManager.COLLECTIONS:
					return COLLECTIONS;
				case DeferredBonusManager.HOLIDAY_RATING:
					return HOLIDAY_RATING;
				case DeferredBonusManager.TEMPORARY_PACKAGES:
					return PACKAGES;
				case DeferredBonusManager.HOLIDAY_TICKET:
					return HOLIDAY_TICKET;
				case DeferredBonusManager.COINS:
					return GOLD;
			}
			return -1;
		}

		public function HolidayBonusView(id:int, type:int, value:int):void
		{
			this.defferedBonusId = id;

			super(convertType(type), 0, value, 1);

			this.y = START_POSITION.y;
			this.x = START_POSITION.x;

			DeferredBonusManager.addEventListener(GameEvent.DEFERRED_BONUS_ACCEPT, onAccept);
			DeferredBonusManager.addEventListener(GameEvent.DEFERRED_BONUS_REJECT, onReject);
		}

		override protected function addImage():void
		{
			var container:DisplayObject = image;
			container.x = - container.width/2;
			container.y = - container.height/2;
			this.addChild(container);
		}

		private function onReady():void
		{
			addEventListener(MouseEvent.MOUSE_OVER, sendPacket);
		}

		private function onAccept(e:GameEvent):void
		{
			if (this.defferedBonusId != e.data['id'])
				return;
			takeBonus();

			destroy();
		}

		private function onReject(e:GameEvent):void
		{
			if(!e || !e.data || !this || !this.parentIssuance)
				return;

			if (this.defferedBonusId != e.data['id'])
				return;
			if (!this.parentIssuance.contains(this))
				return;

			this.parentIssuance.removeChild(this);

			destroy();
		}

		override public function show(parentView:Sprite):void
		{
			this.parentIssuance = parentView;
			this.parentIssuance.addChild(this);

			var area:int = int(Math.random() * AREA);
			var dx:Number = Math.random() < 0.5 ? (OFFSET+area) : -(OFFSET+area);

			var timeTop:Number = 20/Game.stage.frameRate;
			var timeFall:Number = 10/Game.stage.frameRate;
			var down:Number = (Math.random()-0.5) * 20 + START_POSITION.y + 70;

			TweenNano.to(this, timeTop, {rotation: dx < 0 ? 1 : -1, y:START_POSITION.y-TOP,
				ease:Sine.easeOut, overwrite:false});
			TweenNano.to(this, timeTop, {x:dx/2 + START_POSITION.x,
				ease:Sine.easeIn, overwrite:false});
			TweenNano.to(this, timeFall, {rotation:0, delay: timeTop, y:down,
				ease:Sine.easeIn, overwrite:false});
			TweenNano.to(this, timeFall, {delay: timeTop, x:dx + START_POSITION.x, onComplete: onDrop,
				ease:Sine.easeOut, overwrite:false});

		}

		private function onDrop():void
		{
			if(this != null)
				TweenNano.killTweensOf(this);

			if (this.type == NUTS)
			{
				sendPacket(null);
				return;
			}

			var offsetY:Number = this.y + 3;
			TweenMax.to(this, 0.2, {scaleX:1.1, scaleY:0.9, y:offsetY,
				ease:Sine.easeOut, overwrite:false, repeat:1, yoyo:true});

			onReady();
		}

		public function takeForce():void
		{
			takeBonus();
			destroy();
		}

		override protected function takeBonus(e:MouseEvent = null):void
		{
			if(!this)
				return;

			TweenNano.killTweensOf(this);

			if (!this.parentIssuance || !this.parentIssuance.contains(this))
				return;

			this.parentIssuance.removeChild(this);

			if(!Game.gameSprite)
				return;

			var text:String = "";
			switch (this.type)
			{
				case MANA:
					text = "50";
					break;
				case EXP:
					text = "50";
					break;
				case ENERGY:
					text = "30";
					break;
				case VIP:
					text = "30" + " " + gls("мин.");
					break;
				case MANAREGEN:
					text = "30" + " " + gls("мин.");
					break;
				case PACKAGES:
					text = "60" + " " + gls("мин.");
					break;
				case HOLIDAY_RATING:
					text = "10";
					break;
				case COLLECTIONS:
				case HOLIDAY_TICKET:
					text = "1";
					break;
				case GOLD:
					text = "5";
					break;
			}

			var valueView:GameBonusValueView = new GameBonusValueView(text, x - 35, y, null, 1.5);
			if(valueView)
				Game.gameSprite.addChild(valueView);

			var imageView:GameBonusImageView = new GameBonusImageView(this.iconView, valueView.x + int(valueView.width)+ 1, valueView.y - 2, -1, -1, 1.5);
			if(imageView)
				Game.gameSprite.addChild(imageView);

			GameSounds.play("bundle_item_take");

			destroy();
		}

		override protected function get image():DisplayObject
		{
			var answer:Sprite = new Sprite();
			switch (this.type)
			{
				case EXP:
					var icon:DisplayObject = new ImageIconExp();
					icon.scaleX = icon.scaleY = 2.0;
					answer.addChild(icon);
					break;
				case ENERGY:
					icon = new ImageIconEnergy();
					icon.scaleX = icon.scaleY = 2.0;
					answer.addChild(icon);
					break;
				case MANA:
					icon = new ImageIconMana();
					icon.scaleX = icon.scaleY = 2.0;
					answer.addChild(icon);
					break;
				case MANAREGEN:
					icon = new ManaRegenerationImage();
					icon.scaleX = icon.scaleY = 0.3;
					icon.y -= 6;
					answer.addChild(icon);
					break;
				case VIP:
					icon = new VIPShopSmallImage();
					icon.scaleX = icon.scaleY = 0.5;
					answer.addChild(icon);
					break;
				case COLLECTIONS:
					var imageClass:Class = CollectionsData.getIconClass(this.value);
					icon = new imageClass();
					icon.scaleX = icon.scaleY = 0.75;
					answer.addChild(icon);
					break;
				case PACKAGES:
					icon = new PackageImageLoader(this.value);
					icon.scaleX = icon.scaleY = 0.5;
					answer.addChild(icon);
					break;
				case NUTS:
					break;
				case HOLIDAY_RATING:
					icon = new ImageIconHolidayRating();
					icon.scaleX = icon.scaleY = 2.0;
					answer.addChild(icon);
					break;
				case HOLIDAY_TICKET:
					icon = new ImageIconHolidayTicket();
					icon.scaleX = icon.scaleY = 2.0;
					answer.addChild(icon);
					break;
				case GOLD:
					icon = new ImageIconCoins();
					icon.scaleX = icon.scaleY = 2.0;
					answer.addChild(icon);
					break;

				default:
					return super.image;
			}
			return answer;
		}

		protected function destroy():void
		{
			TweenNano.killTweensOf(this);

			removeEventListener(MouseEvent.MOUSE_OVER, takeBonus);
			removeEventListener(MouseEvent.MOUSE_OVER, sendPacket);

			DeferredBonusManager.removeEventListener(GameEvent.DEFERRED_BONUS_ACCEPT, onAccept);
			DeferredBonusManager.removeEventListener(GameEvent.DEFERRED_BONUS_REJECT, onReject);
		}

		protected function sendPacket(e:MouseEvent):void
		{
			if (this.sended)
				return;
			this.sended = true;
			DeferredBonusManager.receiveBonus(this.defferedBonusId);
		}
	}
}