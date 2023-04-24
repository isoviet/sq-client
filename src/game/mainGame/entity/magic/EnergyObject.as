package game.mainGame.entity.magic
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.entity.simple.GameBody;
	import screens.ScreenGame;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;
	import protocol.packages.server.PacketRoundSkillAction;

	public class EnergyObject extends GameBody implements IPinFree
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(15 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var sensor:HeroDetector;
		protected var sended:Boolean = false;

		protected var view:MovieClip = null;
		protected var beginView:MovieClip = null;

		protected var perkCode:int;
		protected var messageId:int;

		public function EnergyObject():void
		{
			this.view = this.animation;
			this.view.visible = false;
			addChild(this.view);

			this.beginView = this.beginAnimation;
			addChild(this.beginView);

			this.fixed = true;

			super();
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);

			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);

			super.build(world);

			this.beginView.gotoAndPlay(0);
			this.beginView.addEventListener(Event.CHANGE, onComplete);

			Connection.listen(onPacket, [PacketRoundSkill.PACKET_ID, PacketRoundSkillAction.PACKET_ID]);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
		}

		override public function dispose():void
		{
			super.dispose();

			Connection.forget(onPacket, [PacketRoundSkill.PACKET_ID, PacketRoundSkillAction.PACKET_ID]);

			if (contains(this.view))
				removeChild(this.view);

			onComplete();

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
		}

		protected function get animation():MovieClip
		{
			return null;
		}

		protected function get beginAnimation():MovieClip
		{
			return null;
		}

		protected function showAward():void
		{}

		protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var packetSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (packetSkill.type != this.perkCode)
						return;
					if (packetSkill.targetId != this.playerId)
						return;
					if (!this.gameInst.squirrels.isSynchronizing)
						return;
					this.gameInst.map.destroyObjectSync(this, true);
					break;
				case PacketRoundSkillAction.PACKET_ID:
					var packetAction:PacketRoundSkillAction = packet as PacketRoundSkillAction;
					if (packetAction.type != this.perkCode)
						return;

					if (packetAction.targetId <= 0 || packetAction.targetId != this.playerId)
						return;

					ScreenGame.sendMessage(packetAction.playerId, "", this.messageId);

					if (!this.gameInst)
						return;

					showAward();
					this.gameInst.squirrels.get(packetAction.playerId).heroView.showGetBonusAnimation(new this.animation.constructor());

					if (!this.gameInst.squirrels.isSynchronizing)
						return;

					this.gameInst.map.destroyObjectSync(this, true);
					break;
			}
		}

		private function onComplete(e:Event = null):void
		{
			if (this.beginView.parent)
				this.beginView.parent.removeChild(this.beginView);

			this.beginView.removeEventListener(Event.CHANGE, onComplete);
			this.view.visible = true;
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			if (e.hero.id != Game.selfId && e.hero.id > 0)
				return;

			if (e.hero.isDead || e.hero.isHare || e.hero.shaman)
				return;

			if (this.sended)
				return;

			Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.perkCode, this.playerId);
			this.sended = true;
		}
	}
}