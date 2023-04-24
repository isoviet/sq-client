package game.mainGame.entity.simple
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.GameMap;
	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelCollection;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IPostDeserialize;
	import game.mainGame.gameEditor.Selection;

	import by.blooddy.crypto.serialization.JSON;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.IntUtil;
	import utils.starling.StarlingAdapterSprite;

	public class FlyWayPoint extends BindPoint implements IGameObject, IUpdate, ISerialize, IPostDeserialize, IDispose, IComplexEditorObject, IEditorDebugDraw
	{
		static private const SPEED_BASE:int = 100;

		private var pointsIds:Array = null;
		private var bodyPointsIds:Array = null;

		private var view:StarlingAdapterSprite;

		private var map:GameMap = null;

		private var gameInst:SquirrelGame;

		public var destinations:Object = {};
		public var bodies:Object = {};
		public var bodiesIds:Array = [];

		public function FlyWayPoint():void
		{
			super();

			this.view = new StarlingAdapterSprite(new FlyWayPointView());
			addChildStarling(this.view);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function set x(value:Number):void
		{
			super.x = value;

			updateWays();
		}

		override public function set y(value:Number):void
		{
			super.y = value;

			updateWays();
		}

		public function getBody(bodyId:int):GameBody
		{
			if (bodyId in this.bodies)
				return this.bodies[bodyId];

			return null;
		}

		public function setBody(bodyId:int, body:GameBody):void
		{
			if (this.bodiesIds.indexOf(bodyId) == -1)
				this.bodiesIds.push(bodyId);

			this.bodies[bodyId] = body;
		}

		override public function getRect(targetCoordinateSpace:DisplayObject):Rectangle
		{
			return this.view.getRect(targetCoordinateSpace);
		}

		public function get angle():Number
		{
			return this.rotation * Game.D2R;
		}

		public function set angle(value:Number):void
		{
			this.rotation = value / (Game.D2R);
			updateWays();
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

		public function build(world:b2World):void
		{
			showDebug = false;

			this.gameInst = world.userData as SquirrelGame;

			for each (var body:GameBody in this.bodies)
			{
				if (!body)
					continue;
				body.position = this.position;
			}
		}

		public function serialize():*
		{
			this.pointsIds = [];

			for each (var point:IGameObject in this.bindPoints)
				this.pointsIds.push(this.map.getID(point));

			this.bodyPointsIds = [];

			for each (point in this.bodyPoints)
				this.bodyPointsIds.push(this.map.getID(point));

			return [[this.position.x, this.position.y], this.pointsIds, this.bodyPointsIds];
		}

		public function deserialize(data:*):void
		{
			this.pointsIds = [];
			this.bodyPointsIds = [];

			this.position = new b2Vec2(data[0][0], data[0][1]);

			for each (var pointId:int in data[1])
				this.pointsIds.push(pointId);

			for each (pointId in data[2])
				this.bodyPointsIds.push(pointId);
		}

		public function OnPostDeserialize(map:GameMap):void
		{
			this.bindPoints = new Vector.<IGameObject>();
			this.bodyPoints = new Vector.<IGameObject>();

			for each (var pointId:int in this.pointsIds)
				this.bindPoints.push(this.map.getObject(pointId));

			for each (pointId in this.bodyPointsIds)
			{
				var body:GameBody = this.map.getObject(pointId) as GameBody;
				if (body != null)
				{
					setBody(pointId, body);
					this.bodyPoints.push(body);
					body.bindPoints.push(this);
				}
			}

			updateWay();
		}

		public function dispose():void
		{
			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			this.destinations = {};

			this.bodies = {};
			this.bodiesIds = [];
		}

		public function onAddedToMap(map:GameMap):void
		{
			showDebug = false;
			this.map = map;
		}

		public function onRemovedFromMap(map:GameMap):void
		{}

		public function onSelect(selection:Selection):void
		{}

		public function set showDebug(value:Boolean):void
		{
			this.debugDraw = value;
			this.visible = value;

			updateWays();
		}

		public function update(timeStep:Number = 0):void
		{
			if (this.bindPoints.length == 0)
				return;

			for each (var bodyId:int in this.bodiesIds)
			{
				var body:GameBody = getBody(bodyId);
				if (body == null)
					continue;

				if (!(bodyId in this.destinations) || this.destinations[bodyId] == null)
				{
					synchronize(bodyId);
					return;
				}

				var destinationPoint:Point = new Point(this.destinations[bodyId].x, this.destinations[bodyId].y);
				var direction:Point = destinationPoint.subtract(new Point(body.x, body.y));

				if (direction.length < SPEED_BASE * timeStep * body.speed)
				{
					synchronize(bodyId);
					return;
				}

				direction.normalize(direction.length < (3 * SPEED_BASE * timeStep * body.speed) ? int(direction.length / 2) : (SPEED_BASE * timeStep * body.speed));

				body.position = new b2Vec2((body.x + direction.x) / Game.PIXELS_TO_METRE, (body.y + direction.y) / Game.PIXELS_TO_METRE);
			}
		}

		private function clearBody(bodyId:int):void
		{
			this.destinations[bodyId] = null;

			setBody(bodyId, null);

			if (this.bodiesIds.length <= 1)
			{
				this.bodiesIds = [];
				return;
			}

			var bodyIndex:int = this.bodiesIds.indexOf(bodyId);
			this.bodiesIds.splice(bodyIndex, 1);
		}

		private function synchronize(bodyId:int):void
		{
			if (Hero.self && !this.gameInst.squirrels.isSynchronizing)
				return;

			var currentPoint:FlyWayPoint = ((bodyId in this.destinations) && this.destinations[bodyId] != null) ? this.destinations[bodyId] : this;

			var destIndex:int = IntUtil.randomInt(0, currentPoint.bindPoints.length - 1);
			currentPoint.destinations[bodyId] = currentPoint.bindPoints[destIndex] as FlyWayPoint;
			currentPoint.setBody(bodyId, getBody(bodyId));

			var data:Object = {'FlyWay': [bodyId, this.map.getID(currentPoint), this.map.getID(currentPoint.destinations[bodyId])]};
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode(data));

			if (currentPoint != this)
				clearBody(bodyId);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var result:Object = packet.dataJson;
			if (!('FlyWay' in result))
				return;

			var data:Array = result['FlyWay'];

			if (!SquirrelCollection.instance)
				return;
			if (Hero.self && SquirrelCollection.instance.isSynchronizing)
				return;

			var bodyId:int = data[0];

			if (this.bodiesIds.indexOf(bodyId) == -1)
				return;

			var body:GameBody = getBody(bodyId);

			if (body == null)
				return;

			var currentPoint:FlyWayPoint = this.map.getObject(data[1]) as FlyWayPoint;
			currentPoint.destinations[bodyId] = this.map.getObject(data[2]) as FlyWayPoint;
			currentPoint.setBody(bodyId, body);
			currentPoint.update();

			if (currentPoint != this)
				clearBody(bodyId);
		}
	}
}