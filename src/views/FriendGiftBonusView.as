package views
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import footers.FooterGame;
	import game.gameData.PowerManager;
	import game.mainGame.entity.simple.Balk;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.Box;
	import game.mainGame.entity.simple.Trampoline;

	import com.greensock.TweenMax;

	import protocol.Connection;
	import protocol.packages.server.PacketBalance;
	import protocol.packages.server.PacketEnergy;
	import protocol.packages.server.PacketMana;

	public class FriendGiftBonusView extends Sprite
	{
		static private const SPEED:int = 400;

		static private const ENERGY:int = 0;
		static private const MANA:int = 1;
		static private const BOX:int = 2;
		static private const BALK:int = 3;
		static private const BALLOON:int = 4;
		static private const TRAMPOLINE:int = 5;
		static private const COINS:int = 6;
		static public const MAX_TYPE:int = 7;

		static private var gifts:Object = {};

		static public var coins:int = 0;
		static public var mana:int = 0;
		static public var energy:int = 0;

		private var type:int = -1;
		private var id:int = 0;

		private var tween:TweenMax = null;

		static private function getGift(type:int):Object
		{
			switch (type)
			{
				case ENERGY:
					return {'class': ImageIconEnergy, 'count': 5, 'scale': 1};
				case MANA:
					return {'class': ImageIconMana, 'count': 10, 'scale': 1};
				case BOX:
					return {'class': Box1, 'count': 1, 'scale': 0.5};
				case BALK:
					return {'class': Balk1, 'count': 1, 'scale': 0.4, 'rotate': 45, 'offsetY': -8};
				case BALLOON:
					return {'class': BalloonIcon, 'count': 1, 'scale': 0.5};
				case TRAMPOLINE:
					return {'class': TrampolineView, 'count': 1, 'scale': 0.5, 'offsetY': 10};
				case COINS:
					return {'class': ImageIconCoins, 'count': 1, 'scale': 1};
			}
			return null;
		}

		static public function hide():void
		{
			for each (var gift:FriendGiftBonusView in gifts)
			{
				if (gift == null)
					continue;
				gift.takeGift();
			}
		}

		public function FriendGiftBonusView(type:int, pos:Point):void
		{
			this.type = type;

			this.x = pos.x;
			this.y = pos.y;

			init();
		}

		public function show():void
		{
			for (;; this.id++)
			{
				if (this.id in gifts && gifts[this.id] != null)
					continue;
				break;
			}

			gifts[this.id] = this;

			var posX:int = int(Config.GAME_WIDTH * 0.5) + 70 * int((this.id + 1) / 2) * (this.id % 2 == 0 ? 1 : -1);
			var posY:int = 560;

			var posX0:int = int(this.x + posX) * 0.5;
			var posY0:int = this.y - 200;

			var time:Number = Math.sqrt(Math.pow(this.x - posX, 2) + Math.pow(this.y - posY, 2)) / SPEED;

			this.scaleX = this.scaleY = 0.7;

			TweenMax.to(this, time, {'bezier': [{'x': posX0, 'y': posY0}, {'x': posX, 'y': posY}], 'scaleX': 1, 'scaleY': 1, 'onComplete': function():void
			{
				addEventListener(MouseEvent.MOUSE_OVER, takeGift);
			}});
		}

		private function init():void
		{
			var data:Object = getGift(this.type);

			var imageClass:Class = data['class'];
			var image:DisplayObject = new imageClass();
			if (image is MovieClip)
				(image as MovieClip).gotoAndStop(0);
			image.scaleX = image.scaleY = data['scale'] * 2;
			if ('rotate' in data)
				image.rotation = data['rotate'];
			if ('offsetY' in data)
				image.y = data['offsetY'] * 2;
			addChild(image);

			Game.gameSprite.addChild(this);

			glow();
		}

		private function glow():void
		{
			var target:Object = this;
			this.tween = TweenMax.to(target, 0.2, {'glowFilter': {'color':0xFFFFCC, 'alpha': 1, 'blurX':0, 'blurY':0, 'strength':1}, 'onComplete': function():void
			{
				tween = TweenMax.to(target, 0.5, {'glowFilter': {'color':0xFFFFCC, 'alpha': 1, 'blurX':10, 'blurY':10, 'strength':1}, 'onComplete': function():void
				{
					tween = TweenMax.to(target, 0.5, {'glowFilter': {'color':0xFFFFCC, 'alpha': 1, 'blurX':30, 'blurY':30, 'strength':4}, 'onComplete': function():void
					{
						tween = TweenMax.to(target, 1.0, {'glowFilter': {'color':0xFFFFCC, 'alpha': 1, 'blurX':10, 'blurY':10, 'strength':1}, 'onComplete': glow});
					}});
				}});
			}});
		}

		private function takeGift(e:MouseEvent = null):void
		{
			removeEventListener(MouseEvent.MOUSE_OVER, takeGift);
			gifts[this.id] = null;

			Game.gameSprite.removeChild(this);
			if (this.tween)
				this.tween.kill();

			var data:Object = getGift(this.type);

			var imageClass:Class = data['class'];
			var image:DisplayObject = new imageClass();
			if (image is MovieClip)
				(image as MovieClip).gotoAndStop(0);
			image.scaleX = image.scaleY = data['scale'];
			if ('rotate' in data)
				image.rotation = data['rotate'];
			if (!('offsetY' in data))
				data['offsetY'] = 0;

			var valueView:GameBonusValueView = new GameBonusValueView(data['count'], x - 35, y, null, 1.5);
			Game.gameSprite.addChild(valueView);

			var imageView:GameBonusImageView = new GameBonusImageView(image, valueView.x + int(valueView.width)+ 1, valueView.y - 2 + data['offsetY'], -1, -1, 1.5);
			Game.gameSprite.addChild(imageView);

			var id:int = -1;
			switch (this.type)
			{
				case ENERGY:
					energy -= data['count'];
					Connection.receiveFake(PacketEnergy.PACKET_ID, [PowerManager.currentEnergy + energy + data['count'], 0]);
					break;
				case MANA:
					mana -= data['count'];
					Connection.receiveFake(PacketMana.PACKET_ID, [PowerManager.currentMana + mana + data['count'], 0]);
					break;
				case BOX:
					id = CastItemsData.getId(Box);
					break;
				case BALK:
					id = CastItemsData.getId(Balk);
					break;
				case BALLOON:
					id = CastItemsData.getId(BalloonBody);
					break;
				case TRAMPOLINE:
					id = CastItemsData.getId(Trampoline);
					break;
				case COINS:
					coins -= data['count'];
					Connection.receiveFake(PacketBalance.PACKET_ID, [Game.self.coins + coins + data['count'], Game.self.nuts, 0]);
					break;
			}
			if (id != -1)
			{
				Game.selfCastItems[id] += data['count'];
				//DialogShop.onCastItemAdd(id);
				FooterGame.updateCastItems([id]);
			}
		}
	}
}