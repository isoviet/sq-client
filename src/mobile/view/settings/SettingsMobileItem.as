package mobile.view.settings
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;

	import utils.flashEx.SpriteEx;

	public class SettingsMobileItem extends SpriteEx
	{
		public static const EVENT_BTN_CLICK: String = 'onBtnClick';
		public static const EVENT_UNCHECK: String = 'onUnCheck';
		public static const EVENT_CHECK: String = 'onCheck';

		private var _background: Sprite = new PlaceSettingItem();
		private var _image: DisplayObject = null;
		private var _checkOff: SimpleButton = null;
		private var _checkOn: SimpleButton = null;
		private var _btn: Sprite = null;
		private var _label: GameField = null;
		private var _eventCallback: Function = null;
		private var _eventClick: String = MouseEvent.CLICK;
		private var _tag: * = null;

		public function SettingsMobileItem(image: DisplayObject, text: String, style: SettingsMobileItemStyle,
			checked: Boolean = false, eventCallback: Function = null, tag: * = null)
		{
			super();

			_tag = tag;
			_image = image;
			_label = new GameField(gls(text), 0 ,0,
				new TextFormat(null, 12, 0x663300, false, null, null, null, null, "center")
			);

			addChild(_image);
			addChild(_background);
			addChild(_label);

			_eventCallback = eventCallback;

			if (Config.isMobile)
				_eventClick = TouchEvent.TOUCH_BEGIN;

			if (SettingsMobileItemStyle.CHECK.equals(style) == true)
			{
				_checkOff = new SettingsCheckOff();
				_checkOn = new SettingsCheckOn();

				_checkOff.addEventListener(_eventClick, onCheckUnCheck);
				_checkOn.addEventListener(_eventClick, onCheckUnCheck);
				_checkOn.visible = checked;
				_checkOff.visible = !checked;

				this.addEventListener(_eventClick, onCheckUnCheck);
				addChild(_checkOn);
				addChild(_checkOff);
			}
			else if (SettingsMobileItemStyle.BUTTON.equals(style) == true)
			{
				_btn = new ButtonBase(gls("Открыть"));
				_btn.addEventListener(_eventClick, onClickButton);
				addChild(_btn);
			}

			initPosition();
		}

		private function initPosition(): void
		{
			_background.x = 25;
			_background.y = 0;

			_image.x = -_image.width / 2;
			_image.y = _background.y + _background.height / 2 - _image.height / 2;

			_label.x = _background.x + 5;
			_label.y = _background.y + _background.height / 2 - _label.height / 2;

			if (_checkOff && _checkOn)
			{
				_checkOn.x = _checkOff.x = _background.x + _background.width - 17;
				_checkOn.y = _checkOff.y = _background.y + _background.height / 2;
			}

			if (_btn)
			{
				_btn.x = _background.x + _background.width - _btn.width - 5;
				_btn.y = _background.y + _background.height / 2 - _btn.height / 2;
			}
		}

		public function set checked(value: Boolean): void
		{
			if (!_checkOff || !_checkOn)
				return;

			_checkOff.visible = !value;
			_checkOn.visible = value;
		}

		public function get checked(): Boolean
		{
			return _checkOn.visible;
		}

		public function remove(): void
		{
			this.removeEventListener(_eventClick, onCheckUnCheck);
			if (_checkOff)
				_checkOff.removeEventListener(_eventClick, onCheckUnCheck);

			if (_checkOn)
				_checkOn.removeEventListener(_eventClick, onCheckUnCheck);

			if (_btn)
				_btn.removeEventListener(_eventClick, onClickButton);

			while(numChildren > 0)
				removeChildAt(0);

			_tag = null;
			_background = null;
			_checkOff = null;
			_checkOn = null;
			_btn = null;
			_eventCallback = null;

			this.parent ? this.parent.removeChild(this) : null;
		}

		private function onCheckUnCheck(e: Event): void
		{
			_checkOn.visible = !_checkOn.visible;
			_checkOff.visible = !_checkOff.visible;

			_eventCallback(this, _checkOn.visible ? EVENT_CHECK :  EVENT_UNCHECK, _tag);
			GameSounds.play("click");
			e.stopImmediatePropagation();
		}

		private function onClickButton(e: Event): void
		{
			_eventCallback(this, EVENT_BTN_CLICK, _tag);
		}
	}
}