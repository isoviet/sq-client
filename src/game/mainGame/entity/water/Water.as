package game.mainGame.entity.water
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.IForegroundObject;
	import game.mainGame.ILags;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.ILandSound;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.simple.Hydrant;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class Water extends StarlingAdapterSprite implements IForegroundObject, IGameObject, ISerialize, ISizeable, IUpdate, IDispose, ILags, ILandSound
	{
		static public var bubbles:BitmapData;

		private var _particlesCount:int;

		private var particles:Vector.<WaterParticle>;
		private var defaultVolume:Number;
		//private var gravity:Number = 10;
		private var affectIndex:int;
		//private var textureOffset:b2Vec2 = new b2Vec2(0, 0);
		private var starlingWater: StarlingAdapterSprite;
		private var waveStep:Number = 0;

		private var _color0:int = 0x80CAFF;
		private var _color1:int = 0x0087FF;
		private var _color2:int = 0x0350D6;
		private var _waveEnabled:Boolean = false;

		protected var game:SquirrelGame = null;

		protected var _alpha0:Number = 0.41;
		protected var _alpha1:Number = 0.41;
		protected var _alpha2:Number = 0.41;

		protected var _size:b2Vec2;

		protected var controller:WaterController;
		protected var renderSprite:StarlingAdapterSprite;

		public var bubblesVector:Vector.<BubbleData> = new Vector.<BubbleData>();
		public var waveAmplitude:Number = 0;
		public var waveLength:Number = 0;
		public var velocity:b2Vec2 = new b2Vec2();
		public var allowSwim:Boolean = true;
		public var bubblingFactor:Number = 0;
		public var hydrantId:int = -1;

		public function Water():void
		{
			if (!bubbles)
			{
				bubbles = new BitmapData(15, 15, true, 0x00FFFFFF);
				bubbles.draw(new Bubble());
			}

			this._size = new b2Vec2(300, 300);
			this.affectIndex = 1;
			this.particlesCount = 6;
			//this.touchable = false;
		}

		public function get landSound():String
		{
			return "water";
		}

		override public function get rotation():Number
		{
			return super.rotation;
		}

		override public function set rotation(value:Number):void
		{
			if (value) {/*unused*/}
			super.rotation = 0;
		}

		override public function get graphics():flash.display.Graphics
		{
			return this.renderSprite ? this.renderSprite.graphics : super.graphics;
		}

		public function applyVelocity(pos:b2Vec2, vel:b2Vec2):void
		{
			var particle:WaterParticle = getByPos(pos.x * Game.PIXELS_TO_METRE);
			var velocity:Number = vel.y * Game.PIXELS_TO_METRE / 5;

			if (particle && particle.velocity < velocity)
				particle.velocity += vel.y * Game.PIXELS_TO_METRE / 5;
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
			return 0;
		}

		public function set angle(value:Number):void
		{
			this.rotation = 0;
		}

		public function build(world:b2World):void
		{
			this.controller = new WaterController(this);
			world.AddController(this.controller);
			this.graphics.clear();
			this.game = (world.userData as SquirrelGame);

			if (this.hydrantId == -1)
				return;

			var hydrant:Hydrant = (this.game.map.getObject(this.hydrantId) as Hydrant);
			if (hydrant)
				hydrant.waterId = this.game.map.getID(this);
		}

		public function getSurfaceData(posX:Number, posY:Number):Array
		{
			if (posY * Game.PIXELS_TO_METRE > this.y)
				return [null, null, false];

			var baseIndex:int = getIndex(posX * Game.PIXELS_TO_METRE);
			switch (baseIndex)
			{
				case -1:
					return [null, null, false];
				case int.MAX_VALUE:
					return [null, null, false];
			}

			var line:Line = Line.fromPoints(getPos(baseIndex), getPos(baseIndex + 1));
			var normal:b2Vec2 = line.normal;
			normal.Normalize();
			return [normal, -line.offset / Game.PIXELS_TO_METRE, true];
		}

		public function update(timeStep:Number = 0):void
		{
			if (this.controller)
			{
				this.controller.velocity = this.velocity;
				this.controller.skipStep = false;
			}
		}

		public function serialize():*
		{
			return [[this.position.x, this.position.y], 0, [this.size.x, this.size.y], this.waveAmplitude, this.waveLength, this.waveStep, this.particlesCount, this.allowSwim, [this.velocity.x, this.velocity.y], this.bubblingFactor, this.waveEnabled, [this.color0, this.color1, this.color2], this.hydrantId];
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.size = new b2Vec2(data[2][0], data[2][1]);
			this.waveAmplitude = data[3];
			this.waveLength = data[4];
			this.waveStep = data[5];
			this.particlesCount = data[6];
			this.allowSwim = Boolean(data[7]);
			this.velocity = new b2Vec2(data[8][0], data[8][1]);
			this.bubblingFactor = data[9];

			if (!(10 in data))
				return;

			this.waveEnabled = Boolean(data[10]);

			if (!(11 in data))
				return;

			this.color0 = data[11][0];
			this.color1 = data[11][1];
			this.color2 = data[11][2];
			drawForStarling();
			if (!(12 in data))
				return;

			this.hydrantId = data[12];
		}

		public function dispose():void
		{
			this.game = null;

			this.graphics.clear();
			this.renderSprite = null;

			if (this.controller)
			{
				this.controller.GetWorld().DestroyController(this.controller);
				this.controller.waterSurface = null;
			}

			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			if (this.parentStarling)
				this.parentStarling.removeChildStarling(this);
		}

		public function setSize(x:int, y:int):void
		{
			size = new b2Vec2(x, y);
		}

		public function get size():b2Vec2
		{
			var result:b2Vec2 = _size.Copy();
			result.y = -result.y;
			result.Multiply(1 / (Game.PIXELS_TO_METRE / 2));
			return result;
		}

		public function set size(value:b2Vec2):void
		{
			value = value.Copy();
			value.Multiply(Game.PIXELS_TO_METRE / 2);
			value.y = -value.y;

			this._size = value;
			this._size.y = Math.abs(this._size.y);
			this._size.x = Math.max(this._size.x, 0);

			resize();
		}

		public function get particlesCount():int
		{
			return this._particlesCount;
		}

		public function set particlesCount(value:int):void
		{
			this._particlesCount = value;
			resize();
		}

		public function containPoint(v:b2Vec2):Boolean
		{
			return (v.y < 0) && (-v.y < this._size.y - 10) && (v.x > 0) && (v.x < this._size.x);
		}

		public function addBubble(v:b2Vec2, size:Number):void
		{
			v.Multiply(Game.PIXELS_TO_METRE);
			v.Subtract(new b2Vec2(this.x, this.y));

			var bubble:BubbleData = new BubbleData();
			bubble.pos = v;
			bubble.scale = size;
			bubble.vel2 = new b2Vec2(Math.random() - Math.random(), -1 * Math.abs(size));
			this.bubblesVector.push(bubble);
		}

		public function get waveEnabled():Boolean
		{
			return this._waveEnabled;
		}

		public function set waveEnabled(value:Boolean):void
		{
			this._waveEnabled = value;

			if (!value)
				this.particlesCount = 0;
		}

		public function get color0():int
		{
			return this._color0;
		}

		public function set color0(value:int):void
		{
			this._color0 = value;
			draw();
			drawForStarling();
		}

		public function get color1():int
		{
			return this._color1;
		}

		public function set color1(value:int):void
		{
			this._color1 = value;
			draw();
			drawForStarling();
		}

		public function get color2():int
		{
			return this._color2;
		}

		public function set color2(value:int):void
		{
			this._color2 = value;
			draw();
			drawForStarling();
		}

		public function estimateLags():Number
		{
			return 0.3 + (Math.min(0.5, this.bubblingFactor) * 3 + this.particlesCount * 0.1);
		}

		protected function drawForStarling():void
		{
			var graph: Shape = new Shape();

			graph.graphics.clear();

			if (starlingWater)
				removeChildStarling(starlingWater);

			var offset:Point = this.renderSprite ? new Point(this.x, this.y) : new Point();
			graph.graphics.moveTo(offset.x, offset.y);

			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(this._size.x, this._size.y, Math.PI / 2, offset.x, offset.y - this._size.y);

			graph.graphics.beginGradientFill(GradientType.LINEAR, [color0, color1, color2], [this._alpha0 * this.alpha, this._alpha1 * this.alpha, this._alpha2 * this.alpha], [0, 100, 255], matrix);
			graph.graphics.lineTo(particles[0].x + offset.x, particles[0].y + offset.y);

			for (var index:int = 0; index < particles.length - 1; index++)
			{
				var particle:WaterParticle = particles[index];
				var nextParticle:WaterParticle = particles[index + 1];
				var start:Point = new Point(particle.x + offset.x, particle.y + offset.y);
				var end:Point = new Point(nextParticle.x + offset.x, nextParticle.y + offset.y);
				graph.graphics.curveTo(start.x, start.y, end.x, end.y);
			}

			graph.graphics.lineStyle();
			graph.graphics.lineTo(_size.x + offset.x, offset.y);
			graph.graphics.endFill();

			starlingWater = new StarlingAdapterSprite(graph);
			addChildStarling(starlingWater);
		}

		protected function draw():void
		{}

		protected function resize():void
		{
			this.particles = new Vector.<WaterParticle>();

			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			while (this.particles.length < particlesCount)
				this.particles.push(new WaterParticle(-this._size.y));
			this.particles.push(new WaterParticle(-this._size.y), new WaterParticle(-this._size.y));

			var x:Number = 0;
			for each (var particle:WaterParticle in this.particles)
			{
				particle.x = x;
				addChildStarling(particle);
				x += this._size.x / (this.particles.length - 1);
			}

			this.defaultVolume = _size.x * _size.y;
			if (this.renderSprite == null)
				draw();
			drawForStarling();
		}

		private function getPos(index:int):b2Vec2
		{
			var particle:* = this.particles[index];
			return new b2Vec2(-(particle.x + this.x), particle.y + this.y);
		}

		private function getIndex(value:Number):int
		{
			if (value < this.x)
				return -1;
			if (value >= this.x + this._size.x)
				return int.MAX_VALUE;

			var result:int = int(((value - this.x) * (this.particles.length - 1)) / (this._size.x));
			if ((result) >= this.particles.length - 1)
				return int.MAX_VALUE;
			return result;
		}

		private function getByPos(value:Number):WaterParticle
		{
			var index:int = getIndex(value);
			if (index in particles)
				return this.particles[index];
			return null;
		}
	}
}