package game.mainGame.entity.simple
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.Rotator;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class Centrifuge extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE1:b2CircleShape = new b2CircleShape(44 / Game.PIXELS_TO_METRE);
		static private const SHAPE2:b2PolygonShape = b2PolygonShape.AsOrientedBox(33 / Game.PIXELS_TO_METRE, 11 / Game.PIXELS_TO_METRE, new b2Vec2(0, 40 / Game.PIXELS_TO_METRE));

		static private const FIXTURE_DEF1:b2FixtureDef = new b2FixtureDef(SHAPE1, null, 0.8, 0.1, 2, CATEGORIES_BITS, MASK_BITS, 0);
		static private const FIXTURE_DEF2:b2FixtureDef = new b2FixtureDef(SHAPE2, null, 0.8, 0.1, 5, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var view:StarlingAdapterMovie = null;

		private var squirrels:Object = {};

		private var arrow:StarlingAdapterSprite = null;
		private var rotator:Rotator = null;

		public var effectTime:Number = 5 * 1000;
		public var discMotorSpeed:Number = 15;

		public function Centrifuge():void
		{
			this.view = new StarlingAdapterMovie(new CentrifugeImg);
			//this.view.x = -44;
			//this.view.y = -44;
			this.view.loop = true;
			this.view.stop();
			addChildStarling(this.view);

			this.arrow = new StarlingAdapterSprite(new CentrifugeArrow());
			this.arrow.addEventListener(MouseEvent.MOUSE_DOWN, startDragArrow);
			(this.arrow as StarlingAdapterSprite).useCursorHand = true;
			Game.stage.addEventListener(MouseEvent.MOUSE_UP, stopDragArrow);
			addChildStarling(this.arrow);

			this.rotator = new Rotator(this.arrow, new Point());

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF2);

			this.body.CreateFixture(FIXTURE_DEF1).SetUserData(this);

			super.build(world);

			this.view.gotoAndPlay(0);
		}

		override public function dispose():void
		{
			for (var id:String in this.squirrels)
				releaseSquirrel(int(id));

			this.arrow.removeEventListener(MouseEvent.MOUSE_DOWN, startDragArrow);
			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragArrow);
			Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragArrow);

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			if (this.view)
				this.view.removeFromParent();
			this.view = null;

			this.squirrels = null;

			super.dispose();
		}

		override public function update(timeStep:Number = 0):void
		{
			if (this.body == null)
				return;

			super.update(timeStep);

			var hasSquirrels:Boolean = false;
			for (var id:String in this.squirrels)
			{
				var hero:Hero = this.gameInst.squirrels.get(int(id));
				if (!(hero && !hero.isDead && !hero.inHollow) || !hero.torqueApplied)
					continue;

				hero.angle += 1;
				hasSquirrels = true;
			}
			this.view.maxFPS = hasSquirrels ? Game.stage.frameRate * 3 : Game.stage.frameRate;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.fireAngle, this.effectTime, this.discMotorSpeed]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			this.fireAngle = data[1][0];
			this.effectTime = data[1][1];
			this.discMotorSpeed = data[1][2];
		}

		override public function set showDebug(value:Boolean):void
		{
			super.showDebug = value;

			this.arrow.visible = this.debugDraw;
		}

		public function beginContact(contact:b2Contact):void
		{
			var hero:* = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!(hero is Hero))
				return;

			if (!hero || hero.isDead || hero.inHollow || hero.isDragon || hero.isHare || this.squirrels[hero.id] != null || hero.hasJoints("centrifugeDisc"))
				return;

			commandPinSquirrel(hero.id);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function get fireAngle():Number
		{
			return (this.arrow.rotation + this.rotation) * Game.D2R;
		}

		private function set fireAngle(value:Number):void
		{
			this.rotator.rotation = value * Game.R2D - this.rotation;
		}

		private function commandPinSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			pinSquirrel(heroId);

			if (!(this.gameInst is SquirrelGameEditor))
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'pinSquirrel': [this.id, heroId]}));
		}

		private function commandBoostSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			boostSquirrel(heroId);

			if (!(this.gameInst is SquirrelGameEditor))
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'centrifugeSquirrel': [this.id, heroId]}));
		}

		private function pinSquirrel(heroId:int):void
		{
			if (!this.gameInst || this.squirrels[heroId] != null)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || hero.torqueApplied)
				return;

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.bodyA = this.body;
			hero.bindToRevoluteJointDef(jointDef, false);
			jointDef.collideConnected = false;
			jointDef.localAnchorA = new b2Vec2();
			jointDef.localAnchorB = new b2Vec2();
			jointDef.enableLimit = false;
			this.squirrels[hero.id] = this.body.GetWorld().CreateJoint(jointDef);

			hero.isStoped = true;
			hero.torqueApplied = true;
			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);

			hero.dispatchEvent(new Event(Hero.EVENT_BREAK_JOINT));

			setTimeout(commandBoostSquirrel, 600, hero.id);
		}

		private function boostSquirrel(heroId:int):void
		{
			if (!this.gameInst || this.squirrels[heroId] == null)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);

			if (!(hero && hero.isExist))
			{
				removeSquirrel(heroId);
				return;
			}

			releaseSquirrel(heroId);
			setTimeout(removeSquirrel, 1000, heroId);

			if (!(this.gameInst && this.gameInst.squirrels.isSynchronizing))
				return;

			var disc:CentrifugeDisc = new CentrifugeDisc();
			disc.hero = hero;
			disc.lifeTime = this.effectTime;
			disc.boostDir = new b2Vec2(Math.cos(this.fireAngle), Math.sin(this.fireAngle));
			disc.position = this.body.GetWorldCenter().Copy();
			var direction:b2Vec2 = disc.boostDir.Copy();
			direction.Multiply(5);
			direction.Add(disc.position);
			disc.position = direction;
			disc.motorSpeed = this.discMotorSpeed;
			hero.game.map.createObjectSync(disc, true);
		}

		private function releaseSquirrel(heroId:int):void
		{
			this.body.GetWorld().DestroyJoint(this.squirrels[heroId] as b2Joint);

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero)
				return;

			hero.torqueApplied = false;
			hero.isStoped = false;

			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
		}

		private function removeSquirrel(heroId:int):void
		{
			if (this.squirrels == null)
				return;

			this.squirrels[heroId] = null;
			delete this.squirrels[heroId];
		}

		private function onEvent(e:Event):void
		{
			releaseSquirrel(e['player']['id']);
			removeSquirrel(e['player']['id']);
		}

		private function startDragArrow(e:MouseEvent):void
		{
			Game.stage.addEventListener(MouseEvent.MOUSE_MOVE, dragArrow);
			e.stopImmediatePropagation();
		}

		private function stopDragArrow(e:MouseEvent):void
		{
			Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragArrow);
		}

		private function dragArrow(e:MouseEvent):void
		{
			var globalCoords:Point = this.localToGlobal(new Point());
			var angle:Number = Math.atan2(e.stageY - globalCoords.y, e.stageX - globalCoords.x);

			var positiveAngle:Number = (angle <= 0) ? (-angle) : (Math.PI * 2 - angle);
			var standAngle:Number = (this.angle <= 0) ? (-this.angle) : (Math.PI * 2 - this.angle);

			if ((standAngle < Math.PI) ? ((positiveAngle > standAngle + Math.PI) || positiveAngle < standAngle) : ((positiveAngle > standAngle - Math.PI) && (positiveAngle < standAngle)))
				return;

			this.rotator.rotation = angle * Game.R2D - this.rotation;
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('pinSquirrel' in data)
			{
				if (data['pinSquirrel'][0] != this.id)
					return;
				if (data['pinSquirrel'][1] == Game.selfId)
					return;

				pinSquirrel(data['pinSquirrel'][1]);
			}

			if ('centrifugeSquirrel' in data)
			{
				if (data['centrifugeSquirrel'][0] != this.id)
					return;
				if (data['centrifugeSquirrel'][1] == Game.selfId)
					return;

				boostSquirrel(data['centrifugeSquirrel'][1]);
			}
		}
	}
}