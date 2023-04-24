package game.mainGame.perks.clothes
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.perks.Perk;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundHollow;
	import protocol.packages.server.PacketRoundShaman;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothes extends Perk
	{
		protected const SOUND_APPEARANCE:String = "appearance";
		protected const SOUND_FLYING:String = "flying";
		protected const SOUND_SMOKE:String = "smoke";
		protected const SOUND_ACCELERATION:String = "acceleration";
		protected const SOUND_TELEPORT:String = "teleport";
		protected const SOUND_ACTIVATE:String = "activate";
		protected const SOUND_DROP:String = "drop";
		protected const SOUND_WINGS:String = "wings";

		protected var buff:BuffRadialView = null;
		public var perkLevel:int = 0;

		public function PerkClothes(hero:Hero):void
		{
			super(hero);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.buff && this.activeTime != 0)
				this.buff.update(100 - 100 * (this.currentActiveTime / this.activeTime));
		}

		override public function get available():Boolean
		{
			return super.available && !this.isBlock && this.validHero;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (this.hero == null)
				return;
			switch (packet.packetId)
			{
				case PacketRoundShaman.PACKET_ID:
					var roundShaman:PacketRoundShaman = packet as PacketRoundShaman;
					var shamans:Vector.<int> = roundShaman.playerId;
					if (shamans.indexOf(this.hero.id) != -1)
						this.active = false;
					break;
				case PacketRoundHollow.PACKET_ID:
					var roundHollow:PacketRoundHollow = packet as PacketRoundHollow;
					if (roundHollow.success != 0)
						return;
					if (this.hero.id == roundHollow.playerId)
						this.active = false;
					break;
				case PacketRoundDie.PACKET_ID:
					var roundDie:PacketRoundDie = packet as PacketRoundDie;
					if (this.hero.id == roundDie.playerId)
						this.active = false;
					break;
				case PacketRoomLeave.PACKET_ID:
					var roomLeave:PacketRoomLeave = packet as PacketRoomLeave;
					if (this.hero.id == roomLeave.playerId)
						this.active = false;
					break;
				case PacketRoundSkill.PACKET_ID:
					var roundSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (roundSkill.state == PacketServer.SKILL_ERROR)
						return;
					if (roundSkill.type != this.code || roundSkill.playerId != this.hero.id)
						return;
					this.active = roundSkill.state == PacketServer.SKILL_ACTIVATE;
					break;
			}
		}

		override protected function get packets():Array
		{
			return [PacketRoundSkill.PACKET_ID, PacketRoundShaman.PACKET_ID, PacketRoundHollow.PACKET_ID, PacketRoundDie.PACKET_ID, PacketRoomLeave.PACKET_ID];
		}

		override protected function activate():void
		{
			super.activate();

			if (this is ITransformation)
				resetTransformations();

			if (!this.switchable || this.hero.id != Game.selfId)
				return;
			if (!this.buff)
			{
				var sprite:Sprite = new Sprite();
				var image:DisplayObject = PerkClothesFactory.getNewImage(this.code);
				image.scaleX = image.scaleY = 0.8;
				image.x = image.y = 15;
				sprite.addChild(image);
				this.buff = new BuffRadialView(sprite, 1, 0.25, PerkClothesFactory.getDescription(this.code));
			}
			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.hero && this.buff)
				this.hero.removeBuff(this.buff);
		}

		protected function get validHero():Boolean
		{
			return this.hero.isSquirrel;
		}

		protected function resetTransformations():void
		{
			var perksClothes:Vector.<PerkClothes> = this.hero.perkController.perksClothes;
			for (var i:int = 0; i < perksClothes.length; i++)
			{
				if (!(perksClothes[i] is ITransformation) || (perksClothes[i] == this) || !perksClothes[i].active)
					continue;
				perksClothes[i].active = false;
				Connection.sendData(PacketClient.ROUND_SKILL, perksClothes[i].code, PacketServer.SKILL_DEACTIVATE, 0, "");
			}
		}
	}
}