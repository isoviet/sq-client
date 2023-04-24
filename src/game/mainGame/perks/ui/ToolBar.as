package game.mainGame.perks.ui
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import footers.FooterGame;
	import screens.ScreenEdit;
	import screens.Screens;

	import protocol.PacketServer;

	public class ToolBar extends Sprite
	{
		protected var buttonSprite:Sprite = new Sprite();
		protected var buttons:Vector.<ToolButton> = new Vector.<ToolButton>();

		public function ToolBar():void
		{
			addChild(this.buttonSprite);

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}

		override public function set visible(value:Boolean):void
		{
			if (super.visible == value)
				return;

			super.visible = value;
			updateHotKeysStatuses();
		}

		public function addButton(button:ToolButton):void
		{
			this.buttons.push(button);
			this.buttonSprite.addChild(button);
		}

		public function get notEmpty():Boolean
		{
			return this.buttons.length > 0;
		}

		public function get perksAvailable():Boolean
		{
			return !Locations.currentLocation.nonPerk && (FooterGame.gameState == PacketServer.ROUND_START) && !(FooterGame.hero && FooterGame.hero.isHare);
		}

		public function get perksVisible():Boolean
		{
			return this.notEmpty;
		}

		public function updateButtons():void
		{
			for each (var button:ToolButton in this.buttons)
				button.updateState();
		}

		protected function get hotKeys():Array
		{
			return [Keyboard.NUMBER_1, Keyboard.NUMBER_2, Keyboard.NUMBER_3, Keyboard.NUMBER_4, Keyboard.NUMBER_5, Keyboard.NUMBER_6, Keyboard.NUMBER_7, Keyboard.NUMBER_8, Keyboard.NUMBER_9, Keyboard.NUMBER_0];
		}

		protected function get needVisible():Boolean
		{
			return true;
		}

		protected function updateHotKeysStatuses():void
		{
			var length:int = Math.min(this.buttons.length, this.hotKeys.length);
			for (var i:int = 0; i < length; i++)
				this.visible ? this.buttons[i].addHotKeyStatus(String.fromCharCode(this.hotKeys[i])) : this.buttons[i].removeHotKeyStatus();
		}

		protected function get keyCode():uint
		{
			return 0;
		}

		protected function onKey(e:KeyboardEvent):void
		{
			if (e.shiftKey || e.ctrlKey)
				return;

			if (!this.perksAvailable || !this.perksVisible)
				return;

			if (Game.chat && Game.chat.visible ||(Screens.active is ScreenEdit))
				return;

			if (e.keyCode == this.keyCode)
			{
				this.visible = !this.visible;
				return;
			}

			if (this.needVisible && !this.visible)
				return;

			var length:int = Math.min(this.buttons.length, this.hotKeys.length);
			for (var i:int = 0; i < length; i++)
			{
				if (e.keyCode != this.hotKeys[i])
					continue;
				this.buttons[i].onClick();
			}
		}
	}
}