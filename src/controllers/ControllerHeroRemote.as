package controllers
{
	import flash.ui.Keyboard;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.IHealth;

	import protocol.Connection;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundCastBegin;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundHero;
	import protocol.packages.server.PacketRoundSmile;

	public class ControllerHeroRemote extends ControllerHero
	{
		static private const DIFF_TRESHOLD_MIN:Number = 5 / Game.PIXELS_TO_METRE;
		static private const DIFF_TRESHOLD_MAX:Number = 50 / Game.PIXELS_TO_METRE;

		private var playerId:int;

		public function ControllerHeroRemote(hero:IHero, playerId:int):void
		{
			Logger.add("ControllerHeroRemote.ControllerHeroRemote " + playerId);
			super(hero);

			hero.setController(this);

			this.playerId = playerId;

			Connection.listen(onPacket, [PacketRoundCastBegin.PACKET_ID, PacketRoundHero.PACKET_ID,
				PacketRoundDie.PACKET_ID, PacketRoundSmile.PACKET_ID]);
		}

		override public function remove():void
		{
			Logger.add("ControllerHeroRemote.remove " + this.playerId);
			super.remove();
			Connection.forget(onPacket, [PacketRoundCastBegin.PACKET_ID, PacketRoundHero.PACKET_ID,
				PacketRoundDie.PACKET_ID, PacketRoundSmile.PACKET_ID]);
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundCastBegin.PACKET_ID:
					if ((packet as PacketRoundCastBegin).playerId != playerId)
						break;
					this.hero.wakeUp();
					break;
				case PacketRoundHero.PACKET_ID:
					var pktHero: PacketRoundHero = packet as PacketRoundHero;
					if (pktHero.playerId != playerId)
						break;

					var newPosition:b2Vec2 = new b2Vec2(pktHero.posX, pktHero.posY);

					var distance:b2Vec2 = newPosition.Copy();
					distance.Subtract(this.hero.position);

					if (distance.Length() > DIFF_TRESHOLD_MIN && distance.Length() < DIFF_TRESHOLD_MAX)
						this.hero.interpolate(distance);
					else
					{
						this.hero.interpolate(null);
						this.hero.position = newPosition;
					}

					this.hero.velocity = new b2Vec2(pktHero.velX, pktHero.velY);

					this.hero.wakeUp();
					if (pktHero.health > -1 && this.hero is IHealth)
						(this.hero as IHealth).health = pktHero.health;
					var up:Boolean = (pktHero.keycode > 0);
					switch (Math.abs(pktHero.keycode))
					{
						case Keyboard.W:
						case Keyboard.SPACE:
						case Keyboard.UP:
							if (this.stoped)
								return;
							this.hero.jump(up);
							break;
						case Keyboard.A:
						case Keyboard.LEFT:
							if (this.stoped)
								return;
							this.hero.moveLeft(up);
							break;
						case Keyboard.D:
						case Keyboard.RIGHT:
							if (this.stoped)
								return;
							this.hero.moveRight(up);
							break;
						case Keyboard.F1:
						case Keyboard.F2:
						case Keyboard.F3:
						case Keyboard.F4:
							this.hero.setEmotion(Math.abs(pktHero.keycode) - 111);
							break;
					}
					break;
				case PacketRoundDie.PACKET_ID:
					var die: PacketRoundDie = packet as PacketRoundDie;
					if (die.playerId != playerId)
						break;

					this.hero.interpolate(null);
					hero.position = new b2Vec2(die.posX, die.posY);
					hero.velocity = new b2Vec2();
					break;
				case PacketRoundSmile.PACKET_ID:
					var smile: PacketRoundSmile = packet as PacketRoundSmile;

					if (smile.player != playerId)
						break;
					this.hero.setEmotion(smile.smile + Hero.EMOTION_MAX_TYPE);
					break;
			}
		}
	}
}