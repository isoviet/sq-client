package game.mainGame.entity.magic
{
	import flash.events.Event;

	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.simple.InvisibleBody;
	import game.mainGame.entity.simple.PoiseRight;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import sounds.GameSounds;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkillAction;

	import utils.starling.StarlingAdapterMovie;

	public class PirateCannon extends InvisibleBody
	{
		private var isShoot:Boolean = false;
		private var delay:Number = 2.0;

		private var _direction:Boolean = true;
		private var disposed:Boolean = false;

		public function PirateCannon()
		{
			this.view = new StarlingAdapterMovie(new PirateCannonView);
			this.view.play();
			this.view.scaleXY(-0.5, 0.5);
			this.view.y = 30;
			this.view.addEventListener(Event.ENTER_FRAME, onFrame);
			addChildStarling(this.view);

			Connection.listen(onPacket, PacketRoundSkillAction.PACKET_ID);
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			var skill: PacketRoundSkillAction = packet as PacketRoundSkillAction;

			if (skill.type != PerkClothesFactory.PIRATE)
				return;

			GameSounds.play("canon");
		}

		private function onFrame(e:Event):void
		{
			if (this.isShoot)
			{
				if (this.view.currentFrame == 28)
				{
					this.view.stop();
					destroy();
				}
			}
			else
			{
				if (this.view.currentFrame == 5)
					this.view.gotoAndPlay(0);
			}
		}

		public function set direction(value:Boolean):void
		{
			if (this._direction == value)
				return;
			this._direction = value;

			this.view.scaleXY(this._direction ? -0.5 : 0.5, 0.5);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.delay, this._direction, this.playerId, this.isShoot]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.delay = data[1][0];
			this.direction = Boolean(data[1][1]);
			this.playerId = data[1][2];
			this.isShoot = Boolean(data[1][3]);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.playerId != Game.selfId)
				return;

			this.delay -= timeStep;
			if (this.delay > 0 || this.isShoot)
				return;

			this.isShoot = true;

			var castObject:GameBody = new PoiseRight();
			castObject.position = this.position;
			castObject.angle = this.angle + (this._direction ? 0 : (180 * Game.D2R));
			this.gameInst.map.createObjectSync(castObject, true);

			Connection.sendData(PacketClient.ROUND_SKILL_ACTION, PerkClothesFactory.PIRATE, this.playerId);

			this.view.gotoAndPlay(7);
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.view)
				this.view.removeEventListener(Event.ENTER_FRAME, onFrame);
		}

		private function destroy():void
		{
			if (this.disposed)
				return;
			this.disposed = true;
			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}