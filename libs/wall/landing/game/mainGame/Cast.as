package landing.game.mainGame
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	import Box2D.Common.Math.b2Vec2;

	import landing.game.mainGame.entity.EntityFactory;
	import landing.game.mainGame.entity.IGameObject;
	import landing.game.mainGame.entity.IPinable;
	import landing.game.mainGame.entity.cast.BodyDestructor;
	import landing.game.mainGame.entity.cast.ICastTool;
	import landing.game.mainGame.entity.joints.JointToWorld;
	import landing.game.mainGame.entity.joints.JointToWorldFixed;
	import landing.game.mainGame.entity.simple.GameBody;
	import landing.game.mainGame.events.CastEvent;

	public class Cast extends Sprite implements IUpdate
	{
		static private const CAST_TIME:int = 1000;
		static private const CAST_ROTATE_DELTA:Number = 10 * (Math.PI / 180);

		protected var object:IGameObject;
		protected var timer:Timer = new Timer(CAST_TIME, 1);
		protected var game:SquirrelGame;

		protected var currentPin:JointToWorld;
		protected var pinPosId:int = -1;

		protected var casting:Boolean = false;

		public function Cast(game:SquirrelGame):void
		{
			this.game = game;
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onCastComplete, false, 0, true);

			WallShadow.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		}

		public function dispose():void
		{
			this.castObject = null;
			this.timer = null;
			this.game = null;

			WallShadow.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		public function set castObject(value:IGameObject):void
		{
			if (this.castObject == value)
				return;

			if (this.castObject && this.castObject is IDispose && contains(this.castObject as DisplayObject))
				(this.castObject as IDispose).dispose();

			this.object = value;

			if (value is DisplayObject)
				addChild(value as DisplayObject);

			if (this.currentPin)
			{
				this.currentPin.dispose();
				this.currentPin = null;
				this.pinPos = -1;
			}

			if (this.castObject)
				this.castObject.position = new b2Vec2(WallShadow.stage.mouseX / WallShadow.PIXELS_TO_METRE, WallShadow.stage.mouseY / WallShadow.PIXELS_TO_METRE);

			if (value)
			{
				if (this.game.squirrels.self)
					this.game.squirrels.self.showCircle();

				if (value is GameBody)
					(value as GameBody).casted = true;

				if (value is ICastTool)
					(value as ICastTool).game = this.game;

				WallShadow.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMoveObject, false, 0, true);
				WallShadow.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onRotateObject, false, 0, true);
				WallShadow.stage.addEventListener(MouseEvent.MOUSE_DOWN, onCastStart, false, 0, true);
			}
			else
			{
				if (this.game.squirrels.self)
					this.game.squirrels.self.removeCircle();
				WallShadow.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMoveObject);
				WallShadow.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onRotateObject);
				WallShadow.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onCastStart);
				WallShadow.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastCancel);
				WallShadow.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastComplete);
			}
		}

		public function get castObject():IGameObject
		{
			return this.object;
		}

		public function onObjectSelect(e:CastEvent):void
		{
			this.castObject = (e.objectId is Class) ? new e.objectId() : new (EntityFactory.getEntity(e.objectId) as Class)();
		}

		public function update(timeStep:Number = 0):void
		{
			if (this.castObject == null)
				return;

			var self:wHero = this.game.squirrels.self;
			if (self != null && (self.isDead || self.inHollow))
			{
				dropObject();
				self.removeCircle();
				return;
			}

			(this.castObject as DisplayObject).alpha = resolve() ? 1 : 0.5;

			if (this.timer.running && !resolve())
				onCastCancel();
		}

		protected function onMoveObject(e:MouseEvent):void
		{
			if (this.castObject == null)
				return;

			var pos:Point = globalToLocal(new Point(e.stageX, e.stageY));
			var worldPos:b2Vec2 = new b2Vec2(pos.x / WallShadow.PIXELS_TO_METRE, pos.y / WallShadow.PIXELS_TO_METRE);
			this.castObject.position = worldPos;
			(this.castObject as DisplayObject).alpha = resolve() ? 1 : 0.5;
		}

		protected function onKeyDown(e:KeyboardEvent):void
		{
			if (casting)
				return;

			var key:int = e.keyCode;

			switch (key)
			{
				case Keyboard.ESCAPE:
					dropObject();
					break;
				case Keyboard.Q:
				case Keyboard.E:
					if (!castObject)
						break;
					this.castObject.angle += CAST_ROTATE_DELTA * ((key == Keyboard.Q ? -1 : 0) + (key == Keyboard.E ? 1 : 0))
					break;
				case Keyboard.C:
					if (!(this.castObject is landing.game.mainGame.entity.IPinable))
						return;
					if (this.castObject == null)
						break;

					if (this.currentPin == null || !(getQualifiedClassName(this.currentPin) == getQualifiedClassName(JointToWorld)))
					{
						if (this.currentPin != null)
							this.currentPin.dispose();
						this.currentPin = new JointToWorld();
					}

					this.pinPos++;
					break;
				case Keyboard.V:
					if (!(this.castObject is landing.game.mainGame.entity.IPinable))
						break;
					if (this.castObject == null)
						break;

					if (this.currentPin == null || !(getQualifiedClassName(this.currentPin) == getQualifiedClassName(JointToWorldFixed)))
					{
						if (this.currentPin != null)
							this.currentPin.dispose();
						this.currentPin = new JointToWorldFixed();
					}

					this.pinPos++;
					break;
			}

			if (this.currentPin && this.castObject)
				this.currentPin.body = (this.castObject as GameBody);
		}

		protected function get pinPos():int
		{
			return this.pinPosId;
		}

		protected function set pinPos(value:int):void
		{
			if (this.castObject == null)
				return;

			this.pinPosId = value;

			if (this.pinPosId >= (this.castObject as IPinable).pinPositions.length)
			{
				this.pinPosId = -1;

				if (this.currentPin)
					this.currentPin.dispose();

				this.currentPin = null;
			}

			if (this.pinPosId > -1 && this.currentPin != null)
				this.currentPin.position = (this.castObject as IPinable).pinPositions[this.pinPosId];
		}

		protected function onRotateObject(e:MouseEvent):void
		{
			this.castObject.angle += e.delta * 2 * (Math.PI / 180);
		}

		protected function onCastStart(e:MouseEvent):Boolean
		{
			if (!resolve())
				return false;
			if (castObject is BodyDestructor && !(castObject as BodyDestructor).destroyObject)
				return false;

			this.casting = true;

			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onCastStart);
			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMoveObject);
			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onRotateObject);

			WallShadow.stage.addEventListener(MouseEvent.MOUSE_UP, onCastCancel, false, 0, true);

			this.timer.reset();
			this.timer.start();

			this.game.squirrels.self.castStart(null, CAST_TIME);
			return true;
		}

		protected function onCastCancel(e:MouseEvent = null):void
		{
			this.casting = false;
			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastCancel);

			WallShadow.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMoveObject, false, 0, true);
			WallShadow.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onRotateObject, false, 0, true);
			WallShadow.stage.addEventListener(MouseEvent.MOUSE_DOWN, onCastStart, false, 0, true);

			this.timer.stop();
			this.game.squirrels.self.castStop(false);
		}

		protected function onCastComplete(e:TimerEvent):void
		{
			this.casting = false;

			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_UP, onCastCancel);

			if (!this.castObject)
				return;
			this.removeChild(this.castObject as DisplayObject);
			this.game.map.add(this.castObject);
			(this.castObject as DisplayObject).alpha = 1;
			this.castObject.build(this.game.world);

			if (this.currentPin)
			{
				this.game.map.add(this.currentPin);
				this.currentPin.build(this.game.world);
			}

			this.currentPin = null;
			this.castObject = null;
			this.pinPosId = -1;
			this.game.squirrels.self.castStop(true);
		}

		protected function resolve(circleWidth:int = 222):Boolean
		{
			if (!this.game || !this.game.squirrels || !this.game.squirrels.self || !this.castObject)
				return false;

			var circlePoint:Point = this.game.squirrels.self.getCirclePosition();
			var pos:Point = new Point(castObject.position.x * WallShadow.PIXELS_TO_METRE, castObject.position.y * WallShadow.PIXELS_TO_METRE);
			var lenght:Number = circlePoint.add(new Point(circleWidth / 2, circleWidth / 2)).subtract(pos).length;

			return (lenght < circleWidth / 2);
		}

		private function dropObject():void
		{
			if (this.timer.running)
				return;

			if (this.castObject)
			{
				if (this.castObject is IDispose)
					(this.castObject as IDispose).dispose();
				if (contains(this.castObject as DisplayObject))
					removeChild(this.castObject as DisplayObject);
				this.castObject = null;
			}

			if (this.currentPin)
			{
				if (this.currentPin is IDispose)
					(this.currentPin as IDispose).dispose();
				if (contains(this.currentPin as DisplayObject))
					removeChild(this.currentPin as DisplayObject);
				this.pinPosId = -1;
				this.currentPin = null;
			}
		}
	}
}