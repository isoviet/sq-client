package game.mainGame.gameEditor
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Keyboard;

	import Box2D.Common.Math.b2Vec2;

	import events.EditNewElementEvent;
	import game.mainGame.GameMap;
	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.ICover;
	import game.mainGame.entity.IDragable;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.battle.SpikePoiseRespawn;
	import game.mainGame.entity.editor.BlackShamanBody;
	import game.mainGame.entity.editor.BlueTeamBody;
	import game.mainGame.entity.editor.Covered;
	import game.mainGame.entity.editor.RectGravity;
	import game.mainGame.entity.editor.RedShamanBody;
	import game.mainGame.entity.editor.RedTeamBody;
	import game.mainGame.entity.editor.ShamanBody;
	import game.mainGame.entity.editor.SquirrelBody;
	import game.mainGame.entity.editor.ZombieBody;
	import game.mainGame.entity.editor.inspector.InspectorDialog;
	import game.mainGame.entity.iceland.IceBlockGenerator;
	import game.mainGame.entity.iceland.NYSnowGenerator;
	import game.mainGame.entity.iceland.NYSnowReceiver;
	import game.mainGame.entity.joints.JointDistance;
	import game.mainGame.entity.joints.JointPulley;
	import game.mainGame.entity.joints.JointToBody;
	import game.mainGame.entity.joints.JointToBodyFixed;
	import game.mainGame.entity.joints.JointToBodyMotor;
	import game.mainGame.entity.joints.JointToBodyMotorCCW;
	import game.mainGame.entity.joints.JointToWorld;
	import game.mainGame.entity.joints.JointToWorldFixed;
	import game.mainGame.entity.joints.JointToWorldMotor;
	import game.mainGame.entity.joints.JointToWorldMotorCCW;
	import game.mainGame.entity.joints.JointWeld;
	import game.mainGame.entity.simple.AcornBody;
	import game.mainGame.entity.simple.BlueHollowBody;
	import game.mainGame.entity.simple.FlyWayPoint;
	import game.mainGame.entity.simple.HollowBody;
	import game.mainGame.entity.simple.RedHollowBody;
	import screens.ScreenStarling;
	import tape.TapeShamaning;

	import interfaces.IDispose;

	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;

	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterSprite;

	public class GameMapEditor extends GameMap
	{
		static private const ROTATE_DELTA:int = 10;

		private var newObject:IGameObject = null;
		private var tapeShamaning:TapeShamaning = null;
		private var gameEditor:SquirrelGameEditor;

		private var _scale:Number = 1;
		private var objectStatus:StatusObjectName;

		public var _enabled:Boolean = true;
		public var selection:Selection = null;

		public var wndInspector: InspectorDialog = null;
		private var locPointsStarling: Point;

		public function GameMapEditor(game:SquirrelGame, gameEditor:SquirrelGameEditor):void
		{
			super(game);
			this.gameEditor = gameEditor;

			this.selection = new Selection(this, gameEditor);
			addChild(selection);
			addChild(drawSprite);

			this.size = this.size;
			this.objectStatus = new StatusObjectName(this);
			Game.stage.doubleClickEnabled = true;
			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onStarlingTouch);
			ScreenStarling.instance.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			Game.stage.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
		}

		private function onDoubleClick(e: MouseEvent): void
		{
			showInspector();
		}

		public function checkSelectObject(points: Point): StarlingAdapterSprite {

			var i:int = this.gameObjects().length - 1;
			while (i >= 0) {
				if (this.gameObjects().length >= i - 1)
				{
					var mapChild:StarlingAdapterSprite = this.gameObjects()[i--];
					if (mapChild is IStarlingAdapter && points && mapChild.hitTestStarling(points, false)) {
						return	mapChild;
					}
				}
			}
			return null;
		}

		public function onStarlingTouch(event: TouchEvent): void {
			var touch:Touch = event.getTouch(ScreenStarling.instance);
			// if mouse leave stage
			if(!touch)
				return;
			locPointsStarling = touch.getLocation(ScreenStarling.instance);

			onMovePlace(touch);
		}

		public function getVisibleInspector(): Boolean {
			return this.wndInspector && this.wndInspector.visible;
		}

		private function showInspector():void
		{
			var i: int = this.objectSprite.numChildren - 1;
			while (i >= 0) {
				var mapChild:StarlingAdapterSprite = this.objectSprite.getChildStarlingAt(i--);
				var localInObjPos:Point = locPointsStarling;
				if (!(mapChild is ICover) && mapChild.hitTestStarling(localInObjPos, false)) {
					this.selection.resetMovable();
					if (this.wndInspector)
						this.wndInspector.hide();

					this.wndInspector = new InspectorDialog(mapChild);
					this.wndInspector.show();
					this.wndInspector.visible = true;
					break;
				}
			}

		}

		public function setTapeShamaning(tape:TapeShamaning):void
		{
			this.tapeShamaning = tape;
		}

		override public function dispose():void
		{
			this.drawAllMap = false;

			super.dispose();

			Game.stage.removeEventListener(MouseEvent.CLICK, onPlace);
			Game.stage.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onStarlingTouch);
			ScreenStarling.instance.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			this.selection.dispose();
			this.selection = null;
			this.newObject = null;
			this.tapeShamaning = null;

			if (this.objectStatus)
				this.objectStatus.remove();
			this.objectStatus = null;
		}

		override public function get size():Point
		{
			return super.size;
		}

		override public function set size(value:Point):void
		{
			if (this.drawSprite)
			{
				super.size = value;

				this.drawSprite.graphics.clear();
				this.drawSprite.graphics.lineStyle(5, 0x00C113);
				this.drawSprite.graphics.drawRect(0, Config.GAME_HEIGHT * this.scale, this.size.x * this.scale, - this.size.y * this.scale);
			}
		}

		override public function add(object:* = null):void
		{
			super.add(object);

			initDoubleClick(object);

			if (object is IEditorDebugDraw)
				(object as IEditorDebugDraw).showDebug = true;

			dispatchEvent(new EditNewElementEvent(object, EditNewElementEvent.ADD));
		}

		override public function remove(object:*, doDispose:Boolean = false):void
		{
			super.remove(object, doDispose);

			dispatchEvent(new EditNewElementEvent(object, EditNewElementEvent.REMOVE));
		}

		override public function clear():void
		{
			super.clear();

			if (this.newObject == null)
				return;

			removeChildStarling(this.newObject as IStarlingAdapter);
			this.newObject = null;
		}

		override public function serialize():*
		{
			this.shamanTools = this.tapeShamaning.serialize();

			return super.serialize();
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
		}

		public function set enabled(value:Boolean):void
		{
			this._enabled = value;
			this.selection.visible = value;
			this.showStatuses = value;

			if (value)
				return;

			this.selection.clear();
		}

		public function get scale():Number
		{
			return this._scale;
		}

		public function isValid(locationId:int, modeId:int = -1):Boolean
		{
			switch (modeId)
			{
				case Locations.DRAGON_MODE:
					return has(SquirrelBody) && has(AcornBody) && has(HollowBody);
				case Locations.TWO_SHAMANS_MODE:
					return (get(RedShamanBody).length == 1) && (get(ShamanBody).length == 1) && has(SquirrelBody) && has(AcornBody) && (get(BlueHollowBody).length == 1) && (get(RedHollowBody).length == 1);
				case Locations.BLACK_SHAMAN_MODE:
					return (has(BlackShamanBody) && has(SquirrelBody));
				case Locations.FLY_NUT_MODE:
					return has(SquirrelBody) && has(AcornBody) && has(HollowBody) && has(FlyWayPoint);
				case Locations.ZOMBIE_MODE:
					return has(SquirrelBody) && has(ZombieBody) && !has(AcornBody) && !has(HollowBody);
				case Locations.VOLCANO_MODE:
					return has(SquirrelBody) && !has(AcornBody) && !has(HollowBody);
				case Locations.SNOWMAN_MODE:
					return has(NYSnowGenerator) && has(NYSnowReceiver) && has(IceBlockGenerator);
			}

			switch (locationId)
			{
				case Locations.BATTLE_ID:
				case Locations.TENDER:
					return has(RedTeamBody) && has(BlueTeamBody) && has(ShamanBody) && has(RedShamanBody) && has(SpikePoiseRespawn);
			}

			return has(SquirrelBody) && has(ShamanBody) && has(AcornBody) && has(HollowBody);
		}

		public function isValid2(locationId:int, modeId:int = -1):Boolean
		{
			switch (modeId)
			{
				case Locations.SNOWMAN_MODE:
				case Locations.DRAGON_MODE:
					return !(has(RedTeamBody) || has(BlueTeamBody) || has(RedShamanBody) || has(SpikePoiseRespawn) || has(ShamanBody) || has(BlueHollowBody) || has(RedHollowBody) || has(BlackShamanBody));
				case Locations.TWO_SHAMANS_MODE:
					return !(has(BlueTeamBody) || has(RedTeamBody) || has(SpikePoiseRespawn) || has(HollowBody) || has(BlackShamanBody));
				case Locations.BLACK_SHAMAN_MODE:
					return !(has(AcornBody) || has(HollowBody) || has(BlueTeamBody) || has(RedTeamBody) || has(RedShamanBody) || has(BlueHollowBody) || has(RedHollowBody));
				case Locations.ROPED_MODE:
					if (get(SquirrelBody).length > 2)
						return false;
					else if (get(SquirrelBody).length < 2)
						break;
					else
					{
						var players:Array = get(SquirrelBody);

						var positions:Vector.<b2Vec2> = new Vector.<b2Vec2>();
						for each (var player:IGameObject in players)
							positions.push(player.position);

						if (Math.sqrt(Math.pow((positions[0].x - positions[1].x), 2) + Math.pow((positions[0].y - positions[1].y), 2)) >= 10)
							return false;
						break;
					}
				case Locations.FLY_NUT_MODE:
					var flyWayPoints:Array = get(FlyWayPoint);
					for each (var point:FlyWayPoint in flyWayPoints)
						if (point.bindPoints.length == 0)
							return false;
			}

			switch (locationId)
			{
				case Locations.BATTLE_ID:
				case Locations.TENDER:
					return !(has(AcornBody) || has(HollowBody) || has(BlueHollowBody) || has(RedHollowBody) || has(BlackShamanBody));
			}

			return !(has(RedTeamBody) || has(BlueTeamBody) || has(RedShamanBody) || has(SpikePoiseRespawn) || has(BlueHollowBody) || has(RedHollowBody) || has(BlackShamanBody));
		}

		public function createObject(objectId:*):void
		{
			if (!this._enabled)
				return;

			this.selection.clear();

			if (this.newObject != null && this.objectSprite.containsStarling(this.newObject))
				ScreenStarling.groundLayer.removeChild((this.newObject as IStarlingAdapter).getStarlingView());

			if (this.newObject is IDispose)
				(this.newObject as IDispose).dispose();

			if (objectId == -1 || objectId == null)
			{
				this.newObject = null;
				Game.stage.removeEventListener(MouseEvent.CLICK, onPlace);
				this.selection.visible = true;
				return;
			}

			this.selection.visible = false;
			this.newObject = (objectId is Class) ? new objectId() : new (EntityFactory.getEntity(objectId) as Class)();

			(this.newObject as StarlingAdapterSprite).alpha = 0.5;

			if (this.newObject is IDragable)
				(this.newObject as IDragable).init(this.scale);

			if (this.newObject is RectGravity)
				(this.newObject as RectGravity).init();

			var localPos:Point = this.globalToLocal(new Point(Game.stage.mouseX, Game.stage.mouseY));
			this.newObject.position = new b2Vec2(int(localPos.x) / Game.PIXELS_TO_METRE / this.scale, int(localPos.y) / Game.PIXELS_TO_METRE / this.scale);

			this.objectSprite.addChildStarling(this.newObject);
			initDoubleClick(this.newObject);
			Game.stage.addEventListener(MouseEvent.CLICK, onPlace, false, 0, true);
		}

		private function initDoubleClick(object:*):void
		{
			if (object == null)
				return;

			object.doubleClickEnabled = true;
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (!this.getVisibleInspector() && !(Game.stage.focus is TextField))
			{
				Game.stage.focus = this;
			}

			if (Game.stage.focus != null && Game.stage.focus != this || Game.stage.focus == null)
				return;

			if (e.ctrlKey)
				return;

			switch (e.keyCode)
			{
				case Keyboard.DELETE:
				case Keyboard.BACKSPACE:
					this.selection.deleteSelected();
					createObject(null);
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
				case Keyboard.G:
					createObject(JointPulley);
					break;
				case Keyboard.H:
					createObject(JointWeld);
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
					if (this.newObject != null)
						this.newObject.angle += ROTATE_DELTA * (Game.D2R);
					break;
				case Keyboard.DOWN:
					if (this.newObject != null)
						this.newObject.angle -= ROTATE_DELTA * (Game.D2R);
					break;
				case Keyboard.SPACE:
					if (!this.gameEditor.isTest)
						this.gameEditor.header.onHand();
					break;
			}
		}

		private function onMovePlace(e:Touch):void
		{
			if (e && e.globalX && e.globalY && this.newObject) {
				var localPos:Point = this.globalToLocal(new Point(e.globalX, e.globalY));
				this.newObject.position = new b2Vec2(localPos.x / Game.PIXELS_TO_METRE / this.scale, localPos.y / Game.PIXELS_TO_METRE / this.scale);
			}

			if (this._enabled) {
				super.drawVisibleObjects(true);
			}
		}

		private function onPlace(e:MouseEvent):void
		{
			this.selection.visible = true;

			Game.stage.removeEventListener(MouseEvent.CLICK, onPlace);

			if (this.newObject is ICover) {
				locPointsStarling.x -= 1;
				locPointsStarling.y -= 1;
				var itemCover: StarlingAdapterSprite = this.checkSelectObject(locPointsStarling);
				if (itemCover is Covered) {
					(this.newObject as ICover).addCoveredObject(itemCover);
				}
				itemCover = null;
			}

			if (this.newObject == null)
				return;

			(this.newObject as StarlingAdapterSprite).alpha = 1;

			if (this.newObject is ICover)
			{
				(this.newObject as IStarlingAdapter).removeFromParent();
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

		private function set showStatuses(value:Boolean):void
		{
			if (value && !this.objectStatus)
				this.objectStatus = new StatusObjectName(this);

			if (!value && this.objectStatus)
			{
				this.objectStatus.remove();
				this.objectStatus = null;
			}
		}

		override protected function createDynamicBackground(): void
		{}
	}
}