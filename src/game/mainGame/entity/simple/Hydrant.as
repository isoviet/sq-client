package game.mainGame.entity.simple
{
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.water.Water;
	import game.mainGame.gameEditor.SquirrelGameEditor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterMovie;

	public class Hydrant extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsVector(vertices, 0);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.5, 0.1, 2, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const WATER_UP_STEP:Number = 1 / Game.PIXELS_TO_METRE;
		static private const WATER_DOWN_STEP:Number = 5 / Game.PIXELS_TO_METRE;

		private var view:StarlingAdapterMovie = null;

		private var _active:Boolean = false;
		private var water:Water = null;
		private var _waterLayer:Number = 0;
		public var _waterId:int = -1;
		private var timeCounter:Number = 0;

		public var waterVolume:b2Vec2 = new b2Vec2(60, 60);
		public var waterTime:Number = 5 * 1000;

		public function Hydrant():void
		{
			this.view = new StarlingAdapterMovie(new HydrantImage);
			this.view.gotoAndStop(0);
			addChildStarling(this.view);

			this.fixed = true;
			this.view.addEventListener(Event.COMPLETE, onAnimateViewComplete);
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		private function onAnimateViewComplete(event: Event):void
		{
			if (this._active) {
				this.view.loop = true;
				this.view.offsetFrameCount = 22;
				this.view.play();
			}
		}

		static private function get vertices():Vector.<b2Vec2>
		{
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			vertices.push(new b2Vec2(-1, 0));
			vertices.push(new b2Vec2(-1, -4.5));
			vertices.push(new b2Vec2(0, -5.5));
			vertices.push(new b2Vec2(1, -4.5));
			vertices.push(new b2Vec2(1, 0));
			return vertices;
		}

		override public function set rotation(value:Number):void
		{
			if (value) {/*unused*/}
			super.rotation = 0;
		}

		override public function set angle(value:Number):void
		{}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			super.build(world);
		}

		override public function dispose():void
		{
			this.view = null;
			this.water = null;
			this.waterVolume = null;

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.active)
			{
				if (this.waterLayer >= this.waterVolume.y)
				{
					this.timeCounter -= timeStep * 1000;

					if (this.timeCounter <= 0)
						this.active = false;
				}
				else
					this.waterLayer += WATER_UP_STEP;
			}
			else
				this.waterLayer -= WATER_DOWN_STEP;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			var extraData:Array = [this.active, [this.waterVolume.x, this.waterVolume.y], this.waterTime];
			if (this.water)
				extraData.push([this.waterLayer, this.timeCounter]);
			result.push(extraData);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.active = Boolean(data[1][0]);
			this.waterVolume = new b2Vec2(data[1][1][0], data[1][1][1]);
			this.waterTime = data[1][2];

			if (!(3 in data[1]))
				return;

			this._waterLayer = data[1][3][0];
			this.timeCounter = data[1][3][1];
		}

		public function set active(value:Boolean):void
		{
			if (this._active == value)
				return;

			this._active = value;

			if (!value) {
				this.view.loop = false;
				this.view.offsetFrameCount = 0;
				this.view.gotoAndStop(0);
			} else {
				if (this.waterLayer == 0) {
					this.view.loop = false;
					this.view.offsetFrameCount = 0;
					this.view.gotoAndPlay(1);
				}
			}

			if (!(this.gameInst && this.gameInst.squirrels.isSynchronizing) || !this.water || (this.gameInst is SquirrelGameEditor))
				return;

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'waterLayer': [this.id, this.waterLayer]}));
		}

		public function get active():Boolean
		{
			return this._active;
		}

		public function set waterId(value:int):void
		{
			this._waterId = value;
			if (!this.gameInst)
				return;

			this.water = this.gameInst.map.getObject(this.waterId) as Water;
			this.waterLayer = this._waterLayer;
		}

		public function get waterId():int
		{
			return this._waterId;
		}

		private function set waterLayer(value:Number):void
		{
			if (this._waterLayer == value)
				return;

			if (this.water == null && value >= 0 && this.waterId == -1)
			{
				if (this.gameInst && this.gameInst.squirrels.isSynchronizing)
				{
					this._waterId = -2;

					var water:Water = new Water();
					water.size = new b2Vec2(this.waterVolume.x, value);
					water.bubblingFactor = 0.1;
					water.color0 = water.color1 = water.color2 = 0x66FFFF;
					water.position = new b2Vec2(this.position.x - this.waterVolume.x / 4, this.position.y);
					water.waveEnabled = true;
					water.waveAmplitude = 5;
					water.waveLength = 5;
					water.hydrantId = this.id;
					this.gameInst.map.createObjectSync(water, true);
				}

				return;
			}

			if (this.waterId < 0)
				return;

			if (this._waterLayer < 0 && value < this._waterLayer)
				return;

			this._waterLayer = value;

			if (value < 0 && this.water)
			{
				commandDestroyWater();
				return;
			}

			if (this._waterLayer >= this.waterVolume.y)
				this.timeCounter = this.waterTime;

			this.water.size = new b2Vec2(this.waterVolume.x, this._waterLayer);
		}

		private function get waterLayer():Number
		{
			return this._waterLayer;
		}

		private function commandDestroyWater():void
		{
			if (this.gameInst is SquirrelGameEditor)
			{
				detsroyWater(this.waterId);
				return;
			}

			if (!(this.gameInst && this.gameInst.squirrels.isSynchronizing))
				return;

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'destroyWater': [this.id, this.waterId]}));
			this._waterId = -1;
		}

		private function detsroyWater(waterId:int):void
		{
			this.water = null;
			this._waterLayer = 0;
			this._waterId = -1;

			if (!this.gameInst)
				return;

			this.gameInst.map.remove(this.gameInst.map.getObject(waterId), true);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('destroyWater' in data)
			{
				if (data['destroyWater'][0] != this.id)
					return;

				detsroyWater(data['destroyWater'][1]);
			}

			if ('waterLayer' in data)
			{
				if (data['waterLayer'][0] != this.id)
					return;

				this._waterLayer = data['waterLayer'][1];
			}
		}
	}
}