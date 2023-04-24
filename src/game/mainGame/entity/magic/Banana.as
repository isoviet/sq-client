package game.mainGame.entity.magic
{
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.simple.GameBody;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class Banana extends GameBody implements ILifeTime
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_NONE_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_NONE_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(9 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 10, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, true, b2Body.b2_dynamicBody);

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 1 * 1000;
		private var disposed:Boolean = false;

		private var view:StarlingAdapterSprite;
		private var explodeView:StarlingAdapterMovie;

		public function Banana()
		{
			this.view = new StarlingAdapterSprite(new MinionPerkView());
			addChildStarling(this.view);

			this.explodeView = new StarlingAdapterMovie(new MinionPerkExplodeView());
			this.explodeView.loop = false;
			this.explodeView.visible = false;
			addChildStarling(this.explodeView);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body)
				return;

			if (!this.aging || this.disposed)
				return;

			this._lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);
			this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(0, -100)));

			Connection.listen(onPacket, [PacketRoundCommand.PACKET_ID]);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.lifeTime, this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.lifeTime = data[1][0];
			this.playerId = data[1][1];
		}

		public function get aging():Boolean
		{
			return this._aging;
		}

		public function set aging(value:Boolean):void
		{
			this._aging = value;
		}

		public function get lifeTime():Number
		{
			return this._lifeTime;
		}

		public function set lifeTime(value:Number):void
		{
			this._lifeTime = value;
		}

		private function destroy():void
		{
			if (!this.gameInst.squirrels.isSynchronizing)
				return;
			if (this.disposed)
				return;
			this.disposed = true;

			var command:Object = {};
			command['banana'] = {'id': this.id};
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode(command));
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			if (!("banana" in packet.dataJson) || packet.dataJson['banana']['id'] != this.id)
				return;

			this.fixed = true;
			this.view.visible = false;
			this.explodeView.visible = true;
			this.explodeView.addEventListener(Event.ENTER_FRAME, onFrame);
			this.explodeView.play();

			Connection.forget(onPacket, [PacketRoundCommand.PACKET_ID]);

			if (!this.gameInst.squirrels.isSynchronizing)
				return;
			for (var i:int = 0; i < 5; i++)
			{
				var banana:BananaSmall = new BananaSmall();
				banana.playerId = this.playerId;
				banana.angle = this.body.GetAngle() + Math.PI * (i - 2) / 4;
				banana.position = this.position.Copy();
				banana.currentId = i;
				this.gameInst.map.createObjectSync(banana, true);
			}
		}

		private function onFrame(e:Event):void
		{
			if (!this.explodeView)
				return;
			if (this.explodeView.currentFrame < this.explodeView.totalFrames - 1)
				return;
			this.explodeView.stop();
			this.explodeView.removeEventListener(Event.ENTER_FRAME, onFrame);

			if (this.gameInst && this.gameInst.map)
				this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}