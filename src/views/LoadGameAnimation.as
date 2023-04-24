package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;

	import buttons.ButtonFooterTab;
	import loaders.ScreensLoader;
	import screens.ScreenGame;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	public class LoadGameAnimation
	{
		static private const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 18, 0xFFFFFF, null, null, null, null, null, "center");
		private var sprite:Sprite = new Sprite();

		private var tweenLogo:TweenMax = null;
		private var imageLogo:DisplayObject = null;

		private var skyAnimation:SkyAnimation;
		private var buttonCancel:ButtonFooterTab;
		private var fieldLoading:GameField;

		private var _isOpened:Boolean;

		private var scaled:Boolean = false;

		static private var _instance:LoadGameAnimation;

		static public function get instance():LoadGameAnimation
		{
			if (!_instance)
				_instance = new LoadGameAnimation();
			return _instance;
		}

		public function LoadGameAnimation():void
		{
			_instance = this;

			this.skyAnimation = new SkyAnimation();

			this.skyAnimation.cacheAsBitmap = true;
			this.skyAnimation.stop();
			this.skyAnimation.addEventListener("Closed", function(e:Event):void
			{
				_isOpened = false;
				fieldLoading.visible = true;
			});
			this.skyAnimation.addEventListener("Opened", function(e:Event):void
			{
				_isOpened = true;
				fieldLoading.visible = false;
			});

			this.imageLogo = PreLoader.getLogo();
			this.imageLogo.scaleX = this.imageLogo.scaleY = 1.2;
			this.imageLogo.x = -(this.imageLogo.width * 0.5);
			this.imageLogo.visible = false;

			this.buttonCancel = new ButtonFooterTab(gls("Отмена"), [FORMAT, FORMAT, FORMAT], ButtonSkyAnimationCancel, 10);
			this.buttonCancel.x = -70;
			this.buttonCancel.y = 230;
			this.buttonCancel.addEventListener(MouseEvent.CLICK, onCancel);

			this.fieldLoading = new GameField(gls("Загрузка..."), 0, 180, new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF));
			this.fieldLoading.x = -int(this.fieldLoading.textWidth * 0.5);
			this.fieldLoading.filters = [new DropShadowFilter(2, 45, 0x000000, 1, 4, 4)];
			this.fieldLoading.visible = false;

			this.sprite.x = int(Config.GAME_WIDTH * 0.5);
			this.sprite.y = int(Config.GAME_HEIGHT * 0.5);

			this.sprite.addChild(this.skyAnimation);
			this.sprite.addChild(this.buttonCancel);
			this.sprite.addChild(this.fieldLoading);
			this.sprite.addChild(this.imageLogo);

			this._isOpened = true;
		}

		public function set visible(value:Boolean):void
		{
			this.sprite.visible = value;
		}

		public function get isOpened():Boolean
		{
			return _isOpened;
		}

		public function close(showButton:Boolean = true, frame:int = 0):void
		{
			if ((Game.starling.stage.stageWidth == Config.GAME_WIDTH) == this.scaled)
			{
				var scale:Number = Math.max(Game.starling.stage.stageWidth / Config.GAME_WIDTH, Game.starling.stage.stageHeight / Config.GAME_HEIGHT);
				this.sprite.scaleX = this.sprite.scaleY = scale;
				this.sprite.x = int(Game.starling.stage.stageWidth * 0.5);
				this.sprite.y = int(Game.starling.stage.stageHeight * 0.5);

				this.scaled = !this.scaled;
			}

			if (this.skyAnimation.isPlaying)
			{
				setTimeout(close, 1);
				return;
			}
			if (this._isOpened)
			{
				Game.gameSprite.addChild(this.sprite);
				this.skyAnimation.gotoAndPlay(frame);
				this.buttonCancel.visible = showButton;

				this.imageLogo.visible = true;
				if (frame == 0)
				{
					if (this.tweenLogo)
						this.tweenLogo.kill();
					this.imageLogo.y = -500;
					this.tweenLogo = TweenMax.to(this.imageLogo, 0.3, {'y': -250, 'delay': 0.5, 'ease': Back.easeOut});
				}
				else
					this.imageLogo.y = -250;
			}
		}

		public function open(callback:Function = null):void
		{
			if (this.skyAnimation.isPlaying)
			{
				setTimeout(open, 1, callback);
				return;
			}

			if (callback != null)
				callback();

			if (!this._isOpened)
			{
				Game.gameSprite.addChild(this.sprite);
				this.skyAnimation.gotoAndPlay(98);
				this.buttonCancel.visible = false;

				if (this.tweenLogo)
					this.tweenLogo.kill();
				this.imageLogo.y = -250;
				this.tweenLogo = TweenMax.to(this.imageLogo, 0.3, {'y': -500, 'ease': Back.easeIn});
			}
		}

		private function onCancel(e:MouseEvent):void
		{
			open();

			ScreenGame.refuse();
			ScreensLoader.clearCallback();
		}
	}
}