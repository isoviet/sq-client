package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.entity.simple.CollectionElement;
	import game.mainGame.entity.simple.Element;
	import screens.ScreenGame;
	import views.Settings;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundElement;
	import protocol.packages.server.PacketRoundSkill;

	import utils.starling.StarlingAdapterMovie;

	public class PerkClothesVampire extends PerkClothes
	{
		static private const SPEED:Number = 2;
		static private const FRONT_SPEED:Number = 1;
		static private const FRONT_DISTANCE:int = 16;

		private var collectionElement:Element;

		private var frontPosition:int = 0;
		private var frontSpeed:int = 1;

		private var view:MovieClip;
		private var viewElement:StarlingAdapterMovie;

		public function PerkClothesVampire(hero:Hero):void
		{
			super(hero);

			this.view = new VampireMagicSelf();
			this.soundOnlyHimself = true;
			this.activateSound = SOUND_WINGS;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get totalCooldown():Number
		{
			return 40;
		}

		override public function get activeTime():Number
		{
			return 15;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.active)
				moveElement(timeStep);
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundElement.PACKET_ID]);
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.running) && !(this.hero.heroView.fly);
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.collectionElement != null)
				this.collectionElement.view.play();

			if (this.view)
				this.view.removeEventListener(Event.CHANGE, preActive);

			if (this.viewElement != null && this.viewElement.parentStarling != null)
			{
				this.viewElement.removeFromParent(true);
				this.viewElement.removeEventListener(Event.COMPLETE, onMagicStart);
				this.viewElement.removeEventListener(Event.COMPLETE, onMagicEnd);
			}
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero.game)
				return;

			if (this.hero.isSelf)
				this.view.filters = Hero.GLOW_FILTERS[Settings.highlight];
			this.view.addEventListener(Event.CHANGE, preActive);
			this.view.gotoAndPlay(0);
			this.hero.addView(this.view);
			this.hero.isStoped = true;
		}

		override protected function deactivate():void
		{
			super.deactivate();
			if (this.hero && this.hero.id == Game.selfId)
				Connection.sendData(PacketClient.ROUND_SKILL, this.code, false, 0, "");

			if (this.viewElement != null && this.viewElement.parentStarling != null)
			{
				this.viewElement.removeEventListener(Event.COMPLETE, onMagicStart);
				this.viewElement.removeEventListener(Event.COMPLETE, onMagicEnd);
				this.viewElement.removeFromParent(true);
			}

			if (this.collectionElement != null)
			{
				this.collectionElement.view.play();
				this.viewElement = new StarlingAdapterMovie(new VampireMagicEnd());
				this.viewElement.play();
				this.viewElement.loop = false;
				this.viewElement.addEventListener(Event.COMPLETE, onMagicEnd);
				this.collectionElement.view.addChildStarling(this.viewElement);
			}
			this.collectionElement = null;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (isEndGame)
				return;

			switch (packet.packetId)
			{
				case PacketRoundElement.PACKET_ID:
					if (this.collectionElement == null || !(this.collectionElement is CollectionElement))
						return;
					if (this.collectionElement.index != (packet as PacketRoundElement).index)
						return;
					this.collectionElement = null;
					this.active = false;
					break;
				case PacketRoundSkill.PACKET_ID:
					var skill: PacketRoundSkill = packet as PacketRoundSkill;
					if (skill.state == PacketServer.SKILL_ERROR)
						return;
					if (this.hero != null && skill.type == this.code && skill.playerId == this.hero.id)
					{
						var index:int = skill.data;
						if (index == -1)
						{
							if (this.hero.id == Game.selfId)
								ScreenGame.sendMessage(this.hero.id, "", ChatDeadServiceMessage.VAMPIRE_PERK);
							return;
						}
						this.active = skill.state == PacketServer.SKILL_ACTIVATE;

						if (skill.state != PacketServer.SKILL_ACTIVATE)
							return;

						if (!(index in this.hero.game.map.elements))
							return;

						this.collectionElement = this.hero.game.map.elements[index];
						this.collectionElement.view.stop();

						this.viewElement = new StarlingAdapterMovie(new VampireMagicStart());
						this.viewElement.play();
						this.viewElement.addEventListener(Event.COMPLETE, onMagicStart);
						this.collectionElement.view.addChildStarling(this.viewElement);
					}
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function preActive(e:Event):void
		{
			this.view.removeEventListener(Event.CHANGE, preActive);

			this.hero.isStoped = false;
			this.hero.changeView();
		}

		private function onMagicStart(e:Event):void
		{
			if (this.viewElement != null && this.viewElement.parentStarling != null)
			{
				this.viewElement.removeEventListener(Event.COMPLETE, onMagicStart);
				this.viewElement.removeFromParent(true);
			}

			if (this.collectionElement != null)
			{
				this.viewElement = new StarlingAdapterMovie(new VampireMagicStand());
				this.viewElement.play();
				this.collectionElement.view.addChildStarling(this.viewElement);
			}
		}

		private function onMagicEnd(e:Event):void
		{
			if (this.viewElement != null && this.viewElement.parentStarling != null)
			{
				this.viewElement.removeEventListener(Event.COMPLETE, onMagicEnd);
				this.viewElement.removeFromParent(true);
			}
		}

		private function moveElement(timeStep:Number):void
		{
			if (!(this.hero && this.hero.game && this.hero.game.map) || (this.collectionElement == null))
				return;
			var vec:b2Vec2 = this.hero.position.Copy();
			vec.Subtract(this.collectionElement.position);

			var dist:Number = vec.Length();

			if (dist == 0)
				return;

			var speed:Number = Math.min(SPEED * timeStep, dist);
			var x:Number = this.collectionElement.position.x + speed * vec.x / dist;
			var y:Number = this.collectionElement.position.y + speed * vec.y / dist;

			x += Math.pow(FRONT_DISTANCE - Math.abs(this.frontPosition), 0.5) * this.frontSpeed * (FRONT_SPEED * timeStep) * (vec.y / dist);
			y -= Math.pow(FRONT_DISTANCE - Math.abs(this.frontPosition), 0.5) * this.frontSpeed * (FRONT_SPEED * timeStep) * (vec.x / dist);

			this.collectionElement.position = new b2Vec2(x, y);

			this.frontPosition += this.frontSpeed;
			if (Math.abs(this.frontPosition) >= FRONT_DISTANCE)
				this.frontSpeed *= -1;
		}
	}
}