package game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;

	import game.mainGame.CollisionGroup;
	import sensors.ISensor;

	import utils.starling.StarlingAdapterSprite;

	public class BeamEmitter extends BeamReceiver implements ISensor
	{
		static private const STATE_WORK:int = 0;
		static private const STATE_BEFORE_BLINK:int = 1;
		static private const STATE_BLINK:int = 2;

		private var beam:StarlingAdapterSprite = null;
		private var beamFixture:b2Fixture = null;

		private var _receiver:BeamReceiver = null;
		private var receivers:Array = null;
		private var _state:int = STATE_WORK;

		private var timeCounter:Number = 0;

		private var hasObstacles:Boolean = false;

		private var receiverId:int = -1;

		private var beamDefSize: Number = 0;

		public var workTime:Number = 5 * 1000;
		public var blinkTime:Number = 2 * 1000;
		private var emitterWidth: int = 0;

		public function BeamEmitter():void
		{
			super();
			emitterWidth = this.width;

			this.beam = new StarlingAdapterSprite(new Beam());
			beamDefSize = this.beam.width;
			this.beam.x = this.beam.width / 2;
			this.beam.mouseEnabled = false;
			this.beam.mouseChildren = false;
			this.beam.visible = false;
			this.beam.rotation = 90;
			this.beam.pivotY = this.beam.width;
			addChildStarlingAt(this.beam, 0);
		}

		override public function dispose():void
		{
			if (this.beam)
				this.beam.removeFromParent(true);
			this.beam = null;

			this.receivers = null;
			this._receiver = null;
			this.beamFixture = null;

			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			var extraData:Array = [this.workTime, this.blinkTime, this.timeCounter];
			if (this.receiver)
				extraData.push([this.state, this.receiver.id]);
			result.push(extraData);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.workTime = data[1][0];
			this.blinkTime = data[1][1];
			this.timeCounter = data[1][2];

			if (!(3 in data[1]))
				return;

			this._state = data[1][3][0];
			this.receiverId = data[1][3][1];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;

			if (this.receivers == null)
				this.receivers = this.gameInst.map.get(BeamReceiver);

			if (this.receiver == null)
			{
				if (this.receiverId != -1)
				{
					this.receiver = this.gameInst.map.getObject(this.receiverId) as BeamReceiver;
					this.state = this.state;
					this.receiverId = -1;
					return;
				}

				for (var i:int = this.receivers.length - 1; i >= 0; i--)
				{
					if (checkReceiver(this.receivers[i]))
					{
						this.receiver = this.receivers[i];
						this.state = STATE_WORK;
						return;
					}
				}
			}
			else
			{
				if (!checkReceiver(this.receiver))
				{
					this.receiver = null;
				}
				else
				{
					if (this.timeCounter <= 0)
					{
						this.state = (this.state == STATE_BLINK) ? STATE_WORK : STATE_BLINK;
						this.timeCounter = (this.state == STATE_BLINK) ? this.blinkTime : this.workTime;
					}
					else
						this.timeCounter -= timeStep * 1000;

					if ((this.state == STATE_WORK) && this.timeCounter < 1.5 * 1000 && this.blinkTime > 0)
						this.state = STATE_BEFORE_BLINK;
				}
			}
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if (this.state != STATE_BLINK)
				return;

			if (contact.GetFixtureA() != this.beamFixture && contact.GetFixtureB() != this.beamFixture)
				return;

			contact.SetEnabled(false);
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function set receiver(value:BeamReceiver):void
		{
			if (this._receiver == value)
				return;

			this._receiver = value;

			if (this.beamFixture)
				this.body.DestroyFixture(this.beamFixture);
			this.beamFixture = null;

			this.beam.visible = value != null;

			if (!value)
				return;

			var beamLength:Number = b2Math.SubtractVV(this.position, value.position).Length();

			this.beam.scaleX =  (beamLength * Game.PIXELS_TO_METRE) / beamDefSize;

			this.beam.x = emitterWidth / 2;
			this.beam.y = -this.beam.height + 5;
			var def:b2FixtureDef = new b2FixtureDef(b2PolygonShape.AsOrientedBox(2 / Game.PIXELS_TO_METRE, beamLength / 2, new b2Vec2(0, -beamLength / 2)), this, 0.8, 0.1, 0.1, CollisionGroup.OBJECT_CATEGORY, CollisionGroup.HERO_CATEGORY);
			this.beamFixture = this.body.CreateFixture(def);
			this.beamFixture.SetUserData(this);
		}

		private function get receiver():BeamReceiver
		{
			return this._receiver;
		}

		private function set state(value:int):void
		{
			switch (value)
			{
				case STATE_WORK:
					this.timeCounter = this.workTime;
					setBeamFilter(CollisionGroup.OBJECT_CATEGORY);
					this.beam.visible = true;
					break;
				case STATE_BEFORE_BLINK:
					break;
				case STATE_BLINK:
					if (this.blinkTime == 0)
						return;
					this.beam.visible = false;
					this.timeCounter = this.blinkTime;
					setBeamFilter(CollisionGroup.OBJECT_NONE_CATEGORY);
					break;
			}

			this._state = value;
		}

		private function get state():int
		{
			return this._state;
		}

		private function setBeamFilter(categorieBits:uint):void
		{
			if (!this.beamFixture)
				return;
			var filter:b2FilterData = this.beamFixture.GetFilterData();
			filter.categoryBits = categorieBits;
			this.beamFixture.SetFilterData(filter);
		}

		private function checkReceiver(body2:BeamReceiver):Boolean
		{
			var vec3:b2Vec2 = b2Math.SubtractVV(body2.position, this.position);
			var vec4:b2Vec2 = vec3.Copy();
			vec4.Normalize();
			if ((Math.abs(b2Math.Dot(vec4, this.body.GetWorldVector(new b2Vec2(1, 0)))) >= 0.05) || (Math.abs(b2Math.Dot(vec4, body2.body.GetWorldVector(new b2Vec2(1, 0)))) >= 0.05) || (b2Math.AddVV(this.body.GetWorldVector(new b2Vec2(0, -1)), vec3).Length() < vec3.Length()) || b2Math.AddVV(body2.body.GetWorldVector(new b2Vec2(0, -1)), vec3).Length() > vec3.Length())
				return false;

			this.hasObstacles = false;

			this.gameInst.world.RayCast(rayCastCallback, body2.position, this.position);
			return !this.hasObstacles;
		}

		private function rayCastCallback(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number):Number
		{
			var body:b2Body = fixture.GetBody();
			if (body != this.body && !(body.GetUserData() is Hero) && !(body.GetUserData() is Element) && (fixture.GetUserData() != this))
			{
				this.hasObstacles = true;
				return 0;
			}

			return 1;
		}
	}
}