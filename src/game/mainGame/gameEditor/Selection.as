package game.mainGame.gameEditor
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	import Box2D.Common.Math.b2Vec2;

	import events.EditNewElementEvent;
	import game.mainGame.IReflect;
	import game.mainGame.ISerialize;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.ILimitedAngles;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.editor.inspector.InspectorDialog;
	import game.mainGame.entity.simple.BindPoint;
	import game.mainGame.entity.simple.FlyWayPoint;
	import game.mainGame.entity.simple.GameBody;
	import screens.ScreenStarling;

	import starling.core.Starling;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;

	import utils.GeomUtil;
	import utils.Rotator;
	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterSprite;

	public class Selection extends Sprite
	{
		public var selection:Vector.<IGameObject> = new Vector.<IGameObject>();
		public var handButton:Boolean = false;

		private var gameEditor:SquirrelGameEditor;
		private var map:GameMapEditor = null;
		private var mouseDownPoint:Point = null;
		private var dragObject:Boolean = false;

		private var rotators:Dictionary = new Dictionary(true);
		private var _rotationPoint:Point = new Point();
		private var rotationPointSprite:SelectionCenter = new SelectionCenter();

		private var scrollEnabled:Boolean = false;

		private var rotationEnabled:Boolean = false;
		private var prevAngle:Number = 0;
		private var rotationToolSprite:DisplayObject = new RotateButton();

		private var scaleSprite:Sprite = new Sprite();
		private var scaleButtonBR:ScaleButton = new ScaleButton();
		private var scaleButtonTL:ScaleButton = new ScaleButton();
		private var scaleBREnabled:Boolean = false;
		private var scaleTLEnabled:Boolean = false;

		private var bindButton:BindButton = new BindButton();
		private var bindEnabled:Boolean = false;

		private var selectionEnabled:Boolean = false;
		private var selectionRectangleSprite:Sprite = new Sprite();
		private var selectionRectangleStart:Point = new Point();
		private var selectionRectangleEnd:Point = new Point();
		private var releaseButton: Boolean = true;

		private var _localPos: Point;
		private var _globalPos: Point;
		private var lastSelectObject: StarlingAdapterSprite = null;
		private var _mouseDown: Boolean = false;

		public function Selection(map:GameMapEditor, gameEditor:SquirrelGameEditor):void
		{
			this.map = map;

			this.gameEditor = gameEditor;

			addChild(this.rotationPointSprite);
			addChild(this.rotationToolSprite);

			updateScaleButton();
			updateBindButton();

			this.scaleSprite.addChild(this.scaleButtonBR);
			this.scaleSprite.addChild(this.scaleButtonTL);
			addChild(this.scaleSprite);

			addChild(this.bindButton);

			drawRectangle();

			addChild(this.selectionRectangleSprite);

			this.rotationPoint = this.selectionCenter;

			Game.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			Game.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			Game.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onStarlingTouch);
			ScreenStarling.instance.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		public function onStarlingTouch(event: TouchEvent): void {
			var touch:Touch = event.getTouch(Starling.current.stage);

			// if mouse leave stage
			if(!touch)
				return;

			_globalPos = new Point(touch.globalX, touch.globalY);
			_localPos = touch.getLocation(ScreenStarling.instance);
		}

		public function get rotationPoint():Point
		{
			return this._rotationPoint;
		}

		public function set rotationPoint(value:Point):void
		{
			this._rotationPoint = value;
			for each (var rotator:Rotator in this.rotators)
				rotator.setRegistrationPoint(value);

			this.rotationPointSprite.x = int(value.x * this.gameEditor.scale);
			this.rotationPointSprite.y = int(value.y * this.gameEditor.scale);
			this.rotationPointSprite.visible = this.selection.length > 0;

			this.rotationToolSprite.x = value.x * this.gameEditor.scale + 100;
			this.rotationToolSprite.y = value.y * this.gameEditor.scale;
			this.rotationToolSprite.visible = this.selection.length > 0;

			this.prevAngle = 0;

			updateScaleButton();
		}

		public function get selectionCenter():Point
		{
			var center:Point = new Point();
			var count:int = 0;

			for (var object:* in this.rotators)
			{
				count++;
				center = new Point(object.x, object.y).add(center);
			}

			return new Point(center.x / count, center.y / count);
		}

		public function dispose():void
		{
			clear();

			Game.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onStarlingTouch);

			this.map = null;
			this.selection = null;
			this.rotators = null;
			this.rotationToolSprite = null;
			this.rotationPointSprite = null;
			this.selectionRectangleSprite = null;
			this.scaleButtonBR = null;
			this.scaleButtonTL = null;
		}

		public function deleteSelected():void
		{
			this.gameEditor.saveStep();

			while (this.selection.length > 0)
			{
				var object:IGameObject = this.selection[0];

				if (object is BindPoint)
					(object as BindPoint).removeWays();

				remove(object);
				this.map.remove(object, true);
			}
		}

		public function rotate(angle:Number):void
		{
			for each (var rotator:Rotator in this.rotators)
				rotator.rotation += angle;
			updateScaleButton();
		}

		public function add(object:IGameObject, clearBefore:Boolean = false):void
		{
			if (object == null)
				return;
			if (this.selection.indexOf(object) != -1)
				return;

			if (clearBefore)
				clear();

			this.selection.push(object);

			if (object is IStarlingAdapter)
			{
				this.rotators[object] = new Rotator(object);
				this.rotationPoint = this.selectionCenter;
				//(object as StarlingAdapterSprite).filters = [new GlowFilter(0xFFFFFF, 1, 10, 10, 5, 1, true)];
			}

			if (object is IComplexEditorObject)
				(object as IComplexEditorObject).onSelect(this);

			updateScaleButton();
			updateBindButton();

			if (!(object is Sprite))
				return;

			this.selectionEnabled = false;
			(object as EventDispatcher).addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

			dispatchEvent(new EditNewElementEvent(object, EditNewElementEvent.SELECT));
		}

		public function clear():void
		{
			while (this.selection.length > 0)
				remove(this.selection[0]);
		}

		public function remove(object:IGameObject):void
		{
			if (object == null)
				return;

			var index:int = this.selection.indexOf(object);
			if (index == -1)
				return;
			this.selection.splice(index, 1);

			if (object is IStarlingAdapter)
			{
				(object as StarlingAdapterSprite).filters = [];
				delete this.rotators[object];
			}

			(object as EventDispatcher).removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

			this.rotationPoint = this.selectionCenter;

			updateScaleButton();
			updateBindButton();

			dispatchEvent(new EditNewElementEvent(null, EditNewElementEvent.SELECT));
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			var newIndex: int = 0;
			var indexInArray: int = 0;

			if (this.map && !this.map.getVisibleInspector() && !(Game.stage.focus is TextField))
			{
				Game.stage.focus = this.map;
			}

			if (Game.stage.focus != this.map || Game.stage.focus == null)
				return;

			switch (e.keyCode)
			{
				case Keyboard.D:
					if (!e.ctrlKey)
						break;

					copy();
					break;
				case Keyboard.Z:
					if (e.ctrlKey)
					{
						for each (var item:IGameObject in this.selection)
						{
							if (!(item is IReflect))
								continue;
							(item as IReflect).orientation = !(item as IReflect).orientation;
						}
					}
					else
					{
						for each (var object:IGameObject in this.selection)
						{
							if (!(object is GameBody))
								continue;
							(object as GameBody).ghost = !(object as GameBody).ghost;
						}
					}
					break;
				case Keyboard.X:
					if (this.selection.length == 1 || (this.selection.length > 0 && this.selection[0] is IComplexEditorObject))
						this.map.wndInspector = new InspectorDialog(this.selection[0]);

					if (this.selection.length == 0)
						this.map.wndInspector = new InspectorDialog(this.map);

					if (this.map.wndInspector)
					{
						this.map.wndInspector.show();
						this.map.wndInspector.visible = true;
					}
					break;
				case Keyboard.DOWN:
				case Keyboard.UP:
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					var amount:Number = (e.ctrlKey ? 10 : 1);
					var xDir:int = (e.keyCode == Keyboard.LEFT ? -1 : 0) + (e.keyCode == Keyboard.RIGHT ? 1 : 0);
					var yDir:int = (e.keyCode == Keyboard.UP ? -1 : 0) + (e.keyCode == Keyboard.DOWN ? 1 : 0);
					var movePoint:Point = new Point(xDir * amount, yDir * amount);

					if (e.ctrlKey && e.shiftKey)
					{
						this.map.game.shift = this.map.game.shift.add(movePoint);
						break;
					}

					if (!e.shiftKey)
					{
						moveSelection(movePoint);
						break;
					}

					for each (object in this.selection) {
						indexInArray = this.map.gameObjects().indexOf(object);

						if (indexInArray > -1) {
							newIndex = indexInArray + yDir;
							if (newIndex > this.map.gameObjects().length) newIndex = this.map.gameObjects().length;
							if (newIndex < 0) newIndex = 0;

							var item0: * = this.map.gameObjects()[indexInArray];
							this.map.gameObjects().splice(indexInArray, 1);
							this.map.gameObjects().splice(newIndex, 0, item0);
							(item0 as StarlingAdapterSprite).lastIndex = this.map.gameObjects().indexOf(object);
							this.map.objectSprite.addChildStarlingAt((item0 as StarlingAdapterSprite), newIndex + 1);
						}
					}

					break;
				case Keyboard.A:
					if (!e.ctrlKey)
						break;

					clear();

					var objects:Array = this.map.get(Object, true);
					for each (object in objects)
						add(object);
					break;
				case Keyboard.O:
					for each (var gameObject:IGameObject in this.selection)
					{
						if (!(gameObject is GameBody))
							continue;
						(gameObject as GameBody).fixed = !(gameObject as GameBody).fixed;
					}
					break;
			}
		}

		private function copy():void
		{
			var result:Array = [];

			for each (var object:IGameObject in this.selection)
			{
				if (!(object is ISerialize))
					continue;

				result.push([EntityFactory.getId(object), (object as ISerialize).serialize()]);
			}

			clear();

			for each (var data:Array in result)
			{
				object = new (EntityFactory.getEntity(data[0]) as Class)();
				(object as ISerialize).deserialize(data[1]);
				this.map.add(object);

				add(object);
			}
		}

		private function drawRectangle():void {
			this.selectionRectangleSprite.graphics.clear();
			this.selectionRectangleSprite.graphics.beginFill(0xFCFFD6, 0.1);
			this.selectionRectangleSprite.graphics.lineStyle(1, 0xFFFF56);
			this.selectionRectangleSprite.graphics.drawRect(this.selectionRectangleStart.x, this.selectionRectangleStart.y, this.selectionRectangleEnd.x - this.selectionRectangleStart.x, this.selectionRectangleEnd.y - this.selectionRectangleStart.y);
			this.selectionRectangleSprite.graphics.lineStyle(0);
			this.selectionRectangleSprite.graphics.endFill();
		}

		private function isSelected(object:IGameObject):Boolean
		{
			return this.selection.indexOf(object) > -1;
		}

		private function onMouseMove(e: MouseEvent): void {
			if (!_mouseDown || !this.map || !this.map.objectSprite)
				return;

			var localPos:Point = this.map.objectSprite.globalToLocal(_globalPos);

			if (this.releaseButton && !this.mouseDownPoint && e.target == Game.stage) {
				this.selectionRectangleEnd = localPos;
				drawRectangle();
				return;
			}

			if (this.scaleBREnabled) {
				if (selection.length == 1 && this.selection[0] is ISizeable) {
					var scaleBRPos:Point = (this.selection[0] as StarlingAdapterSprite).globalToLocal(_globalPos);
					(this.selection[0] as ISizeable).size = new b2Vec2(scaleBRPos.x * 2 / Game.PIXELS_TO_METRE / this.gameEditor.scale, scaleBRPos.y * 2 / Game.PIXELS_TO_METRE / this.gameEditor.scale);

					this.scaleButtonBR.x = (this.selection[0] as ISizeable).size.x * Game.PIXELS_TO_METRE / 2 * this.gameEditor.scale;
					this.scaleButtonBR.y = (this.selection[0] as ISizeable).size.y * Game.PIXELS_TO_METRE / 2 * this.gameEditor.scale;
				}
				return;
			}

			if (this.scaleTLEnabled) {
				if (selection.length == 1 && this.selection[0] is ISizeable) {
					var scaleTLPos:Point = (this.selection[0] as StarlingAdapterSprite).globalToLocal(_globalPos);
					var oldCoords:Point = this.scaleSprite.localToGlobal(new Point(this.scaleButtonBR.x, this.scaleButtonBR.y));
					var size:Point = new Point(this.scaleButtonBR.x, this.scaleButtonBR.y).subtract(scaleTLPos);

					var oldSize:b2Vec2 = (this.selection[0] as ISizeable).size.Copy();
					(this.selection[0] as ISizeable).size = new b2Vec2(size.x * 2 / Game.PIXELS_TO_METRE / this.gameEditor.scale, size.y * 2 / Game.PIXELS_TO_METRE / this.gameEditor.scale);

					var diff:b2Vec2 = oldSize.Copy();
					diff.Subtract((this.selection[0] as ISizeable).size);
					if (diff.x == 0 && diff.y == 0)
						return;

					var position:Point = (this.selection[0] as StarlingAdapterSprite).parentStarling.globalToLocal(this.scaleSprite.localToGlobal(scaleTLPos));
					(this.selection[0] as StarlingAdapterSprite).x = position.x;
					(this.selection[0] as StarlingAdapterSprite).y = position.y;

					this.rotationPoint = this.selectionCenter;

					var newCoords:Point = this.scaleSprite.localToGlobal(new Point(this.scaleButtonBR.x, this.scaleButtonBR.y));
					scaleTLPos = oldCoords.subtract(newCoords);

					(this.selection[0] as StarlingAdapterSprite).x += scaleTLPos.x / this.gameEditor.scale;
					(this.selection[0] as StarlingAdapterSprite).y += scaleTLPos.y / this.gameEditor.scale;

					this.rotationPoint = this.selectionCenter;
				}
				return;
			}

			if (this.rotationEnabled)
			{
				this.rotationToolSprite.x = localPos.x;
				this.rotationToolSprite.y = localPos.y;

				var angle:Number = GeomUtil.getAngle(this.rotationPoint, new Point(localPos.x / this.gameEditor.scale, localPos.y / this.gameEditor.scale)) - 90;
				rotate(angle - prevAngle);
				this.prevAngle = angle;
				return;
			}

			if (this.bindButton.visible)
			{
				this.bindButton.x = this.selection[0].position.x * Game.PIXELS_TO_METRE * this.gameEditor.scale;
				this.bindButton.y = this.selection[0].position.y * Game.PIXELS_TO_METRE * this.gameEditor.scale;
			}

			if (this.mouseDownPoint == null)
				return;

			var point:Point = localPos.subtract(this.mouseDownPoint);

			if (this.scrollEnabled)
			{
				this.map.game.shift = this.map.game.shift.add(point);
				return;
			}

			this.mouseDownPoint = localPos;

			moveSelection(point);

			if (!selectionEnabled)
				return;

			this.selectionEnabled = false;
			this.selectionRectangleStart = localPos;
			this.selectionRectangleEnd = localPos;

			drawRectangle();
		}

		private function onMouseDown(e:MouseEvent):void
		{
			_mouseDown = true;

			var localPos:Point = this.map.objectSprite.globalToLocal(_globalPos);

			this.selectionEnabled = false;
			this.mouseDownPoint = null;
			this.releaseButton = false;
			this.scaleTLEnabled = false;
			this.scrollEnabled = false;
			this.rotationEnabled = false;
			this.scaleBREnabled = false;
			this.bindEnabled = false;

			if (e.ctrlKey && e.shiftKey || handButton)
			{
				this.mouseDownPoint = localPos;
				this.scrollEnabled = true;
				e.stopImmediatePropagation();
				return;
			} else {
				this.scrollEnabled = false;
			}

			if (e.target == this.rotationToolSprite)
			{
				this.rotationEnabled = true;
				this.gameEditor.saveStep();
				e.stopImmediatePropagation();
				return;
			}

			if (e.target == this.scaleButtonBR)
			{
				this.scaleBREnabled = true;
				this.gameEditor.saveStep();
				e.stopImmediatePropagation();
				return;
			}

			if (e.target == this.scaleButtonTL)
			{
				this.scaleTLEnabled = true;
				this.gameEditor.saveStep();
				e.stopImmediatePropagation();
				return;
			}

			if (e.target == this.bindButton)
			{
				this.bindEnabled = true;
				e.stopImmediatePropagation();
				(this.selection[0] as BindPoint).bindWith(this.selection.slice(1));
				for (var i:int = 1; i < this.selection.length; i++)
				{
					(this.selection[i] as BindPoint).bindWith(this.selection.slice(0, i).concat(this.selection.slice(i + 1)));
				}
			}

			if (isSelected(e.currentTarget as IGameObject) || e.target == this.rotationPointSprite)
			{
				e.stopImmediatePropagation();

				if (e.shiftKey)
				{
					remove(e.currentTarget as IGameObject);
					this.selectionEnabled = false;
					return;
				}

				this.dragObject = true;
				this.gameEditor.saveStep();
				this.selectionEnabled = false;
				this.mouseDownPoint = localPos;

				return;
			}

			if (e.target == this.gameEditor.scaleBar)
			{
				var lineSprite:Sprite = new Sprite();
				lineSprite.graphics.lineStyle(4, 0xFFFFFF);
				addChild(lineSprite);
				if (e.stageY > 49)
				{
					lineSprite.graphics.moveTo(0, 0);
					lineSprite.graphics.lineTo(0, Config.GAME_HEIGHT);
				}
				else
				{
					lineSprite.graphics.moveTo(0, 0);
					lineSprite.graphics.lineTo(Config.GAME_WIDTH, 0);
				}
				this.gameEditor.lines.push(lineSprite);
				this.gameEditor.lines[this.gameEditor.lines.length - 1].addEventListener(MouseEvent.MOUSE_DOWN, this.gameEditor.onMouseDown);
				this.gameEditor.lines[this.gameEditor.lines.length - 1].addEventListener(MouseEvent.MOUSE_UP, this.gameEditor.onMouseUp);
				this.gameEditor.scaleBar.addChild(this.gameEditor.lines[this.gameEditor.lines.length - 1]);

				if (e.stageY > 49)
					this.gameEditor.lines[this.gameEditor.lines.length - 1].x = e.stageX;
				else
					this.gameEditor.lines[this.gameEditor.lines.length - 1].y = e.stageY - this.gameEditor.scaleBar.y;

				this.gameEditor.dragLine = true;
				return;
			}

			if (e.target == Game.stage)
			{
				lastSelectObject = this.map.checkSelectObject(_localPos);
			}
			else
			{
				lastSelectObject = null;
			}

			if (lastSelectObject) {
				this.selectionEnabled = true;
				this.mouseDownPoint = localPos;
			}

			this.selectionRectangleStart = localPos;
			this.selectionRectangleEnd = localPos;
			this.releaseButton = !this.selectionEnabled;

			drawRectangle();
		}

		public function resetMovable(): void {
			this.mouseDownPoint = null;
		}

		private function onMouseUp(e: MouseEvent):void {
			_mouseDown = false;
			trace(e.target, selectionRectangleSprite == e.target);
			if (Game.stage != e.target && selectionRectangleSprite != e.target)
				return;

			this.mouseDownPoint = null;
			this.releaseButton = true;
			this.rotationEnabled = false;
			this.scaleTLEnabled = false;
			this.scaleBREnabled = false;

			if (this.visible && !this.map.getVisibleInspector())
			{
				var selected:Array = this.map.get(IGameObject, true);

				if (!e.ctrlKey && !e.shiftKey)
					clear();

				if (this.selectionRectangleSprite.width < 10 && this.selectionRectangleSprite.height < 10)
				{
					if (lastSelectObject && lastSelectObject is IGameObject) {
						if (e.shiftKey) {
							remove(lastSelectObject as IGameObject);
						} else {
							add(lastSelectObject as IGameObject);
						}
					}

					lastSelectObject = null;
					return;
				} else {
					for each (var object:IGameObject in selected){

						if (!(object is IStarlingAdapter))
							continue;

						if (!testSelection(object as StarlingAdapterSprite, selectionRectangleSprite))
							continue;

						if (e.shiftKey)
							remove(object);
						else
							add(object);
					}
				}
			}

			if (this.rotationEnabled)
			{
				for (var rotObject:* in this.rotators)
				{
					if (rotObject is ILimitedAngles)
						(rotObject as IStarlingAdapter).rotation = (rotObject as ILimitedAngles).checkAngle((rotObject as IStarlingAdapter).rotation);
				}
			}

			this.mouseDownPoint = null;
			this.rotationEnabled = false;
			this.selectionEnabled = false;
			this.scaleBREnabled = false;
			this.scaleTLEnabled = false;
			this.bindEnabled = false;
			this.scrollEnabled = false;
			this.dragObject = false;
			this.gameEditor.dragLine = false;
			this.selectionRectangleStart = new Point();
			this.selectionRectangleEnd = new Point();

			drawRectangle();
		}

		private function testSelection(obj:*, selectionRect:DisplayObject):Boolean {
			var rct: Rectangle = selectionRect.getRect(Game.stage);
			var objRect: Rectangle =  StarlingAdapterSprite(obj).boundsStarling();
			if (selectionRect) {}

			return (objRect.left + this.map.x >= rct.left - Game.gameSprite.x &&
				objRect.right + this.map.x <= rct.right - Game.gameSprite.x &&
				objRect.top + this.map.y >= rct.top - Game.gameSprite.y &&
				objRect.bottom + this.map.y <= rct.bottom - Game.gameSprite.y);
		}

		private function moveSelection(delta:Point):void
		{
			for each (var object:* in this.selection)
			{
				object.x += delta.x / this.gameEditor.scale;
				object.y += delta.y / this.gameEditor.scale;
			}
			this.rotationPoint = this.selectionCenter;
		}

		private function updateScaleButton():void
		{
			this.scaleButtonBR.visible = this.scaleButtonTL.visible = (this.selection.length == 1 && this.selection[0] is ISizeable);
			if (!this.scaleButtonBR.visible)
				return;

			var scalePos:b2Vec2 = (this.selection[0] as ISizeable).size.Copy();
			scalePos.Multiply(0.5);
			scalePos.Multiply(Game.PIXELS_TO_METRE);
			this.scaleButtonBR.x = scalePos.x * this.gameEditor.scale;
			this.scaleButtonBR.y = scalePos.y * this.gameEditor.scale;

			this.scaleButtonTL.x = -this.scaleButtonTL.width;
			this.scaleButtonTL.y = -this.scaleButtonTL.height;

			this.scaleSprite.x = this.selection[0].position.x * Game.PIXELS_TO_METRE * this.gameEditor.scale;
			this.scaleSprite.y = this.selection[0].position.y * Game.PIXELS_TO_METRE * this.gameEditor.scale;

			this.scaleSprite.rotation = this.selection[0].angle / (Game.D2R);
		}

		private function updateBindButton():void
		{
			this.bindButton.visible = false;
			var isPoints:Boolean = true;

			if (this.selection.length < 2)
				return;

			for each (var object:DisplayObject in this.selection)
			{
				if (!(object is FlyWayPoint))
				{
					isPoints = false;
					break;
				}
			}

			var withBody:Boolean = (this.selection.length == 2) && ((this.selection[0] is GameBody && this.selection[1] is FlyWayPoint) || (this.selection[1] is GameBody && this.selection[0] is FlyWayPoint));

			if (!isPoints && !withBody)
				return;

			this.bindButton.visible = true;
			this.bindButton.x = this.selection[0].position.x * Game.PIXELS_TO_METRE * this.gameEditor.scale;
			this.bindButton.y = this.selection[0].position.y * Game.PIXELS_TO_METRE * this.gameEditor.scale;
		}
	}
}