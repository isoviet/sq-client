package game.mainGame.entity.editor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Mat22;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.GameMap;
	import game.mainGame.ILags;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.controllers.ExtGravityController;
	import game.mainGame.entity.joints.IJoint;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.gameEditor.Selection;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class RectGravity extends StarlingAdapterSprite implements IGameObject, ISerialize, IJoint, IDispose, ISizeable, IUpdate, IComplexEditorObject, ILags
	{
		static private const COLOR:int = 0xDBFAFF;

		private var controller:ExtGravityController;

		private var _direction:b2Vec2 = new b2Vec2();
		private var _velocity:Number = -100;

		private var _inSize:b2Vec2 = new b2Vec2(10, 10);
		private var _outSize:b2Vec2 = new b2Vec2(20, 20);
		private var _disableGravity:Boolean = true;
		private var _affectHero:Boolean = true;
		private var _affectObject:Boolean = true;
		private var _extGravity:Boolean = true;
		private var tmpPlatformName:String = "";

		private var diagonal: Number = 0;

		private var _parentPlanform:PlatformGroundBody;

		private var serializePosition:b2Vec2 = null;

		private var shapeMeasure:b2Vec2 = new b2Vec2(0, 0);
		private var directionShape:StarlingAdapterSprite = new StarlingAdapterSprite();
		private var maskShape:StarlingAdapterSprite = new StarlingAdapterSprite();
		private var mainShape:StarlingAdapterSprite = new StarlingAdapterSprite();

		private var directionStep:b2Vec2 = new b2Vec2();

		public var body:GameBody;

		private var defWidth: Number = 0;
		private var defHeight: Number = 0;
		private var lastSizeX: int = 0;
		private var lastSizeY: int = 0;
		private var circleImage:BitmapData = new GravityCircle();
		private var circle:Bitmap = new Bitmap(circleImage);

		public function RectGravity():void
		{
			super();

			defWidth = circle.width;
			defHeight = circle.height;

			addChildStarling(this.mainShape);
			addChildStarling(this.directionShape);
			addChildStarling(this.maskShape);
			redraw();
			this.touchable = false;
		}

		public function init():void
		{
			Game.stage.addEventListener(MouseEvent.CLICK, onMouseClick);

			this.mouseEnabled = false;
			this.mouseChildren = false;
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
		}

		public function get angle():Number
		{
			return this.rotation * Game.D2R;
		}

		public function set angle(value:Number):void
		{
			this.rotation = value * Game.R2D;
		}

		public function build(world:b2World):void
		{
			this.controller = new ExtGravityController();
			this.controller.body = this;
			world.AddController(this.controller);

			updateController();
		}

		public function serialize():*
		{
			var result:Array = [
				(this.serializePosition ? [this.serializePosition.x, this.serializePosition.y] : [this.position.x, this.position.y]),
				this.angle, this.velocity,
				[this.direction.x, this.direction.y],
				[this.size.x, this.size.y],
				[this.outSize.x, this.outSize.y],
				disableGravity,
				affectHero,
				affectObject,
				extGravity,
				(parentPlatform ? parentPlatform.name : this.tmpPlatformName)
			];

			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.angle = data[1];
			this.velocity = data[2];
			this.direction = new b2Vec2(data[3][0], data[3][1]);
			this.size = new b2Vec2(data[4][0], data[4][1]);
			this.outSize = new b2Vec2(data[5][0], data[5][1]);
			this.disableGravity = Boolean(data[6]);
			this.affectHero = Boolean(data[7]);
			this.affectObject = Boolean(data[8]);
			this.extGravity = Boolean(data[9]);

			if (!(10 in data))
				return;

			this.tmpPlatformName = data[10];
		}

		public function dispose():void
		{
			if (this.parentStarling)
				this.parentStarling.removeChildStarling(this);

			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			if (this.controller)
				this.controller.dispose();

			this.parentPlatform = null;

			this.body = null;
			this.controller = null;
		}

		public function update(timeStep:Number = 0):void
		{
			/*var width: Number = 0;
			var height: Number = 0;
			width = this.directionShape.scaleX * defWidth;
			height = this.directionShape.scaleY * defHeight;

			if (timeStep != 0)
			{
				if (this.direction.Length() == 0)
				{
					if (width < 5)
					{
						width = this.shapeMeasure.x;
						height = this.shapeMeasure.y;
					}
					else if (width > this.shapeMeasure.x)
					{
						width = 10;
						height = this.shapeMeasure.y * (10 / this.shapeMeasure.x);
					}

					width += (2 * this.velocity / 50);
					height = this.shapeMeasure.y * (width / this.shapeMeasure.x);

					//this.directionShape.scaleX = width / defWidth;
					//this.directionShape.scaleY = height / defHeight;

				}
				else
				{
					if (this.directionShape.x >= this.shapeMeasure.x && this.directionShape.y >= this.shapeMeasure.y)
					{
						this.directionShape.x = -this.shapeMeasure.x;
						this.directionShape.y = -this.shapeMeasure.y;
					}
					else if (this.directionShape.x <= -this.shapeMeasure.x && this.directionShape.y >= this.shapeMeasure.y)
					{
						this.directionShape.x = this.shapeMeasure.x;
						this.directionShape.y = -this.shapeMeasure.y;
					}
					else if (this.directionShape.x <= -this.shapeMeasure.x && this.directionShape.y <= -this.shapeMeasure.y)
					{
						this.directionShape.x = this.shapeMeasure.x;
						this.directionShape.y = this.shapeMeasure.y;
					}
					else if (this.directionShape.x >= this.shapeMeasure.x && this.directionShape.y <= -this.shapeMeasure.y)
					{
						this.directionShape.x = -this.shapeMeasure.x;
						this.directionShape.y = this.shapeMeasure.y;
					}

					this.directionShape.x += this.directionStep.x;
					this.directionShape.y += this.directionStep.y;
				}
			}
			this.directionShape.alignPivot();*/
			 if (!this.parentPlatform || !this.parentPlatform.parentStarling)
			{
				this.parentPlatform = null;
				return;
			}

			var pos:b2Vec2 = this.parentPlatform.position.Copy();
			var size:b2Vec2 = this.parentPlatform.size.Copy();
			size.Multiply(0.5);
			this.size = size.Copy();
			var m:b2Mat22 = new b2Mat22();
			this.angle = this.parentPlatform.angle;
			m.Set(this.angle);
			size.MulM(m);
			size.Multiply(0.5);
			pos.Add(size);

			this.serializePosition = this.parentPlatform.position;

			this.position = pos;
		}

		public function onAddedToMap(map:GameMap):void
		{
			if (this.tmpPlatformName == "")
				return;

			setTimeout(setPlatform, 0, map);
		}

		public function onRemovedFromMap(map:GameMap):void
		{}

		public function onSelect(selection:Selection):void
		{}

		public function get size():b2Vec2
		{
			return _inSize;
		}

		public function set size(value:b2Vec2):void
		{
			value.x = Math.abs(value.x);
			value.y = Math.abs(value.y);

			if (_inSize.x == value.x && _inSize.y == value.y)
				return;

			_inSize = value;
			updateController();
			redraw();
		}

		public function get direction():b2Vec2
		{
			return _direction;
		}

		public function set direction(value:b2Vec2):void
		{
			_direction = value;
			updateController();
			redraw();
		}

		public function get velocity():Number
		{
			return _velocity;
		}

		public function set velocity(value:Number):void
		{
			_velocity = value;
			updateController();
		}

		public function get outSize():b2Vec2
		{
			return _outSize;
		}

		public function set outSize(value:b2Vec2):void
		{
			_outSize = value;
			updateController();
			redraw();
		}

		public function get disableGravity():Boolean
		{
			return _disableGravity;
		}

		public function set disableGravity(value:Boolean):void
		{
			_disableGravity = value;
			updateController();
		}

		public function get affectHero():Boolean
		{
			return _affectHero;
		}

		public function set affectHero(value:Boolean):void
		{
			_affectHero = value;
			updateController();
		}

		public function get affectObject():Boolean
		{
			return _affectObject;
		}

		public function set affectObject(value:Boolean):void
		{
			_affectObject = value;
			updateController();
		}

		public function get extGravity():Boolean
		{
			return _extGravity;
		}

		public function set extGravity(value:Boolean):void
		{
			_extGravity = value;
			updateController();
		}

		public function get parentPlatform():PlatformGroundBody
		{
			return _parentPlanform;
		}

		public function set parentPlatform(value:PlatformGroundBody):void
		{
			_parentPlanform = value;
			if (value == null)
				Game.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			else
				Game.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//redraw();
		}

		public function estimateLags():Number
		{
			return 0.5 * int(this.affectObject);
		}

		private function setPlatform(map:GameMap):void
		{
			var object:IGameObject = map.getByName(this.tmpPlatformName);

			if (object is PlatformGroundBody)
				this.parentPlatform = (object as PlatformGroundBody);

			tmpPlatformName = "";
		}

		private function updateController():void
		{
			if (!this.controller)
				return;

			this.controller.G = this.velocity;
			this.controller.inSize = this.size;
			this.controller.outSize = b2Math.AddVV(this.outSize, this.size);
			this.controller.direction = this.direction;
			this.controller.posOffset = new b2Vec2();
			this.controller.disableGlobalGravity = this.disableGravity;
			this.controller.addExtGrav = this.extGravity;
			this.controller.affectHero = this.affectHero;
			this.controller.affectObjects = this.affectObject;
		}

		private function redraw():void
		{
			if (this.direction.Length() != 0 && lastSizeX == this.outSize.x + this.size.x &&
				lastSizeY == this.outSize.y + this.size.y) {
				return;
			}

			lastSizeX = this.outSize.x + this.size.x;
			lastSizeY = this.outSize.y + this.size.y;

			while (this.directionShape.numChildren > 0)
				this.directionShape.removeChildStarlingAt(0);

			while (this.mainShape.numChildren > 0)
				this.mainShape.removeChildStarlingAt(0);

			if (this.direction.Length() == 0)
			{
				this.shapeMeasure.x = (this.outSize.x + this.size.x) * Game.PIXELS_TO_METRE;
				this.shapeMeasure.y = (this.outSize.y + this.size.y) * Game.PIXELS_TO_METRE;

				if (this.shapeMeasure.x / defWidth < 2000)
				{
					circle.scaleX = this.shapeMeasure.x / defWidth;
					circle.scaleY = this.shapeMeasure.y / defHeight;
				}

				this.directionShape.addChildStarling(new StarlingAdapterSprite(circle));
				this.directionShape.alignPivot();
			}
			else
			{
				this.diagonal = Math.sqrt(Math.pow((this.outSize.x + this.size.x) * Game.PIXELS_TO_METRE, 2) + Math.pow((this.outSize.y + this.size.y) * Game.PIXELS_TO_METRE, 2));
				var angle:Number = Math.atan2(this.direction.y, this.direction.x) - this.angle;
				this.shapeMeasure.x = int(Math.cos(angle) * (this.diagonal / 2));
				this.shapeMeasure.y = int(Math.sin(angle) * (this.diagonal / 2));

				defWidth = this.directionShape.width;
				defHeight = this.directionShape.height;
				this.directionShape.alignPivot();

				this.shapeMeasure.x = Math.abs(this.shapeMeasure.x);
				this.shapeMeasure.y = Math.abs(this.shapeMeasure.y);

				this.directionStep.Set(int(Math.cos(angle) * this.velocity / 50), int(Math.sin(angle) * this.velocity / 50));
			}

			var m:Matrix = new Matrix();
			var mainGraph: Shape = new Shape();

			m.createGradientBox((this.outSize.x + this.size.x) * Game.PIXELS_TO_METRE, (this.outSize.y + this.size.y) * Game.PIXELS_TO_METRE, 0, (-this.outSize.x - this.size.x) * Game.PIXELS_TO_METRE / 2, (-this.outSize.y - this.size.y) * Game.PIXELS_TO_METRE / 2);
			mainGraph.graphics.beginGradientFill(this.direction.Length() == 0 ? GradientType.RADIAL : GradientType.LINEAR, [COLOR, COLOR, COLOR, COLOR], [0, 0.1, 0.5, 0], [0, this.direction.Length() == 0 ? 222 : 50, 250, 255], m, SpreadMethod.PAD, InterpolationMethod.RGB, 0);

			if (this.direction.Length() == 0)
			{
				mainGraph.graphics.drawEllipse((-this.outSize.x - this.size.x) * Game.PIXELS_TO_METRE / 2, (-this.outSize.y - this.size.y) * Game.PIXELS_TO_METRE / 2, (this.outSize.x + this.size.x) * Game.PIXELS_TO_METRE, (this.outSize.y + this.size.y) * Game.PIXELS_TO_METRE);
			}
			else
			{
				mainGraph.graphics.drawRect((-this.outSize.x - this.size.x) * Game.PIXELS_TO_METRE / 2, (-this.outSize.y - this.size.y) * Game.PIXELS_TO_METRE / 2, (this.outSize.x + this.size.x) * Game.PIXELS_TO_METRE, (this.outSize.y + this.size.y) * Game.PIXELS_TO_METRE);
			}

			mainShape.addChildStarling(new StarlingAdapterSprite(mainGraph));

			if (this.direction.x != 0 || this.direction.y != 0 || this.parentPlatform != null)
				return;

			while (this.mainShape.numChildren > 0)
				this.mainShape.removeChildStarlingAt(0);

			mainGraph.graphics.beginFill(0xFFFFFF, 0.1);
			mainGraph.graphics.drawRect(-this.size.x * Game.PIXELS_TO_METRE / 2, -this.size.y * Game.PIXELS_TO_METRE / 2, this.size.x * Game.PIXELS_TO_METRE, this.size.y * Game.PIXELS_TO_METRE);
			mainShape.addChildStarling(new StarlingAdapterSprite(mainGraph));
		}

		private function onMouseClick(e:MouseEvent):void
		{
			if (e.target && e.target is Sprite && (e.target as StarlingAdapterSprite).parentStarling is PlatformGroundBody)
			{
				this.parentPlatform = ((e.target as StarlingAdapterSprite).parentStarling as PlatformGroundBody);
				this.parent.swapChildren(this.parentPlatform, this);
			}

			this.mouseChildren = true;
			this.mouseEnabled = true;

			Game.stage.removeEventListener(MouseEvent.CLICK, onMouseClick);
			update();
		}

		private function onEnterFrame(e:Event):void
		{
			update();
		}
	}
}