package landing.game.mainGame.gameEditor
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	import Box2D.Common.Math.b2Vec2;

	import landing.game.mainGame.GameMap;
	import landing.game.mainGame.ISerialize;
	import landing.game.mainGame.entity.EntityFactory;
	import landing.game.mainGame.entity.IComplexEditorObject;
	import landing.game.mainGame.entity.IGameObject;
	import landing.game.mainGame.entity.ISizeable;
	import landing.game.mainGame.entity.simple.GameBody;

	import utils.GeomUtil;
	import utils.IndexUtil;
	import utils.Rotator;

	public class Selection extends Sprite
	{
		private var selection:Vector.<IGameObject> = new Vector.<IGameObject>();
		private var map:GameMap;
		private var mouseDownPoint:Point = null;
		private var dragObject:Boolean = false;

		private var rotators:Dictionary = new Dictionary(true);
		private var _rotationPoint:Point = new Point();
		private var rotationPointSprite:Sprite = new SelectionCenter();

		private var rotationEnabled:Boolean;
		private var prevAngle:Number;
		private var rotationToolSprite:DisplayObject = new RotateButton();

		private var scaleSprite:Sprite = new Sprite();
		private var scaleButton:ScaleButton = new ScaleButton();
		private var scaleEnabled:Boolean = false;

		private var selectionEnabled:Boolean = false;
		private var selectionRectangleSprite:Sprite = new Sprite();
		private var selectionRectangleStart:Point = new Point();
		private var selectionRectangleEnd:Point = new Point();

		public function Selection(map:GameMap):void
		{
			this.map = map;

			addChild(this.rotationPointSprite);
			addChild(this.rotationToolSprite);

			updateScaleButton();

			this.scaleSprite.addChild(this.scaleButton);
			addChild(this.scaleSprite);

			drawRectangle();

			addChild(this.selectionRectangleSprite);

			this.rotationPoint = selectionCenter;

			WallShadow.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			WallShadow.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			WallShadow.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			WallShadow.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		}

		public function dispose():void
		{
			clear();

			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			WallShadow.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			WallShadow.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			this.map = null;
			this.selection = null;
			this.rotators = null;
			this.rotationToolSprite = null;
			this.rotationPointSprite = null;
			this.selectionRectangleSprite = null;
			this.scaleButton = null;
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.D:
					if (!e.ctrlKey)
						break;

					copy();
					break;
				case Keyboard.Z:
					for each (var object:IGameObject in selection)
					{
						if (object is GameBody)
							(object as GameBody).ghost = !(object as GameBody).ghost;
					}
					break;
					break;
				case Keyboard.DOWN:
				case Keyboard.UP:
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					var amount:Number = (e.ctrlKey ? 10 : 1);
					var xDir:int = (e.keyCode == Keyboard.LEFT ? -1 : 0) + (e.keyCode == Keyboard.RIGHT ? 1 : 0);
					var yDir:int = (e.keyCode == Keyboard.UP ? -1 : 0) + (e.keyCode == Keyboard.DOWN ? 1 : 0);
					var movePoint:Point = new Point(xDir * amount, yDir * amount);

					if (!e.shiftKey)
					{
						moveSelection(movePoint);
						break;
					}

					var result:Array = new Array();
					for each (object in selection)
						result.push(object);

					IndexUtil.shiftMany(result, yDir);
					break;
				case Keyboard.A:
					if (!e.ctrlKey)
						break;

					clear();

					for each (object in this.map.get(Object))
						add(object);
					break;
			}
		}

		private function copy():void
		{
			var result:Array = new Array();

			for each (var object:IGameObject in this.selection)
			{
				if (object is ISerialize)
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

		public function deleteSelected():void
		{
			while (this.selection.length > 0)
			{
				var object:IGameObject = selection[0];
				remove(object);
				this.map.remove(object);
			}
		}

		public function get rotationPoint():Point
		{
			return this._rotationPoint;
		}

		private function drawRectangle():void
		{
			this.selectionRectangleSprite.graphics.clear();
			this.selectionRectangleSprite.graphics.beginFill(0xFCFFD6, 0.1);
			this.selectionRectangleSprite.graphics.lineStyle(1, 0xFFFF56);
			this.selectionRectangleSprite.graphics.drawRect(this.selectionRectangleStart.x, this.selectionRectangleStart.y, this.selectionRectangleEnd.x - this.selectionRectangleStart.x, this.selectionRectangleEnd.y - this.selectionRectangleStart.y);
			this.selectionRectangleSprite.graphics.lineStyle(0);
			this.selectionRectangleSprite.graphics.endFill();
		}

		public function set rotationPoint(value:Point):void
		{
			this._rotationPoint = value;
			for each (var rotator:Rotator in this.rotators)
				rotator.setRegistrationPoint(value);

			this.rotationPointSprite.x = int(value.x);
			this.rotationPointSprite.y = int(value.y);
			this.rotationPointSprite.visible = this.selection.length > 0;

			this.rotationToolSprite.x = value.x + 100;
			this.rotationToolSprite.y = value.y;
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

		public function rotate(angle:Number):void
		{
			for each (var rotator:Rotator in this.rotators)
				rotator.rotation += angle;
			updateScaleButton();
		}

		public function add(object:IGameObject, clearBefore:Boolean = false):void
		{
			if (!object)
				return;

			if (this.selection.indexOf(object) != -1)
				return;

			if (clearBefore)
				clear();

			this.selection.push(object);

			if (object is DisplayObject)
			{
				this.rotators[object] = new Rotator(object);
				this.rotationPoint = selectionCenter;
				(object as DisplayObject).filters = [new GlowFilter(0xFFFFFF, 1, 10, 10, 5)];
			}

			if (object is IComplexEditorObject)
				(object as IComplexEditorObject).onSelect(this);

			updateScaleButton();

			if (!(object is Sprite))
				return;

			this.selectionEnabled = false;
			(object as EventDispatcher).addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		public function clear():void
		{
			while (this.selection.length > 0)
				remove(selection[0]);
		}

		public function remove(object:IGameObject):void
		{
			if (!object)
				return;
			if (this.selection.indexOf(object) == -1)
				return;

			if (object is DisplayObject)
			{
				(object as DisplayObject).filters = [];
				delete this.rotators[object];
			}

			(object as EventDispatcher).removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.selection.splice(selection.indexOf(object), 1);
			this.rotationPoint = selectionCenter;
			updateScaleButton();
		}

		private function isSelected(object:IGameObject):Boolean
		{
			return this.selection.indexOf(object) > -1;
		}

		private function onMouseMove(e:MouseEvent):void
		{
			if (this.selectionEnabled && e.buttonDown)
			{
				this.selectionRectangleEnd = new Point(e.stageX, e.stageY);
				drawRectangle();
			}

			if (this.scaleEnabled && e.buttonDown)
			{
				var scalePos:Point = this.scaleSprite.globalToLocal(new Point(e.stageX, e.stageY));

				if (selection.length == 1 && selection[0] is ISizeable)
				{
					(this.selection[0] as ISizeable).size = new b2Vec2(scalePos.x * 2 / WallShadow.PIXELS_TO_METRE, scalePos.y * 2 / WallShadow.PIXELS_TO_METRE);
					this.scaleButton.x = (this.selection[0] as ISizeable).size.x * WallShadow.PIXELS_TO_METRE / 2;
					this.scaleButton.y = (this.selection[0] as ISizeable).size.y * WallShadow.PIXELS_TO_METRE / 2;
				}
				return;
			}

			if (this.rotationEnabled && e.buttonDown)
			{
				this.rotationToolSprite.x = e.stageX;
				this.rotationToolSprite.y = e.stageY;

				var angle:Number = GeomUtil.getAngle(this.rotationPoint, new Point(e.stageX, e.stageY)) - 90;
				rotate(angle - prevAngle);
				this.prevAngle = angle;
				return;
			}

			if (!e.buttonDown || this.mouseDownPoint == null)
				return;

			var point:Point = new Point(e.stageX, e.stageY).subtract(this.mouseDownPoint);
			this.mouseDownPoint = new Point(e.stageX, e.stageY);
			moveSelection(point);

			if (!selectionEnabled)
				return;

			this.selectionEnabled = false;
			this.selectionRectangleStart = new Point(e.stageX, e.stageY);
			this.selectionRectangleEnd = new Point(e.stageX, e.stageY);

			drawRectangle();
		}

		private function onMouseDown(e:MouseEvent):void
		{
			if (e.target == this.rotationToolSprite)
			{
				this.rotationEnabled = true;
				e.stopImmediatePropagation();
				return;
			}

			if (e.target == this.scaleButton)
			{
				this.scaleEnabled = true;
				e.stopImmediatePropagation();
				return;
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
				this.selectionEnabled = false;
				this.mouseDownPoint = new Point(e.stageX, e.stageY);
				return;
			}

			this.selectionEnabled = this.map.contains(e.target as DisplayObject);
			this.selectionRectangleStart = new Point(e.stageX, e.stageY);
			this.selectionRectangleEnd = new Point(e.stageX, e.stageY);

			drawRectangle();
		}

		private function onMouseUp(e:MouseEvent = null):void
		{
			if (this.selectionEnabled && this.visible)
			{
				var selected:Array = this.map.get(IGameObject);

				if (!e.ctrlKey && !e.shiftKey)
					clear();
				if (this.selectionRectangleSprite.width == 1 && this.selectionRectangleSprite.height == 1)
				{
					var i:int = this.map.objectSprite.numChildren - 1;
					while (i >= 0)
					{
						var mapChild:DisplayObject = this.map.objectSprite.getChildAt(i--);
						if (!mapChild.hitTestPoint(e.stageX, e.stageY, true))
							continue;
						if (!(mapChild is IGameObject))
							continue;
						if (!mapChild.hitTestObject(this.selectionRectangleSprite))
							continue;

						if (e.shiftKey)
							remove(mapChild as IGameObject);
						else
							add(mapChild as IGameObject);
						return;
					}
					return;
				}

				for each (var object:IGameObject in selected)
				{
					if (!(object is Sprite))
						continue;
					if (!(object as Sprite).hitTestObject(this.selectionRectangleSprite))
						continue;

					if (e.shiftKey)
						remove(object);
					else
						add(object);
				}
			}

			this.mouseDownPoint = null;
			this.rotationEnabled = false;
			this.selectionEnabled = false;
			this.scaleEnabled = false;
			this.dragObject = false;
			this.selectionRectangleStart = new Point();
			this.selectionRectangleEnd = new Point();

			drawRectangle();
		}

		private function moveSelection(delta:Point):void
		{
			for each (var object:DisplayObject in this.selection)
			{
				object.x += delta.x;
				object.y += delta.y;
			}
			this.rotationPoint = this.selectionCenter;
		}

		private function updateScaleButton():void
		{
			this.scaleButton.visible = (selection.length == 1 && selection[0] is ISizeable);
			if (!this.scaleButton.visible)
				return;
			var scalePos:b2Vec2 = (selection[0] as ISizeable).size.Copy();
			scalePos.Multiply(0.5);
			scalePos.Multiply(WallShadow.PIXELS_TO_METRE);
			this.scaleButton.x = scalePos.x;
			this.scaleButton.y = scalePos.y;

			this.scaleSprite.x = selection[0].position.x * WallShadow.PIXELS_TO_METRE;
			this.scaleSprite.y = selection[0].position.y * WallShadow.PIXELS_TO_METRE;

			this.scaleSprite.rotation = this.selection[0].angle / (Math.PI / 180);
		}
	}
}