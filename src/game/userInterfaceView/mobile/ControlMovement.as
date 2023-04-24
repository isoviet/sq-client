package game.userInterfaceView.mobile
{
	CONFIG::mobile
	{
		import flash.display.Screen;
	}

	import controllers.ControllerHeroLocal;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import starling.core.Starling;

	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import utils.starling.utils.StarlingConverter;

	public class ControlMovement extends Sprite
	{
		private static const UI_MARGIN: int = 10;
		private static var _enable: Boolean = true;

		private var btnMoveRight: Button = null;
		private var btnMoveLeft: Button = null;
		private var btnJumpRight: Button = null;
		private var btnJumpLeft: Button = null;
		private var heroController:ControllerHeroLocal = null;
		private  var newScale:Number = 1;


		public function ControlMovement(heroController: ControllerHeroLocal)
		{
			CONFIG::mobile
			{
				this.heroController = heroController;
				var thisScreen:Screen = Screen.mainScreen;
				var newScaleX:Number = 1.3;//thisScreen.visibleBounds.width / Config.GAME_WIDTH;
				var newScaleY:Number = 1.3;//thisScreen.visibleBounds.height / Config.GAME_HEIGHT;
				newScale = Math.min(newScaleX, newScaleY);

				var mc: MovieClip = new BtnMoveRight1();

				btnMoveRight = new Button(StarlingConverter.getTexture(mc));
				btnMoveRight.scaleX = btnMoveRight.scaleY = newScale;

				mc = new BtnMoveLeft1();

				btnMoveLeft = new Button(StarlingConverter.getTexture(mc));
				btnMoveLeft.scaleX = btnMoveLeft.scaleY = newScale;

				mc = new BtnMoveUp1();

				btnJumpRight = new Button(StarlingConverter.getTexture(mc));
				btnJumpRight.scaleX = btnJumpRight.scaleY = newScale;

				btnJumpLeft = new Button(StarlingConverter.getTexture(mc));
				btnJumpLeft.scaleX = btnJumpLeft.scaleY = newScale;

				addChild(btnMoveRight);
				addChild(btnMoveLeft);
				addChild(btnJumpRight);
				addChild(btnJumpLeft);

				btnMoveRight.addEventListener(TouchEvent.TOUCH, onTouchControl);
				btnMoveLeft.addEventListener(TouchEvent.TOUCH, onTouchControl);
				btnJumpRight.addEventListener(TouchEvent.TOUCH, onTouchControl);
				btnJumpLeft.addEventListener(TouchEvent.TOUCH, onTouchControl);

				btnJumpLeft.visible = false;
				FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
				onChangeScreenSize();
				Starling.current.stage.addChild(this);
			}
		}

		public static function enable(value: Boolean): void
		{
			_enable = value;
		}

		public function remove(): void
		{
			FullScreenManager.instance().removeEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);

			btnMoveRight.removeEventListeners(TouchEvent.TOUCH);
			btnMoveLeft.removeEventListeners(TouchEvent.TOUCH);
			btnJumpRight.removeEventListeners(TouchEvent.TOUCH);
			btnJumpLeft.removeEventListeners(TouchEvent.TOUCH);

			btnMoveRight.removeFromParent(true);
			btnMoveLeft.removeFromParent(true);
			btnJumpRight.removeFromParent(true);
			btnJumpLeft.removeFromParent(true);

			btnMoveRight = null;
			btnMoveLeft = null;
			btnJumpRight = null;
			btnJumpLeft = null;
			heroController = null;
			this.removeFromParent(true);
		}

		private function onTouchControl(e: TouchEvent): void
		{
			if (!_enable)
				return;

			var keyCode: int = 0;
			var touches: Vector.<Touch> = e.getTouches(this);

			for (var i:int = 0, len: int = touches.length; i < len; i++)
			{
				if (touches[i].target == btnMoveRight)
				{
					keyCode = Keyboard.RIGHT;
				}
				else if (touches[i].target == btnMoveLeft)
				{
					keyCode = Keyboard.LEFT;
				}
				else if (touches[i].target == btnJumpRight || touches[i].target == btnJumpLeft)
				{
					keyCode = Keyboard.UP;
				}

				if (touches[i].phase == TouchPhase.BEGAN)
				{
					this.heroController.onKey(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, keyCode));
				}
				else if (touches[i].phase == TouchPhase.ENDED)
				{
					this.heroController.onKey(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keyCode));
				}
			}
		}

		private function onChangeScreenSize(e: Event = null): void
		{
			btnMoveLeft.x =  UI_MARGIN * newScale;
			btnMoveLeft.y = Game.starling.stage.stageHeight - btnMoveLeft.height * 1.5;
			btnMoveRight.x = btnMoveLeft.x + btnMoveLeft.width + UI_MARGIN * newScale;
			btnMoveRight.y = Game.starling.stage.stageHeight - btnMoveRight.height * 1.5;

			btnJumpLeft.x = btnMoveLeft.x;
			btnJumpLeft.y = btnMoveLeft.y - btnMoveLeft.height;

			btnJumpRight.x = Game.starling.stage.stageWidth - btnJumpRight.width - UI_MARGIN * newScale;
			btnJumpRight.y = btnMoveRight.y;
		}
	}
}