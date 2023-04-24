package game.mainGame.perks.clothes
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.setTimeout;

	import game.mainGame.SquirrelGame;
	import screens.ScreenStarling;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;

	import starling.core.Starling;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class PerkClothesSelectPoint extends PerkClothes
	{
		protected var selectCursor:StarlingAdapterSprite = null;
		protected var selectedPoint:Point = new Point();

		protected var _globalPos:Point = new Point();
		protected var _localPos:Point = new Point();
		protected var eventClick:Boolean = false;

		protected var circle:StarlingAdapterMovie = null;

		public function PerkClothesSelectPoint(hero:Hero)
		{
			super(hero);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.circle || !this.hero || !this.circle.visible)
				return;
			var circleCoords:Point = (this.hero.game as SquirrelGame).globalToLocal(this.hero.localToGlobal(new Point(-this.maxRadius, this.hero.heroView.y - this.maxRadius - 23)));
			this.circle.rotation = this.hero.rotation;
			this.circle.x = circleCoords.x;
			this.circle.y = circleCoords.y;
		}

		override public function get json():String
		{
			if (this.active)
				return "";
			return by.blooddy.crypto.serialization.JSON.encode(this.selectedPoint);
		}

		override public function dispose():void
		{
			if (this.circle)
			{
				this.hero.game.removeChildStarling(this.circle);
				this.hero.game.removeChild(this.circle);
				this.circle = null;
			}
			resetSelection();
			super.dispose();
		}

		override public function resetRound():void
		{
			resetSelection();
			super.resetRound();
		}

		override protected function deactivate():void
		{
			resetSelection();
			super.deactivate();
		}

		override public function onUse():void
		{
			if (!this.hero || !this.hero.game)
				return;

			this.selectedPoint = new Point();
			setTimeout(setSelection, 100);
		}

		override public function set active(value:Boolean):void
		{
			if (!value)
				resetSelection();
			super.active = value;
		}

		protected function get maxRadius():Number
		{
			return 0;
		}

		protected function get arrowMode():Boolean
		{
			return false;
		}

		protected function get maxLength():Number
		{
			return 100;
		}

		protected function setSelection():void
		{
			if (!this.hero.isSelf || !this.hero.game)
				return;

			Mouse.hide();

			if (this.selectCursor)
				this.selectCursor.removeFromParent();
			this.selectCursor = new StarlingAdapterSprite(this.arrowMode ? new PoiseArrow() : new HeroPointer());
			this.selectCursor.visible = false;
			ScreenStarling.upLayer.addChild(this.selectCursor.getStarlingView());

			if (this.maxRadius > 0)
			{
				if (!this.circle)
				{
					this.circle = new StarlingAdapterMovie(new Circle());
					this.circle.touchable = false;
					this.circle.visible = false;
					this.circle.stop();
				}
				this.circle.scaleXY(1);
				this.circle.scaleXY(int(this.maxRadius * 2) / this.circle.width);
				this.circle.visible = true;
				this.hero.game.addChildStarling(this.circle);
				this.hero.game.addChild(this.circle);
			}

			this.eventClick = true;

			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onStarlingTouch);
			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}

		protected function resetSelection():void
		{
			if (!this.hero || !this.hero.isSelf)
				return;

			if (this.selectCursor)
				this.selectCursor.removeFromParent();

			this.eventClick = false;
			if (this.circle)
				this.circle.visible = false;

			Mouse.show();

			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onStarlingTouch);
			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}

		public function onKey(event: KeyboardEvent): void
		{
			if (event.keyCode != Keyboard.ESCAPE)
				return;
			resetSelection();
		}

		public function onStarlingTouch(event:TouchEvent): void
		{
			var touch:Touch = event.getTouch(Starling.current.stage);

			if(!touch)
				return;
			this.selectCursor.visible = true;
			if (this.maxRadius > 0)
				this.selectCursor.alpha = this._localPos.subtract(this.hero.heroView.localToGlobal(new Point(0, -20))).length > this.maxRadius ? 0.5 : 1;
			_globalPos.setTo(touch.globalX, touch.globalY);
			_localPos = touch.getLocation(ScreenStarling.instance);

			if (this.arrowMode)
			{
				var heroPoint:Point = this.hero.heroView.localToGlobal(new Point(0, -20));

				var weaponAngle:Number = Math.atan2(_localPos.y - heroPoint.y, _localPos.x - heroPoint.x);
				var length:int = _localPos.subtract(heroPoint).length;

				this.selectCursor.x = heroPoint.x;
				this.selectCursor.y = heroPoint.y;
				this.selectCursor.rotation = 0;
				this.selectCursor.scaleX = 1;
				this.selectCursor.scaleX = Math.min(length, this.maxLength) / this.selectCursor.width;
				this.selectCursor.rotation = weaponAngle * Game.R2D;
			}
			else
			{
				this.selectCursor.x = _localPos.x;
				this.selectCursor.y = _localPos.y;
			}

			switch (touch.phase)
			{
				case TouchPhase.ENDED:
					if (!this.eventClick)
						return;
					onEnded();
					break;
				case TouchPhase.BEGAN:
				case TouchPhase.MOVED:
					break;
			}
		}

		protected function onEnded():void
		{
			if (this.maxRadius > 0 && this._localPos.subtract(this.hero.heroView.localToGlobal(new Point(0, -20))).length > this.maxRadius)
				return;
			var touchPoint:Point = this.hero.game.squirrels.globalToLocal(_globalPos);
			this.selectedPoint = new Point(touchPoint.x / Game.PIXELS_TO_METRE, touchPoint.y / Game.PIXELS_TO_METRE);
			this.selectedPoint.subtract(new Point(this.hero.game.map.x, this.hero.game.map.y));
			Connection.sendData(PacketClient.ROUND_SKILL, this.code, !this.active, this.target, this.json);

			this.eventClick = false;
			if (this.circle)
				this.circle.visible = false;
		}
	}
}