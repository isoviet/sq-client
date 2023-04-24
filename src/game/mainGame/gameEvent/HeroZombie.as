package game.mainGame.gameEvent
{
	import flash.display.MovieClip;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.editor.ZombieBody;
	import sounds.GameSounds;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class HeroZombie extends Hero
	{
		static private const TIME:Number = 4.0;

		private var effectSmoke:ParticlesEffect;
		private var effectTransform:ParticlesEffect;

		private var _isZombie:Boolean = false;
		private var animation:MovieClip = null;

		public var timerZombie:Number = 0;
		public var first:Boolean = false;

		public function HeroZombie(playerId:int, world:b2World, x:int = 0, y:int = 0)
		{
			super(playerId, world, x, y);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function get viewClass():Class
		{
			return HeroViewZombie;
		}

		public function infect(teleport:Boolean = false):void
		{
			if (this.isZombie || this.timerZombie > 0)
				return;

			if (!this.first)
				GameSounds.play("zombie_infect" + int(Math.random() * 3));

			if (teleport)
				setTimeout(teleportZombie, 0);

			stun();
		}

		public function get isZombie():Boolean
		{
			return this._isZombie;
		}

		public function set isZombie(value:Boolean):void
		{
			if (value == this._isZombie)
				return;
			this._isZombie = value;

			this.heroView.allowCharacter = !value;

			(this.heroView as HeroViewZombie).isZombie = this.isZombie;
			if (this.isZombie)
				this.viewChanged = true;

			if (this.effectSmoke)
			{
				this.effectSmoke.stop();
				CollectionEffects.instance.removeEffect(this.effectSmoke);
				this.effectSmoke = null;
			}
			if (this.effectTransform)
			{
				this.effectTransform.stop();
				CollectionEffects.instance.removeEffect(this.effectTransform);
				this.effectTransform = null;
			}
			if (value)
			{
				this.effectSmoke = CollectionEffects.instance.getEffectByName(CollectionEffects.EFFECT_ZOMBIE_SMOKE);

				this.effectSmoke.view.visible = true;
				this.effectSmoke.view.y = -10;
				this.effectSmoke.start();

				addChildStarlingAt(this.effectSmoke.view, 0);
			}

			if (this.isZombie && this.isSelf)
				this.perkController.deactivateClothesPerks();
		}

		override public function set dead(value:Boolean):void
		{
			if (this.animation)
				this.animation.visible = !value;
			if (value && this.isZombie)
			{
				this.vitalityTimer.reset();
				this.vitalityTimer.start();

				stun();
				setTimeout(teleportZombie, 0);
				if (this.isSelf)
					Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'ZombieStun': this.id}));
				return;
			}

			if (this.effectSmoke)
				this.effectSmoke.view.visible = !value;
			if (this.effectTransform)
				this.effectTransform.view.visible = !value;

			super.dead = value;
		}

		override public function teleport(destination:int, position:b2Vec2 = null):void
		{
			teleportZombie();
		}

		override public function get isSquirrel():Boolean
		{
			return !(this.isDragon || this.isScrat || this.isHare || this.shaman || this.isZombie || this.timerZombie > 0);
		}

		override public function get isScrat():Boolean
		{
			return this._isScrat && !this.isDragon && !this.isHare && !this.shaman && !this.isZombie && this.timerZombie == 0;
		}

		override public function hide():void
		{
			super.hide();

			if (this.effectSmoke)
			{
				this.effectSmoke.stop();
				CollectionEffects.instance.removeEffect(this.effectSmoke);
				this.effectSmoke = null;
			}
			if (this.effectTransform)
			{
				this.effectTransform.stop();
				CollectionEffects.instance.removeEffect(this.effectTransform);
				this.effectTransform = null;
			}
		}

		override public function reset():void
		{
			this.isZombie = false;

			super.reset();

			this.isStoped = false;
			this.timerZombie = 0;

			if (this.effectSmoke)
			{
				this.effectSmoke.stop();
				CollectionEffects.instance.removeEffect(this.effectSmoke);
				this.effectSmoke = null;
			}
			if (this.effectTransform)
			{
				this.effectTransform.stop();
				CollectionEffects.instance.removeEffect(this.effectTransform);
				this.effectTransform = null;
			}

			if (this.animation && this.animation.parent)
				this.heroView.removeChild(this.animation);

			if (this.first)
				infect(true);
			this.first = false;
		}

		override public function get actualSpeed():Number
		{
			return super.actualSpeed * (this.isZombie ? (this.game.squirrels as SquirrelCollectionZombie).speedFactor : 1);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.isSelf && this.isZombie && (this.timerZombie <= 0))
			{
				var hero:HeroZombie = Hero.self as HeroZombie;
				if (hero && !hero.isZombie && (hero.timerZombie <= 0))
				{
					var pos:b2Vec2 = hero.position.Copy();
					pos.Subtract(this.position);
					if (pos.Length() < 4)
					{
						Connection.sendData(PacketClient.ROUND_ZOMBIE, this.id);
						hero.infect();
					}
				}
			}

			if (this.timerZombie > 0 && !this.isDead)
			{
				this.timerZombie -= timeStep;
				if (this.timerZombie <= 0)
				{
					this.isStoped = false;
					this.isZombie = true;

					if (this.animation && this.animation.parent)
						this.heroView.removeChild(this.animation);
				}
			}
		}

		private function teleportZombie():void
		{
			if (!this.game || !this.game.map)
				return;
			this.teleportTo(this.game.map.get(ZombieBody).length > 0 ? this.game.map.get(ZombieBody)[0].position : null);

			if (this.isSelf)
				sendLocation();
		}

		private function stun():void
		{
			this.timerZombie = TIME;
			this.isStoped = true;

			if (!this.isZombie)
			{
				this.effectTransform = CollectionEffects.instance.getEffectByName(CollectionEffects.EFFECT_ZOMBIE_TRANSFORM);
				this.effectTransform.view.visible = !this.isDead;
				this.effectTransform.start();

				addChildStarling(this.effectTransform.view);
			}

			if (!this.animation)
			{
				this.animation = new ZombieStunView();
				this.animation.y = -60;
			}
			this.animation.visible = !this.isDead;
			this.heroView.addChild(this.animation);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			if (packet.playerId != this.id || this.isSelf)
				return;

			if (!('ZombieStun' in packet.dataJson))
				return;
			stun();
		}
	}
}