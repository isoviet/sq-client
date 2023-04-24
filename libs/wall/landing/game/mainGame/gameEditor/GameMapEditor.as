package landing.game.mainGame.gameEditor
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	import Box2D.Common.Math.b2Vec2;

	import landing.game.mainGame.GameMap;
	import landing.game.mainGame.ISerialize;
	import landing.game.mainGame.SquirrelGame;
	import landing.game.mainGame.entity.EntityFactory;
	import landing.game.mainGame.entity.IGameObject;
	import landing.game.mainGame.entity.editor.Cover;
	import landing.game.mainGame.entity.editor.PlatformGroundBody;
	import landing.game.mainGame.entity.editor.ShamanBody;
	import landing.game.mainGame.entity.editor.SquirrelBody;
	import landing.game.mainGame.entity.joints.JointDistance;
	import landing.game.mainGame.entity.joints.JointLinear;
	import landing.game.mainGame.entity.joints.JointPrismatic;
	import landing.game.mainGame.entity.joints.JointPulley;
	import landing.game.mainGame.entity.joints.JointToBody;
	import landing.game.mainGame.entity.joints.JointToBodyFixed;
	import landing.game.mainGame.entity.joints.JointToBodyMotor;
	import landing.game.mainGame.entity.joints.JointToBodyMotorCCW;
	import landing.game.mainGame.entity.joints.JointToWorld;
	import landing.game.mainGame.entity.joints.JointToWorldFixed;
	import landing.game.mainGame.entity.joints.JointToWorldMotor;
	import landing.game.mainGame.entity.joints.JointToWorldMotorCCW;
	import landing.game.mainGame.entity.joints.JointWeld;
	import landing.game.mainGame.entity.simple.AcornBody;
	import landing.game.mainGame.entity.simple.HollowBody;
	import tape.TapeShamaning;

	import by.blooddy.crypto.serialization.JSON;

	public class GameMapEditor extends GameMap
	{
		static private const ROTATE_DELTA:int = 10;

		private var newObject:IGameObject;
		private var tapeShamaning:TapeShamaning
		public var _enabled:Boolean = true;
		public var selection:Selection;

		public function GameMapEditor(game:SquirrelGame, tapeShamaning:TapeShamaning):void
		{
			super(game);

			this.selection = new Selection(this);
			addChild(selection);

			this.tapeShamaning = tapeShamaning;

			WallShadow.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		}

		override public function dispose():void
		{
			super.dispose();
			WallShadow.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			WallShadow.stage.removeEventListener(MouseEvent.CLICK, onPlace);
			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMovePlace);

			this.selection.dispose();
			this.selection = null;
			this.newObject = null;
			this.tapeShamaning = null;
		}

		override public function clear():void
		{
			super.clear();

			if (this.newObject == null)
				return;

			removeChild(this.newObject as DisplayObject);
			this.newObject = null;
		}

		public function createObject(objectId:*):void
		{
			if (!this._enabled)
				return;

			this.selection.clear()

			if (this.newObject != null && contains(this.newObject as DisplayObject))
				removeChild(this.newObject as DisplayObject);

			if (objectId == -1 || objectId == null)
			{
				this.newObject = null;
				WallShadow.stage.removeEventListener(MouseEvent.CLICK, onPlace);
				WallShadow.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMovePlace);
				this.selection.visible = true;
				return;
			}

			this.selection.visible = false;
			this.newObject = (objectId is Class) ? new objectId() : new (EntityFactory.getEntity(objectId) as Class)();

			(this.newObject as DisplayObject).alpha = 0.5;

			addChild(this.newObject as DisplayObject);
			if (this.newObject is PlatformGroundBody)
				(this.newObject as PlatformGroundBody).init();

			this.newObject.position = new b2Vec2(WallShadow.stage.mouseX / WallShadow.PIXELS_TO_METRE, WallShadow.stage.mouseY / WallShadow.PIXELS_TO_METRE);

			WallShadow.stage.addEventListener(MouseEvent.CLICK, onPlace, false, 0, true);
			WallShadow.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMovePlace, false, 0, true);
		}

		override public function serialize():*
		{
			var result:Array = new Array();

			result.push(backgroundId);

			var objects:Array = new Array();

			resort();

			for each (var object:* in this.objects)
			{
				if (object is ISerialize)
					objects.push([EntityFactory.getId(object), (object as ISerialize).serialize()]);
			}

			result.push(objects);
			result.push(this.tapeShamaning.serialize());

			return JSON.encode(result);
		}

		private function onObjectDown(e:MouseEvent):void
		{
			if (!this._enabled)
				return;
		}

		public function set enabled(value:Boolean):void
		{
			this._enabled = value;
			this.selection.visible = value;

			if (!value)
				this.selection.clear();
		}

		public function isValid():Boolean
		{
			return get(SquirrelBody).length > 0 && get(ShamanBody).length > 0 && get(AcornBody).length > 0 && get(HollowBody).length > 0;
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.DELETE:
					selection.deleteSelected();
					createObject(-1);
					break;
				case Keyboard.C:
					createObject(JointToWorld);
					break;
				case Keyboard.V:
					createObject(JointToWorldFixed);
					break;
				case Keyboard.B:
					createObject(JointToBody);
					break;
				case Keyboard.N:
					createObject(JointToBodyFixed);
					break;
				case Keyboard.M:
					createObject(JointToBodyMotor);
					break;
				case Keyboard.S:
					createObject(JointDistance);
					break;
				case Keyboard.F:
					createObject(JointPrismatic);
					break;
				case Keyboard.G:
					createObject(JointPulley);
					break;
				case Keyboard.H:
					createObject(JointWeld);
					break;
				case Keyboard.J:
					createObject(JointLinear);
					break;
				case Keyboard.COMMA:
					createObject(JointToBodyMotorCCW);
					break;
				case Keyboard.PERIOD:
					createObject(JointToWorldMotor);
					break;
				case Keyboard.SLASH:
					createObject(JointToWorldMotorCCW);
					break;
				case Keyboard.UP:
					if (this.newObject)
						this.newObject.angle += ROTATE_DELTA * (Math.PI / 180);
					break;
				case Keyboard.DOWN:
					if (this.newObject)
						this.newObject.angle -= ROTATE_DELTA * (Math.PI / 180);
					break;
			}
		}

		private function onMovePlace(e:MouseEvent):void
		{
			this.newObject.position = new b2Vec2(e.stageX / WallShadow.PIXELS_TO_METRE, e.stageY / WallShadow.PIXELS_TO_METRE);
		}

		private function onPlace(e:MouseEvent):void
		{
			selection.visible = true;
			WallShadow.stage.removeEventListener(MouseEvent.CLICK, onPlace);
			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMovePlace);

			if (this.newObject == null)
				return;

			(this.newObject as DisplayObject).alpha = 1;

			if (this.newObject is Cover)
			{
				if ((this.newObject as DisplayObject).parent != null)
					(this.newObject as DisplayObject).parent.removeChild(this.newObject as DisplayObject);
				this.newObject = null;
				return;
			}

			add(this.newObject);

			var objectId:int = EntityFactory.getId(this.newObject);
			var angle:Number = this.newObject.angle;

			this.newObject = null;

			if (!e.ctrlKey)
				return;

			createObject(objectId);
			this.newObject.angle = angle;
		}
	}
}