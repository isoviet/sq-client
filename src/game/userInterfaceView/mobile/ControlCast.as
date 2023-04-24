package game.userInterfaceView.mobile
{
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.Cast;
	import game.mainGame.ItemPinCast;
	import game.mainGame.entity.IGameObject;
	import screens.ScreenStarling;

	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class ControlCast extends Sprite
	{
		private const CAST_OBJECT_INDENT: int = 60;
		private const LIST_ROTATION_CONTROL: Array = [-0.40, 0.40, 2.40, 3.0, 3.60];

		private var btnApplyCast: Button = null;
		private var btnCancelCast: Button = null;
		private var btnApplyGhost: Button = null;
		private var btnRotate: Button = null;
		private var btnCastMove: Button = null;
		private var arrayItemPins: Vector.<ItemPinCast> = new Vector.<ItemPinCast>();
		private var arrayControl: Vector.<Button> = new Vector.<Button>();
		private var hero: Hero = null;
		private var castObject: StarlingAdapterSprite = null;
		private var mainCast: Cast = null;
		private var btnRotatePressed: Boolean = false;
		private var btnMoveObjectPressed: Boolean = false;
		private var _clearPoint: b2Vec2 = new b2Vec2();

		public function ControlCast(cast: Cast)
		{
			if (Config.isMobile)
			{
				this.mainCast = cast;

				btnApplyCast = new Button(StarlingConverter.getTexture(new BtnCastApply()));
				btnCancelCast = new Button(StarlingConverter.getTexture(new BtnCastCancel()));
				btnApplyGhost = new Button(StarlingConverter.getTexture(new BtnCastApplyGhost()));
				btnRotate = new Button(StarlingConverter.getTexture(new BtnCastRotate()));
				btnCastMove = new Button(StarlingConverter.getTexture(new BtnCastMove()));


				arrayControl.push(btnCancelCast);
				arrayControl.push(btnApplyCast);
				arrayControl.push(btnRotate);
				arrayControl.push(btnCastMove);
				arrayControl.push(btnApplyGhost);

				for (var i:int = 0, len:int = arrayControl.length; i < len; i++)
				{
					arrayControl[i].alignPivot();
					arrayControl[i].pivotY = 130;
					arrayControl[i].rotation = LIST_ROTATION_CONTROL[i];
				}

				addChild(btnApplyCast);
				addChild(btnCancelCast);
				addChild(btnApplyGhost);
				addChild(btnRotate);
				addChild(btnCastMove);

				this.visible = false;

				btnCancelCast.addEventListener(TouchEvent.TOUCH, onTouchControl);
				btnRotate.addEventListener(TouchEvent.TOUCH, onTouchControl);
				btnApplyGhost.addEventListener(TouchEvent.TOUCH, onTouchControl);
				btnApplyCast.addEventListener(TouchEvent.TOUCH, onTouchControl);
				btnCastMove.addEventListener(TouchEvent.TOUCH, onTouchControl);

				ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onTouchScreen);
			}
		}

		public function hideControl(): void
		{
			this.visible = false;
		}

		private function onTouchScreen(e: TouchEvent): void
		{
			var touch: Touch = e.getTouch(e.currentTarget as DisplayObject, TouchPhase.MOVED);
			var point: Point;

			if (touch != null && btnRotatePressed == true && this.castObject.parentStarling != null)
			{
				point = touch.getLocation(this.castObject.parentStarling.getStarlingView());
				this.castObject.rotation = Math.atan2(point.y - this.castObject.y, point.x - this.castObject.x) * 180 / Math.PI;

				point = touch.getLocation(this.btnRotate.parent);
				btnRotate.x = point.x - 60;
				btnRotate.y = point.y - 60;
			}else if(touch != null && btnMoveObjectPressed == true && this.castObject != null)
			{
				point = touch.getLocation(this.castObject.parentStarling.getStarlingView());
				this.x = point.x - btnCastMove.x;
				this.y = point.y - (btnCastMove.y + 110);

				this.castObject.x = this.x;
				this.castObject.y = this.y;
				_clearPoint.Set(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
				(this.castObject as IGameObject).position = _clearPoint;
			}
		}

		private function onTouchControl(e: TouchEvent): void
		{
			var touch: Touch = e.getTouch(e.currentTarget as DisplayObject);

			if (touch == null)
				return;

			if (btnCancelCast == e.currentTarget && touch.phase == TouchPhase.ENDED)
			{
				this.mainCast.dropObject();
				this.visible = false;
				btnMoveObjectPressed = false;
			}
			else if (btnRotate == e.currentTarget && touch.phase == TouchPhase.BEGAN)
			{
				btnRotatePressed = true;
				btnMoveObjectPressed = false;
			}
			else if (btnRotate == e.currentTarget && touch.phase == TouchPhase.ENDED)
			{
				btnRotatePressed = false;
				btnMoveObjectPressed = false;
			}
			else if (btnApplyGhost == e.currentTarget && touch.phase == TouchPhase.ENDED)
			{
				btnMoveObjectPressed = false;
				this.mainCast.applyGhostToObject();
			}
			else if (btnApplyCast == e.currentTarget && touch.phase == TouchPhase.BEGAN)
			{
				btnMoveObjectPressed = false;
				this.mainCast.onCastStart();
			}
			else if (btnApplyCast == e.currentTarget && touch.phase == TouchPhase.ENDED)
			{
				btnMoveObjectPressed = false;
				this.mainCast.onCastCancel();
			}
			else if (this.castObject != null && btnCastMove == e.currentTarget && touch.phase == TouchPhase.BEGAN)
			{
				btnMoveObjectPressed = true;
			}
			else if (this.castObject != null && btnCastMove == e.currentTarget && touch.phase == TouchPhase.ENDED)
			{
				btnMoveObjectPressed = false;
			}

			if (btnCastMove != e.currentTarget && btnRotate != e.currentTarget) {
				e.stopPropagation();
			}
		}

		public function setCastObject(object: IGameObject, hero: Hero): void
		{
			if (Config.isMobile)
			{
				this.visible = true;
				this.hero = hero;
				this.castObject = (object as StarlingAdapterSprite);

				this.castObject.touchable = false;

				_clearPoint.Set(hero.position.x + CAST_OBJECT_INDENT * (hero.heroView.direction ? -1 : 1), hero.position.y);
				(this.castObject as IGameObject).position = _clearPoint;

				showViewPins();

				this.x = hero.position.x * Game.PIXELS_TO_METRE + CAST_OBJECT_INDENT * (hero.heroView.direction ? -1 : 1);
				this.y = hero.position.y * Game.PIXELS_TO_METRE;
				this.castObject.x = this.x;
				this.castObject.y = this.y;
			}
		}

		public function availablePins(pins: Array): void
		{
			if (Config.isMobile)
			{
				var itemPins:ItemPinCast = null;

				for (var i:int = 0, len:int = arrayItemPins.length; i < len; i++)
				{
					arrayItemPins[i].remove();
				}

				arrayItemPins = new Vector.<ItemPinCast>();

				for (i = 0, len = pins.length; i < len; i++)
				{
					if (Cast.PINS.indexOf(pins[i]) > -1)
					{
						itemPins = new ItemPinCast(pins[i], onApplyPin);
						arrayItemPins.push(itemPins);
						addChild(itemPins);
					}
				}
			}
		}

		public function remove(): void
		{
			if (Config.isMobile)
			{
				btnCancelCast.removeEventListener(TouchEvent.TOUCH, onTouchControl);
				btnRotate.removeEventListener(TouchEvent.TOUCH, onTouchControl);
				btnApplyGhost.removeEventListener(TouchEvent.TOUCH, onTouchControl);
				btnApplyCast.removeEventListener(TouchEvent.TOUCH, onTouchControl);
				btnCastMove.removeEventListener(TouchEvent.TOUCH, onTouchControl);
				ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onTouchScreen);

				this.visible = false;

				for (var i:int = 0, len:int = arrayControl.length; i < len; i++)
				{
					arrayControl[i].removeFromParent(true);
				}

				for (i = 0, len = arrayItemPins.length; i < len; i++)
				{
					arrayItemPins[i].remove();
				}

				this.mainCast = null;
				this.hero = null;
				this.castObject = null;
				arrayControl = null;
				arrayItemPins = null;

				btnApplyCast = null;
				btnCancelCast = null;
				btnApplyGhost = null;
				btnRotate = null;
				btnCastMove = null;
			}
			this.removeFromParent(true);
		}

		private function onApplyPin(itemPins: ItemPinCast): void
		{
			btnMoveObjectPressed = false;
			this.mainCast.setPin(itemPins.getPinClass());
		}

		private function showViewPins(): void
		{
			var offset: Number = 0.850;

			for (var i: int = 0, len: int = arrayItemPins.length; i < len; i++)
			{
				arrayItemPins[i].x = 0;
				arrayItemPins[i].y = 0;
				arrayItemPins[i].rotation = offset + i * 0.38;
				if (i == 3)
					offset += 1.85;
			}
		}
	}
}