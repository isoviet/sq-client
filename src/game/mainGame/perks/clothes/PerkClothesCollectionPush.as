package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.magic.EnergyObject;
	import game.mainGame.entity.magic.MagicianCard;
	import game.mainGame.entity.simple.Element;
	import game.mainGame.entity.simple.GameBody;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesCollectionPush extends PerkClothes
	{
		static private const SPEED:Number = 7.5;

		private var elements:Array = null;
		private var view:MovieClip = null;

		public function PerkClothesCollectionPush(hero:Hero):void
		{
			super(hero);

			this.activateSound = "push";
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get activeTime():Number
		{
			return 1.2;
		}

		override public function get maxCountUse():int
		{
			return 1;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.active)
				move(timeStep);
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero.game)
				return;

			this.elements = this.hero.game.map.get(Element, true);
			this.elements = this.elements.concat(this.hero.game.map.get(EnergyObject, true)).concat(this.hero.game.map.get(MagicianCard, true));

			this.view = new MagicElectroPushView();
			this.view.addEventListener(Event.CHANGE, onChange);
			this.hero.addView(this.view, true);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			super.onPacket(packet);

			var skill:PacketRoundSkill = packet as PacketRoundSkill;
			if (skill == null)
				return;

			if (!this.hero || skill.type != PerkClothesFactory.STORM || skill.playerId != this.hero.id || skill.state != PacketServer.SKILL_ACTIVATE)
				return;

			this.currentCooldown = this.totalCooldown;
			dispatchEvent(new Event("STATE_CHANGED"));
		}

		private function move(timeStep:Number):void
		{
			if (!this.hero || this.hero.isDead || this.hero.shaman || this.hero.inHollow)
			{
				this.active = false;
				return;
			}

			for each (var body:GameBody in this.elements)
			{
				if (body.body == null)
					continue;
				var vec:b2Vec2 = new b2Vec2(body.position.x - this.hero.position.x, body.position.y - this.hero.position.y);
				vec.Multiply((SPEED * timeStep) / vec.Length());
				vec.Add(body.position);
				vec.x = Math.max(0, Math.min(vec.x, this.hero.game.map.size.x / Game.PIXELS_TO_METRE));
				vec.y = Math.max(0, Math.min(vec.y, this.hero.game.map.size.y / Game.PIXELS_TO_METRE));
				body.position = vec;
			}
		}

		private function onChange(e:Event):void
		{
			if (this.hero)
				this.hero.changeView();
			this.view.removeEventListener(Event.CHANGE, onChange);
			this.view = null;
		}
	}
}