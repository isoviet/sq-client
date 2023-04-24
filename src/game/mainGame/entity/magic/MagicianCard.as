package game.mainGame.entity.magic
{
	import flash.display.MovieClip;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.ISideObject;
	import game.mainGame.SideIconView;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.Perk;
	import game.mainGame.perks.mana.PerkReborn;
	import game.mainGame.perks.mana.PerkTeleport;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkillAction;

	import utils.starling.StarlingAdapterSprite;

	public class MagicianCard extends GameBody implements ISideObject
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(15 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var sensor:HeroDetector = null;
		private var sended:Boolean = false;

		private var view:MovieClip = null;

		private var perks:Array = null;
		private var hero:Hero = null;
		private var _isVisible: Boolean = false;

		public var isMan:Boolean = true;
		public var perkCode:int;

		public function MagicianCard()
		{
			this.fixed = true;
			super();
		}

		override public function build(world:b2World):void
		{
			this.view = this.isMan ? new BlackMagicianCard() : new RedMagicianCard();
			addChildStarling(new StarlingAdapterSprite(this.view));

			this.body = world.CreateBody(BODY_DEF);

			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);

			super.build(world);

			Connection.listen(onPacket, PacketRoundSkillAction.PACKET_ID);
		}

		override public function dispose():void
		{
			super.dispose();

			Connection.forget(onPacket, PacketRoundSkillAction.PACKET_ID);

			if (containsStarling(this.view))
				removeChildStarling(this.view);

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.playerId, this.isMan ? 1 : 0, this.perkCode]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
			this.isMan = (data[1][1] == 1);
			this.perkCode = data[1][2];
		}

		public function get sideIcon(): StarlingAdapterSprite
		{
			return new SideIconView(SideIconView.COLOR_PINK, SideIconView.ICON_CARD);
		}

		public function get showIcon():Boolean
		{
			return true;
		}

		public function get isVisible():Boolean {
			return _isVisible;
		}

		public function set isVisible(value: Boolean): void {
			_isVisible = false;
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			if (e.hero.id != Game.selfId && e.hero.id > 0)
				return;

			if (e.hero.isDead || e.hero.isHare || e.hero.shaman)
				return;

			if (this.sended)
				return;

			this.hero = e.hero;

			activatePerk();

			this.sended = true;
		}

		private function activatePerk():void
		{
			this.perks = [];

			for each (var perk:Perk in this.hero.perkController.perksMana)
			{
				if (perk.active || perk is PerkReborn || perk is PerkTeleport)
					continue;

				this.perks.push(perk.code);
			}

			sendPerk();

			if (this.perks.length > 0)
				setTimeout(sendPerk, 1500);
		}

		private function sendPerk():void
		{
			var rand:int = Math.random() * this.perks.length;

			if (this.perks.length == 0)
				Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.perkCode, this.playerId);
			else
				Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.perkCode, this.playerId, this.perks[rand]);

			this.perks.splice(rand, 1);
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			var skill: PacketRoundSkillAction = packet as PacketRoundSkillAction;

			if (skill.type != this.perkCode)
				return;

			if (skill.targetId <= 0 || skill.targetId != this.playerId)
				return;

			if (!this.gameInst)
				return;

			this.gameInst.squirrels.get(skill.playerId).heroView.showGetBonusAnimation(this.view);

			if (!this.gameInst.squirrels.isSynchronizing)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}