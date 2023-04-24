package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundHollow;
	import protocol.packages.server.PacketRoundShaman;
	import protocol.packages.server.PacketRoundSkillAction;

	import utils.starling.particleSystem.CollectionEffects;

	public class PerkClothesPikachu extends PerkClothes
	{
		static private const RADIUS:Number = 45 / Game.PIXELS_TO_METRE;

		static private const DURATION:int = 3;

		static private var allVictims:Object = {};

		private var squirrels:Array = [];
		private var victims:Object = {};

		public function PerkClothesPikachu(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_ACCELERATION;
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.active || this.hero.id != Game.selfId)
				return;
			updateVictims(timeStep);

			findVictims();
		}

		override public function dispose():void
		{
			deleteAllVictim();

			super.dispose();
		}

		override protected function activate():void
		{
			if (isEndGame)
			{
				this.active = false;
				return;
			}

			super.activate();

			this.hero.applyEffect(CollectionEffects.EFFECTS_LIGHTNING);
			this.hero.applyEffect(CollectionEffects.EFFECTS_LIGHTNING_TAIL, -1);

			if (this.hero.id != Game.selfId)
				return;

			for each(var hero:Hero in this.hero.game.squirrels.players)
			{
				if (hero.isSelf || hero.isHare || hero.isDragon || hero.inHollow)
					continue;
				if (hero.isSquirrel && hero.perkController.getPerkLevel(PerkClothesFactory.PIKACHU) != -1)
					continue;

				this.squirrels.push(hero);
			}
		}

		override protected function deactivate():void
		{
			deleteAllVictim();

			super.deactivate();

			if (isEndGame)
				return;

			this.hero.disableEffect(CollectionEffects.EFFECTS_LIGHTNING);
			this.hero.disableEffect(CollectionEffects.EFFECTS_LIGHTNING_TAIL);
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundSkillAction.PACKET_ID]);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkillAction.PACKET_ID:
					var action:PacketRoundSkillAction = packet as PacketRoundSkillAction;
					if (action.type != this.code || this.hero.id != action.playerId)
						return;
					var hero:Hero = this.hero.game.squirrels.get(action.targetId);
					if (!hero)
						return;
					if ((action.data == 0) || hero.shaman || hero.isDead || hero.inHollow)
					{
						deleteVictim(hero.id);
						return;
					}
					this.victims[hero.id] = DURATION;

					hero.isStoped = allVictims[hero.id] = true;
					hero.applyEffect(CollectionEffects.EFFECTS_LIGHTNING);
					break;
				case PacketRoundShaman.PACKET_ID:
					super.onPacket(packet);

					var shamans:Vector.<int> = (packet as PacketRoundShaman).playerId;
					for each(var id:int in shamans)
						deleteVictim(id);
					break;
				case PacketRoundHollow.PACKET_ID:
					super.onPacket(packet);

					var hollow:PacketRoundHollow = packet as PacketRoundHollow;
					if (hollow.success != 0)
						return;
					deleteVictim(hollow.playerId);
					break;
				case PacketRoundDie.PACKET_ID:
					super.onPacket(packet);

					deleteVictim((packet as PacketRoundDie).playerId);
					break;
				case PacketRoomLeave.PACKET_ID:
					super.onPacket(packet);

					deleteVictim((packet as PacketRoomLeave).playerId);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function deleteVictim(id:int):void
		{
			allVictims[id] = false;

			if (!(id in this.victims))
				return;

			delete this.victims[id];

			if (isEndGame)
				return;

			var hero:Hero = this.hero.game.squirrels.get(id);

			if (!hero)
				return;

			hero.isStoped = false;
			hero.disableEffect(CollectionEffects.EFFECTS_LIGHTNING);
		}

		private function findVictims():void
		{
			var len:int = this.squirrels.length;
			var hero:Hero;
			while (len--)
			{
				hero = this.squirrels[len];

				if (hero.inHollow)
				{
					this.squirrels.splice(len, 1);
					continue;
				}

				if (allVictims[hero.id] || hero.shaman || hero.isDead)
					continue;

				var pos:b2Vec2 = this.hero.position.Copy();
				pos.Subtract(hero.position);

				if (pos.Length() > RADIUS)
					continue;

				this.squirrels.splice(len, 1);

				Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, hero.id, 1);
			}
		}

		private function updateVictims(timeStep:Number = 0):void
		{
			for (var id:String in this.victims)
			{
				this.victims[id] -= timeStep;
				if (this.victims[id] > 0)
					continue;
				Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, id, 0);
			}
		}

		private function deleteAllVictim():void
		{
			for (var id:String in this.victims)
				deleteVictim(int(id));

			this.squirrels = [];
			this.victims = {};
			allVictims = {};
		}
	}
}