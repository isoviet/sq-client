package syncronize
{
	import Box2D.Common.Math.b2Vec2;

	public class SyncPacketParser implements ISyncObject
	{
		private var _id:int;

		private var _position:b2Vec2;
		private var _linearVelocity:b2Vec2;

		private var _angle:Number;
		private var _angularVelocity:Number;

		private var syncId:int = 0;

		public function SyncPacketParser(data:Array, syncId:int = 0):void
		{
			this._id = data[0];
			this._position = new b2Vec2(data[1], data[2]);
			this._angle = data[3];
			this._linearVelocity = new b2Vec2(data[4], data[5]);
			this._angularVelocity = data[6];

			this.syncId = syncId;
		}

		public function get id():int
		{
			return this._id;
		}

		public function set id(value:int):void
		{
			this._id = value;
		}

		public function get position():b2Vec2
		{
			return this._position;
		}

		public function set position(value:b2Vec2):void
		{
			this._position = value;
		}

		public function get angle():Number
		{
			return this._angle;
		}

		public function set angle(value:Number):void
		{
			this._angle = value;
		}

		public function get linearVelocity():b2Vec2
		{
			return this._linearVelocity;
		}

		public function set linearVelocity(value:b2Vec2):void
		{
			this._linearVelocity = value;
		}

		public function get angularVelocity():Number
		{
			return this._angularVelocity;
		}

		public function set angularVelocity(value:Number):void
		{
			this._angularVelocity = value;
		}

		public function get personalId():int
		{
			return this.syncId;
		}

		public function dispose():void
		{}
	}
}