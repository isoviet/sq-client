package mobile.view.locations
{
	import flash.filters.GlowFilter;

	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ColorMatrixFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.utils.StarlingConverter;

	public class LocationItem extends Sprite
	{
		public static const SCALE_ACTIVE_ITEM: Number = 1.2;

		private static const COLOR_HEAD_INFO: uint = 0x857653;
		private static const DEF_TEXT_COLOR: uint = 0x433527;

		private static const SPEED_ANIMATION: Number = 0.2;

		private var _id: int = -1;
		private var _view: StarlingAdapterMovie = null;

		private var btnPlayLocation: Button = null;
		private var textureBtnOver: Texture = null;
		private var textureBtnUp: Texture = null;

		private var btnShowInfo: Button = null;
		private var btnHideInfo: Button = null;
		private var lblInfo: TextField = null;
		private var lblNameLocation: TextField = null;
		private var lblCaptionInfo: TextField = null;
		private var lblHistory: TextField = null;
		private var lblOnline: TextField = null;
		private var lblEnergy: TextField = null;
		private var imgEnergy: Image = null;
		private var imgLock: Image = null;
		private var imgPreview: Image = null;
		private var needShowInfo: Boolean = false;
		private var _locked: Boolean = false;
		private var animationShowInfo: Boolean = false;
		private var originScaleX: Number = 1;
		private var originScaleY: Number = 1;
		private var placeFaceCard: Sprite = new Sprite();
		private var placeInfoCard: Sprite = new Sprite();
		private var _callback: Function = null;
		private var needLevel: TextField = null;

		public function LocationItem(id: int, view: StarlingAdapterMovie, preview: Image, name: String, desc: String, online: int, energy: int, level: int, callback: Function = null)
		{
			_id = id;
			_view = view;
			view._maxFPS = 10;
			_callback = callback;

			this.addChild(placeFaceCard);
			this.addChild(placeInfoCard);

			placeFaceCard.visible = true;
			placeInfoCard.visible = false;
			placeFaceCard.addChild(_view.getStarlingView());

			_view.getStarlingView().addEventListener(TouchEvent.TOUCH, onTouchPlay);

			lblInfo = new TextField(this.width - 10, 130, desc, GameField.DEFAULT_FONT, 12, DEF_TEXT_COLOR);
			lblInfo.bold = false;
			lblInfo.hAlign = HAlign.LEFT;
			lblInfo.vAlign = VAlign.TOP;
			lblInfo.touchable = false;

			lblOnline = new TextField(this.width-20, 20, '', GameField.DEFAULT_FONT, 10, 0xFFFFFF);
			lblOnline.nativeFilters = [new GlowFilter(0x074B87, 1, 7, 7, 1.9, 1, false)];
			lblOnline.bold = false;
			lblOnline.hAlign = HAlign.LEFT;
			lblOnline.vAlign = VAlign.TOP;
			lblOnline.touchable = false;

			needLevel = new TextField(this.width, 25, '', GameField.DEFAULT_FONT, 11, 0xffffff);
			needLevel.bold = false;
			needLevel.hAlign = HAlign.LEFT;
			needLevel.vAlign = VAlign.TOP;
			needLevel.touchable = false;
			needLevel.nativeFilters = [new GlowFilter(0x074B87, 1, 7, 7, 1.9, 1)];

			lblEnergy = new TextField(27, 28, '', GameField.DEFAULT_FONT, 12, 0xFFFFFF);
			lblEnergy.bold = false;
			lblEnergy.hAlign = HAlign.LEFT;
			lblEnergy.vAlign = VAlign.TOP;
			lblEnergy.touchable = false;
			lblEnergy.nativeFilters = [new GlowFilter(0x074B87, 1, 7, 7, 1.9, 1)];

			imgEnergy = StarlingConverter.convertToImage(new ImageIconEnergy(), 0, 1, 1, '', false, true);
			imgEnergy.scaleX = imgEnergy.scaleY = 0.5;

			lblNameLocation = new TextField(this.width, 30, name, GameField.PLAKAT_FONT, 15, 0xFFFFFF);
			lblNameLocation.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			lblNameLocation.x  = this.width / 2 - lblNameLocation.width / 2;
			lblNameLocation.y = this.height - lblNameLocation.height - 10;
			lblNameLocation.touchable = false;

			lblCaptionInfo = new TextField(this.width, 30, name, GameField.PLAKAT_FONT, 12, COLOR_HEAD_INFO);
			lblCaptionInfo.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			lblCaptionInfo.x  = this.width / 2 - lblCaptionInfo.width / 2;
			lblCaptionInfo.y = 5;
			lblCaptionInfo.touchable = false;

			imgPreview = preview;
			imgPreview.scaleX = imgPreview.scaleY = 0.7;
			imgPreview.x = this.width / 2 - imgPreview.width / 2;
			imgPreview.y = lblCaptionInfo.y + lblCaptionInfo.height + 5;

			lblHistory = new TextField(this.width, 30, gls('Немного истории:'), GameField.DEFAULT_FONT, 12, DEF_TEXT_COLOR);
			lblHistory.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			lblHistory.bold = true;
			lblHistory.y = imgPreview.y + imgPreview.height + 5;
			lblHistory.x = 5;
			lblHistory.touchable = false;

			lblInfo.x = lblHistory.x;
			lblInfo.y = lblHistory.y + lblHistory.height;
			lblInfo.touchable = false;

			textureBtnOver = StarlingConverter.getTexture(new BtnPlayLocationOver(), 0, 1, 1, false, '', false, true);
			textureBtnUp = StarlingConverter.getTexture(new BtnPlayLocation(), 0, 1, 1, false, '', false, true);

			imgLock = StarlingConverter.convertToImage(new IconLocationDisabled(), 0, 1, 1, '', false, true);
			btnShowInfo = new Button(StarlingConverter.getTexture(new BtnShowInfoLocation(), 0, 1, 1, false, '', false, true));
			btnHideInfo = new Button(StarlingConverter.getTexture(new BtnCloseInfo(), 0, 1, 1, false, '', false, true));
			btnPlayLocation = new Button(textureBtnUp, Config.isRus ? "ИГРАТЬ" : "PLAY");
			btnPlayLocation.touchable = false;

			btnShowInfo.addEventListener(Event.TRIGGERED, onTouchShowInfo);
			btnHideInfo.addEventListener(Event.TRIGGERED, onTouchHideInfo);

			btnPlayLocation.fontColor = 0xFFFFFF;
			btnPlayLocation.fontSize = 100;
			btnPlayLocation.alpha = 0.8;
			btnPlayLocation.fontName = GameField.PLAKAT_FONT;

			btnPlayLocation.x = this.width / 2 - btnPlayLocation.width / 2;
			btnPlayLocation.y = 70;
			btnPlayLocation.visible = false;

			btnShowInfo.x = this.width - btnShowInfo.width - 5;
			btnShowInfo.y = 5;

			btnHideInfo.visible = false;
			btnHideInfo.scaleX = btnHideInfo.scaleY = 0.8;
			btnHideInfo.x = this.width - btnHideInfo.width - 5;
			btnHideInfo.y = 5;

			imgLock.visible = false;
			imgLock.x = this.width / 2 - imgLock.width / 2;
			imgLock.y = this.height / 2 - imgLock.height / 2;
			imgLock.touchable = false;

			setValueOnLine(online);
			setValueEnergy(energy);
			setValueLevel(level);

			placeInfoCard.addChild(StarlingConverter.convertToImage(new PlaceInfoLocation(), 0, 1, 1, '', false, true));
			placeInfoCard.addChild(lblInfo);
			placeInfoCard.addChild(btnHideInfo);
			placeInfoCard.addChild(lblHistory);
			placeInfoCard.addChild(lblCaptionInfo);
			placeInfoCard.addChild(imgPreview);

			placeFaceCard.addChild(needLevel);
			placeFaceCard.addChild(btnPlayLocation);
			placeFaceCard.addChild(btnShowInfo);
			placeFaceCard.addChild(imgLock);
			placeFaceCard.addChild(lblNameLocation);
			placeFaceCard.addChild(lblOnline);
			placeFaceCard.addChild(lblEnergy);
			placeFaceCard.addChild(imgEnergy);

			placeFaceCard.alignPivot();
			placeInfoCard.alignPivot();

			placeFaceCard.touchable = true;
			placeFaceCard.useHandCursor = true;

			lblOnline.visible = lblEnergy.visible = imgEnergy.visible = false;
			deactivate();
		}

		public function setValueLevel(value: int): void
		{
			needLevel.text = value == 0 ? gls("Доступно всем") : gls("С {0} уровня", value);
			needLevel.x = 5;
			needLevel.y = lblEnergy.y + lblEnergy.height - 10;
		}

		public function setValueOnLine(value: int): void
		{
			lblOnline.text = gls('Online:') + ' ' + value;
			lblOnline.x = 5;
			lblOnline.y = 0;
		}

		public function setValueEnergy(value: int): void
		{
			lblEnergy.text = value.toString();
			lblEnergy.x = 5;
			lblEnergy.y = lblOnline.y + lblOnline.height - 6;

			//TODO очень плохой способ контроля длинны текстового поля, но штатный автосайз не работает с фильтром
			imgEnergy.x = lblEnergy.x + 10 * lblEnergy.text.length + 6;// + imgEnergy.width / 2;
			imgEnergy.y = lblEnergy.y + lblEnergy.height / 2 - imgEnergy.height / 2;
		}

		public function refresh(): void
		{
			_view.reload();
			placeFaceCard.addChildAt(_view.getStarlingView(), 0);

			placeFaceCard.addChild(btnPlayLocation);
			placeFaceCard.addChild(btnShowInfo);
			placeFaceCard.addChild(imgLock);
			placeFaceCard.addChild(lblNameLocation);
			placeFaceCard.addChild(lblOnline);
			placeFaceCard.addChild(lblEnergy);
			placeFaceCard.addChild(imgEnergy);

			placeFaceCard.alignPivot();

			if (_locked)
				_view.gotoAndStop(1);
			else
				_view.gotoAndPlay(1);
		}

		public function get id(): int
		{
			return _id;
		}

		public function get locked(): Boolean
		{
			return _locked;
		}

		public function set locked(value: Boolean): void
		{
			imgLock.visible = _locked = value;

			if(value)
			{
				var filter:ColorMatrixFilter = new ColorMatrixFilter();
				filter.tint(0x0, 0.5);
				_view.getStarlingView().filter = filter;
			}
			else
			{
				if (_view.getStarlingView().filter)
				{
					_view.getStarlingView().filter.dispose();
					_view.getStarlingView().filter = null;
				}
			}
		}

		public function activate(): void
		{
			if (!_locked)
			{

				if (_view.getStarlingView().filter)
				{
					_view.getStarlingView().filter.dispose();
					_view.getStarlingView().filter = null;
				}
				_view.play();
				_view.loop = true;
				btnPlayLocation.visible = true;
				_view.getStarlingView().addEventListener(TouchEvent.TOUCH, onTouchPlay);
				btnShowInfo.visible = true;
			}
			lblOnline.visible = needLevel.visible = lblEnergy.visible = imgEnergy.visible = true;
		}

		public function deactivate(): void
		{
			_view.stop();

			btnPlayLocation.visible = false;
			_view.getStarlingView().removeEventListener(TouchEvent.TOUCH, onTouchPlay);

			btnShowInfo.visible = false;

			if (needShowInfo)
				EnterFrameManager.addListener(onShowAnimation);
			needShowInfo = false;
			lblOnline.visible = needLevel.visible = lblEnergy.visible = imgEnergy.visible = false;
		}

		override public function dispose(): void
		{
			_view.getStarlingView().removeEventListener(TouchEvent.TOUCH, onTouchPlay);
			_view = null;
			btnPlayLocation.removeEventListener(TouchEvent.TOUCH, onTouchShowInfo);
			btnHideInfo.removeEventListener(TouchEvent.TOUCH, onTouchHideInfo);

			while(numChildren > 0)
				getChildAt(0);

			this.removeFromParent();
			super.dispose();
		}

		private function onTouchPlay(e: TouchEvent): void
		{
			var touch:Touch = e.getTouch(this.placeFaceCard);

			if(touch != null)
			{
				if(touch.phase == TouchPhase.HOVER)
					btnPlayLocation.upState = textureBtnOver;

				if(touch.phase == TouchPhase.ENDED && _callback != null)
					_callback(_id);
			}
			else
				btnPlayLocation.upState = textureBtnUp;
		}

		private function onTouchShowInfo(e: Event): void
		{
			needShowInfo = true;
			EnterFrameManager.addListener(onShowAnimation);
		}

		private function onTouchHideInfo(e: Event): void
		{
			needShowInfo = false;
			EnterFrameManager.addListener(onShowAnimation);
		}

		private function onAnimationHideInfo(): void
		{
			if (!animationShowInfo)
			{
				placeInfoCard.scaleX = placeFaceCard.scaleX -= SPEED_ANIMATION;

				if (placeFaceCard.scaleX <= 0)
				{
					placeInfoCard.scaleX = placeFaceCard.scaleX = 0;
					animationShowInfo = true;
					placeFaceCard.visible = true;
					placeInfoCard.visible = false;
				}
			}

			if (animationShowInfo)
			{
				if (placeFaceCard.scaleY > 1)
					placeInfoCard.scaleY = placeFaceCard.scaleY -= SPEED_ANIMATION / 2;

				placeInfoCard.scaleX = placeFaceCard.scaleX += SPEED_ANIMATION;
				if (placeFaceCard.scaleX >= 1)
				{
					placeInfoCard.scaleX = placeFaceCard.scaleX = 1;
					placeInfoCard.scaleY = placeFaceCard.scaleY = 1;
					animationShowInfo = false;
					EnterFrameManager.removeListener(onShowAnimation);
				}
			}
		}

		private function onAnimationShowInfo(): void
		{
			if (!animationShowInfo)
			{
				if (placeFaceCard.scaleY < 1)
					placeInfoCard.scaleY = placeFaceCard.scaleY += SPEED_ANIMATION / 2;

				placeInfoCard.scaleX = placeFaceCard.scaleX -= SPEED_ANIMATION;
				if (placeFaceCard.scaleX <= 0)
				{
					placeInfoCard.scaleY = placeFaceCard.scaleY = SCALE_ACTIVE_ITEM;
					placeInfoCard.scaleX = placeFaceCard.scaleX = 0;
					animationShowInfo = true;
					placeFaceCard.visible = false;
					placeInfoCard.visible =  true;
				}
			}

			if (animationShowInfo)
			{
				placeInfoCard.scaleX = placeFaceCard.scaleX += SPEED_ANIMATION;

				if (placeFaceCard.scaleX >= SCALE_ACTIVE_ITEM)
				{
					placeInfoCard.scaleX = placeFaceCard.scaleX = SCALE_ACTIVE_ITEM;
					animationShowInfo = false;
					btnHideInfo.visible = true;
					EnterFrameManager.removeListener(onShowAnimation);
				}
			}
		}

		private function onShowAnimation(): void
		{
			if (!needShowInfo)
				onAnimationHideInfo();
			else if (needShowInfo)
				onAnimationShowInfo();
		}
	}
}