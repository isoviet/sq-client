package game.mainGame.entity.editor
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2World;

	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterSprite;

	public class PlatformOilBody extends PartitionsPlatform implements ISensor
	{
		static private const BLOCK_WIDTH:int = 40;
		static private const BLOCK_HEIGHT:int = 21;

		private var buff:BuffRadialView = null;
		private var timer:Timer = new Timer(50, 100);

		private var squirrels:Object = {};

		private var deserializedIds:Array = [];

		public var effectTime:int = 5 * 1000;

		public function PlatformOilBody():void
		{
			super();

			this.friction = 0;
			this.restitution = 0;
			this.density = 0.5;

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function set size(value:b2Vec2):void
		{
			value.y = (this.blockHeight / Game.PIXELS_TO_METRE);

			super.size = value;
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			//this.body.GetFixtureList().SetFriction(0);

			this.timer.delay = this.effectTime / 100;

			for (var i:int = 0; i < this.deserializedIds.length; i++)
			{
				var hero:Hero = this.gameInst.squirrels.get(this.deserializedIds[i]);
				if (!hero || hero.isDead || hero.inHollow || (hero.id in this.squirrels))
					return;

				this.squirrels[hero.id] = hero.friction;
				hero.friction = 0;
			}

			this.deserializedIds.splice(0);
		}

		override public function dispose():void
		{
			for (var id:String in this.squirrels)
				resetSquirrel(int(id));

			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			this.squirrels = null;

			super.dispose();
		}

		override public function serialize():*
		{
			var ids:Array = [];
			for (var id:String in this.squirrels)
				ids.push(id);

			var result:Array = super.serialize();
			result.push([this.effectTime, ids]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.effectTime = data[2][0];
			this.deserializedIds = data[2][1];
		}

		override public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = null;

			if (contact.GetFixtureA().GetFilterData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetFilterData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!hero)
				return;

			commandResetSquirrel(hero.id);
		}

		override public function endContact(contact:b2Contact):void
		{
			var hero:Hero = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!hero)
				return;

			commandOilSquirrel(hero.id);
		}

		override public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var maniFold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(maniFold);

			if (contact.GetFixtureB().GetBody().GetUserData() == this)
				contact.SetEnabled(maniFold.m_normal.y >= 0);
			else
				contact.SetEnabled(!(maniFold.m_normal.y >= 0));
		}

		override public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		override protected function get leftClass():Class
		{
			return OilLeft;
		}

		override protected function get middleClass():Class
		{
			return OilMiddle;
		}

		override protected function get rightClass():Class
		{
			return OilRight;
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new OilIcon());
		}

		protected function get blockWidth():int
		{
			return BLOCK_WIDTH;
		}

		protected function get blockHeight():int
		{
			return BLOCK_HEIGHT;
		}

		private function commandOilSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId || !this.gameInst)
				return;

			if (this.gameInst is SquirrelGameEditor)
				oilSquirrel(heroId);
			else
			{
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'oilSquirrel': [this.id, heroId]}));
				if (Hero.self)
					Hero.self.sendLocation();
			}
		}

		private function commandResetSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId || !this.gameInst)
				return;

			if (this.gameInst is SquirrelGameEditor)
				removeSquirrel(heroId);
			else
			{
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'resetOilSquirrel': [this.id, heroId]}));
				if (Hero.self)
					Hero.self.sendLocation();
			}
		}

		private function oilSquirrel(heroId:int):void
		{
			if (!this.gameInst)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || (hero.id in this.squirrels))
				return;

			this.squirrels[hero.id] = hero.friction;
			hero.friction = 0;

			if (!hero.isSelf)
				return;

			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);

			if (!buff)
				buff = new BuffRadialView(new OilIcon, 0.5, 0.5, gls("Белка скользит после масла."));

			hero.addBuff(buff, this.timer);

			this.timer.reset();
			this.timer.start();
		}

		private function removeSquirrel(heroId:int):void
		{
			resetSquirrel(heroId);
			delete this.squirrels[heroId];
		}

		private function resetSquirrel(heroId:int):void
		{
			if (!this.gameInst)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);

			if (!hero || !hero.isExist || !(hero.id in this.squirrels))
				return;

			hero.friction += this.squirrels[hero.id];

			if (!hero.isSelf)
				return;

			if (this.timer.running)
			{
				this.timer.reset();
				hero.removeBuff(this.buff, this.timer);
			}

			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
		}

		private function onComplete(e:TimerEvent):void
		{
			commandResetSquirrel(Game.selfId);
		}

		private function onEvent(e:Event):void
		{
			commandResetSquirrel(e['player']['id']);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('oilSquirrel' in data)
			{
				if (data['oilSquirrel'][0] != this.id)
					return;

				oilSquirrel(data['oilSquirrel'][1]);
			}

			if ('resetOilSquirrel' in data)
			{
				if (data['resetOilSquirrel'][0] != this.id)
					return;

				removeSquirrel(data['resetOilSquirrel'][1]);
			}
		}
	}
}