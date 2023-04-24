package dialogs
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import events.GameEvent;
	import events.ScreenEvent;
	import screens.ScreenDisconnected;
	import screens.ScreenLocation;
	import screens.Screens;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import com.IShow;

	public class Dialog extends Sprite implements IShow
	{
		static public const FILTERS_CAPTION:Array = [new BevelFilter(1.0, 58, 0xFFFFFF, 1.0, 0x996600, 1.0, 2, 2),
			new GlowFilter(0x663300, 1.0, 4, 4, 8),
			new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)];

		static public const FORMAT_CAPTION_29:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 29, 0xFFCC00);
		static public const FORMAT_CAPTION_16:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFCC00);
		static public const FORMAT_CAPTION_18_CENTER:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 18, 0xFFCC00, null, null, null, null, null, "center");
		static public const FORMAT_CAPTION_21_CENTER:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 21, 0xFFCC00, null, null, null, null, null, "center");
		static public const FORMAT_CAPTION_23_CENTER:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 23, 0xFFCC00, null, null, null, null, null, "center");
		static public const FORMAT_CAPTION_29_CENTER:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 29, 0xFFCC00, null, null, null, null, null, "center");
		static public const FORMAT_MESSAGE_16_CENTER:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 16, 0x6A4729, true, null, null, null, null, "center");
		static public const FILTER_SHADOW:GlowFilter = new GlowFilter(0x000066, 1.0, 7, 7, 1);

		private var offsetX:Number;
		private var offsetY:Number;

		private var dialogWidth:Number = 0;
		private var dialogHeight:Number = 0;

		private var buttons:Array = [];
		protected var fieldCaption:GameField = null;
		protected var fieldMessage:GameField = null;

		private var _topOffset:int = 0;

		protected var buttonClose:SimpleButton = null;
		protected var backgroundClass:Class = null;

		protected var caption:String = "";
		protected var imageCaption:MovieClip = null;
		protected var canClose:Boolean;
		protected var drawBackground:Boolean;
		protected var dialogWindow:MovieClip;
		protected var dialogMessage:DialogMessage;

		protected var leftOffset:int = 0;
		protected var rightOffset:int = 0;
		protected var bottomOffset:int = 0;
		protected var useCaption: Boolean = true;
		protected var sound:String = SoundConstants.WINDOW_BIG_OPEN;

		protected var playShowDialod:Boolean = true;

		public function Dialog(captionDialog:* = null, drawBackground:Boolean = true, canClose:Boolean = true, backgroundClass:Class = null, drag:Boolean = true):void
		{
			super();
			this.visible = false;

			if (captionDialog is String)
				this.caption = captionDialog;
			else if (captionDialog is DisplayObject)
				this.imageCaption = captionDialog;

			this.canClose = canClose;
			this.drawBackground = drawBackground;
			this.backgroundClass = backgroundClass;

			if (drag)
			{
				this.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
				this.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			}

			Screens.addDialog(this);
		}

		public function hide(e:MouseEvent = null):void
		{
			Logger.add("Dialog.hide " + this);

			if (e != null && e is MouseEvent)
				GameSounds.play("exit");

			DialogManager.hide(this);

			dispatchEvent(new GameEvent(GameEvent.HIDED));
		}

		public function hideDialog():void
		{
			this.visible = false;

			stopDragging();
		}

		public function show():void
		{
			Logger.add("Dialog.show " + this);
			if (PreLoader.isShowing)
				Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenShow);
			else
				DialogManager.show(this);

			dispatchEvent(new GameEvent(GameEvent.SHOWED));
		}

		private function onScreenShow(event:ScreenEvent):void
		{
			if (!(Screens.active is ScreenLocation))
				return;

			DialogManager.show(this);
			Screens.instance.removeEventListener(ScreenEvent.SHOW, onScreenShow);
		}

		public function showDialog():void
		{
			if (Screens.active is ScreenDisconnected)
				return;
			this.visible = true;

			addToSprite();

			if (playShowDialod && this.sound != "")
				GameSounds.play(this.sound);

			placeInCenter();
			effectOpen();
		}

		public function get captured():Boolean
		{
			return false;
		}

		public function close():void
		{
			hide();

			if (!Game.gameSprite.contains(this))
				return;
			Game.gameSprite.removeChild(this);
		}

		public function placeInCenter(sceneWidth:Number = Config.GAME_WIDTH, sceneHeight:Number = Config.GAME_HEIGHT):void
		{
			if (Game.starling.stage.stageWidth != Config.GAME_WIDTH)
				sceneWidth = Game.starling.stage.stageWidth;
			if (Game.starling.stage.stageHeight != Config.GAME_HEIGHT)
				sceneHeight = Game.starling.stage.stageHeight;

			this.x = this.leftOffset + int((sceneWidth - this.width) / 2);
			this.y = this.topOffset + int((sceneHeight - this.height) / 2);
		}

		override public function get width():Number
		{
			return this.dialogWidth;
		}

		override public function get height():Number
		{
			return this.dialogHeight;
		}

		override public function set width(value:Number):void
		{
			this.dialogWidth = value;
			place();
		}

		override public function set height(value:Number):void
		{
			this.dialogHeight = value;
			place();
		}

		protected function get captionFormat():TextFormat
		{
			return FORMAT_CAPTION_18_CENTER;
		}

		protected function setDescription(value:String):void
		{
			if (this.fieldMessage)
			{
				this.fieldMessage.text = value;
				return;
			}

			this.fieldMessage = new GameField(value, 0, 0, FORMAT_MESSAGE_16_CENTER);
			this.fieldMessage.multiline = true;
			this.fieldMessage.wordWrap = true;
			addChild(this.fieldMessage);
		}

		protected function place(...rest):void
		{
			for each (var button:* in rest)
			{
				this.buttons.push(button);
				addChild(button);
			}

			clear();
			initSize();
			draw();
			initCaption();
			initClose();
			updateButtons();
			placeInCenter();
		}

		protected function addToSprite():void
		{
			Game.gameSprite.addChild(this);
		}

		protected function effectOpen():void
		{
			/*var dialogX:int = this.x;
			var dialogY:int = this.y;

			this.x += int((this.width * 0.1) / 2);
			this.y += int((this.height * 0.1) / 2);
			this.scaleX = 0.9;
			this.scaleY = 0.9;

			this.alpha = 0.5;
			TweenMax.to(this, 0.3, {'scaleX': 1, 'scaleY': 1, 'x': dialogX, 'y': dialogY, 'alpha': 1});*/
		}

		protected function initClose():void
		{
			if (!this.canClose)
				return;

			this.buttonClose = new ButtonCross();
			this.buttonClose.x = int(this.width - this.buttonClose.width / 2 - this.rightOffset - this.leftOffset);
			this.buttonClose.y = this.fieldCaption ? this.fieldCaption.y - 5 : 0;
			this.buttonClose.addEventListener(MouseEvent.CLICK, hide);
			addChild(this.buttonClose);
		}

		protected function setDefaultSize():void
		{
			this.leftOffset = 15;
			this.rightOffset = 20;
			this.topOffset = 10;
			this.bottomOffset = 0;
		}

		protected function get topOffset():int
		{
			return (this._topOffset + (this.fieldCaption ? this.fieldCaption.height + 5 : 0) + (this.imageCaption ? this.imageCaption.height + 5 : 0));
		}

		protected function set topOffset(value:int):void
		{
			this._topOffset = value;
		}

		protected function initCaption():void
		{
			if (this.caption != "")
			{
				this.fieldCaption = new GameField(this.caption, 0, 0, this.captionFormat);
				this.fieldCaption.filters = FILTERS_CAPTION;
				this.fieldCaption.width = this.width - this.leftOffset - this.rightOffset;
				this.fieldCaption.multiline = true;
				this.fieldCaption.wordWrap = true;
				addChild(this.fieldCaption);

				if (this.dialogWindow && useCaption) //TODO веселый говнокод.
					this.dialogWindow.y -= this.fieldCaption.height + 5;
				this.fieldCaption.y = -this.fieldCaption.height;
			}
			else if (this.imageCaption != null)
			{
				this.imageCaption.x = int((this.width - this.imageCaption.width - this.leftOffset - this.rightOffset) / 2);
				this.imageCaption.mouseEnabled = false;
				this.imageCaption.mouseChildren = false;
				addChild(this.imageCaption);
				this.dialogWindow.y -= this.imageCaption.height + 5;
				this.imageCaption.y = -this.imageCaption.height;
			}

			if (this.fieldCaption && this.fieldMessage)
			{
				this.fieldCaption.y = 10;
				this.fieldMessage.width = this.width - this.leftOffset - this.rightOffset;
				this.fieldMessage.y = this.fieldCaption.y + this.fieldCaption.height + 10;
			}
		}

		private function initSize():void
		{
			if (this.backgroundClass == null && this.drawBackground)
				setDefaultSize();

			if (this.dialogWidth != 0 && this.dialogHeight != 0)
				return;

			this.dialogWidth = Math.floor(super.width) + this.leftOffset + this.rightOffset;
			this.dialogHeight = Math.floor(super.height) + this.topOffset + this.bottomOffset;
		}

		public function clear():void
		{
			if (this.fieldCaption != null)
			{
				removeChild(this.fieldCaption);
				this.fieldCaption = null;
			}
			if (this.buttonClose != null)
			{
				removeChild(this.buttonClose);
				this.buttonClose = null;
			}
			if (this.dialogWindow != null)
			{
				removeChild(this.dialogWindow);
				this.dialogWindow = null;
			}
		}

		protected function draw():void
		{
			if (!this.drawBackground)
				return;

			var origWidth:int = this.dialogWidth;
			var origHeight:int = this.dialogHeight;

			if (this.backgroundClass == null)
			{
				this.dialogWindow = new DialogBaseBackground();
				this.dialogWindow.filters = [FILTER_SHADOW];
			}
			else
				this.dialogWindow = new this.backgroundClass();

			this.dialogWindow.x -= this.leftOffset;
			this.dialogWindow.y -= this._topOffset;

			this.dialogWindow.height = origHeight;
			this.dialogWindow.width = origWidth;
			addChildAt(this.dialogWindow, 0);
		}

		private function updateButtons():void
		{
			if (this.buttons.length == 0)
				return;

			var totalWidth:int = (this.buttons.length - 1) * 20;
			var maxHeight:int = 0;

			for each (var button:* in this.buttons)
			{
				maxHeight = Math.max(maxHeight, button.height);
				totalWidth += button.width;
			}

			var left:int = int((this.width - totalWidth - this.leftOffset - this.rightOffset) / 2) + 3;

			var top:int = this.dialogWindow.y + this.dialogWindow.height - maxHeight - this.bottomOffset - 10;

			for each (button in this.buttons)
			{
				button.x = left;
				button.y = top;

				left += button.width + 20;
			}
		}

		private function startDragging(e:MouseEvent):void
		{
			addToSprite();

			if (e.target != this && !(e.target is GameField) && !(e.target is Bitmap) && !(e.target is Graphics) && !(e.target is MovieClip))
				return;

			this.offsetX = e.stageX - this.x;
			this.offsetY = e.stageY - this.y;

			Game.stage.addEventListener(MouseEvent.MOUSE_MOVE, dragObject);
		}

		private function stopDragging(event:MouseEvent = null):void
		{
			Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragObject);
		}

		private function dragObject(event:MouseEvent):void
		{
			this.x = int(event.stageX - this.offsetX);
			this.y = int(event.stageY - this.offsetY);

			event.updateAfterEvent();
		}
	}
}