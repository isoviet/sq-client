package syncronize
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.simple.GameBody;

	public class SyncGameBody implements ISyncObject
	{
		private var _id: int = -1;
		private var body: GameBody = null;

		public function SyncGameBody(body:GameBody):void
		{
			this.body = body;
			this.body.syncObject = this;
		}

		public function get id():int
		{
			return this.body.id;
		}

		public function set id(value:int):void
		{
			this._id = value;
		}

		public function get position():b2Vec2
		{
			return this.body.position;
		}

		public function set position(value:b2Vec2):void
		{
			if (isNaN(value.x) || isNaN(value.y))
				return;
			this.body.position = value;
		}

		public function get angle():Number
		{
			return this.body.angle;
		}

		public function set angle(value:Number):void
		{
			if (isNaN(value))
				return;

			this.body.angle = value;
		}

		public function get linearVelocity():b2Vec2
		{
			if (this.body.body == null)
				return new b2Vec2(0, 0);
			return this.body.body.GetLinearVelocity();
		}

		public function set linearVelocity(value:b2Vec2):void
		{
			if (isNaN(value.x) || isNaN(value.y))
				return;
			if (this.body.body == null)
				return;
			this.body.body.SetLinearVelocity(value);
		}

		public function get angularVelocity():Number
		{
			if (this.body.body == null)
				return 0;
			return this.body.body.GetAngularVelocity();
		}

		public function set angularVelocity(value:Number):void
		{
			if (isNaN(value))
				return;
			if (this.body.body == null)
				return;
			this.body.body.SetAngularVelocity(value);
		}

		public function get personalId():int
		{
			if (this.body == null || !(this.body is IPersonalObject))
				return 0;
			return (this.body as IPersonalObject).personalId;
		}

		public function dispose():void
		{
			this.body = null;
		}

		public function sync(object:ISyncObject):void
		{
			this.angle = object.angle;
			this.angularVelocity = object.angularVelocity;
			this.linearVelocity = object.linearVelocity;
			this.position = object.position;
		}
	}
}